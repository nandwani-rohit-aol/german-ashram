drop table if exists rooms_dates;
drop table if exists venues_dates;
drop table if exists rooms;
drop table if exists users;
drop view if exists VW_HALLS;
drop table if exists halls;
drop view if exists VW_VENUES;
drop table if exists venues;
drop table if exists tenants;

create table tenants (
    id SMALLSERIAL PRIMARY KEY,
    name VARCHAR(50) unique NOT NULL,
    code VARCHAR(5) unique NOT NULL
);

create table venues (
    id SMALLSERIAL PRIMARY KEY,
    tenant_id SMALLINT NOT NULL REFERENCES tenants(id),
    name VARCHAR(50) unique NOT NULL,
    capacity INT,
    full_capacity INT
);

create or replace view VW_VENUES AS
    select b.name as tenant_name, b.code as tenant_code, a.*
    from VENUES a
    LEFT JOIN tenants b on a.tenant_id = b.id ;

create table halls (
    id SERIAL PRIMARY KEY,
    venue_id SMALLINT NOT NULL REFERENCES venues(id),
    name VARCHAR(50) NOT NULL,
    capacity INT,
    full_capacity INT,
    created_at timestamp with time zone not null default now(),
    UNIQUE (venue_id, name)
);

create or replace view VW_HALLS as
    select a.*,
        b.tenant_id, b.tenant_name, b.tenant_code,
        b.name as venue_name,
        b.capacity as venue_capacity,
        b.full_capacity as venue_full_capacity
    from halls a
    left join VW_VENUES b on a.venue_id = b.id ;


create table users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) unique NOT NULL
);

create table rooms (
    id SERIAL PRIMARY KEY,
    venue_id SMALLINT NOT NULL REFERENCES venues(id),
    name VARCHAR(50) NOT NULL,
    UNIQUE (venue_id, name),
    capacity INT,
    full_capacity INT,
    created_at timestamp with time zone not null default now()
);

create table venues_dates (
    venue_id SMALLINT NOT NULL REFERENCES venues(id),
    v_date DATE NOT NULL,
    is_full_capacity BOOL default false,
    actual_capacity INT,
    PRIMARY KEY (venue_id, v_date)
);

create table rooms_dates (
    venue_id SMALLINT NOT NULL REFERENCES venues(id),
    room_id INT NOT NULL REFERENCES rooms(id),
    r_date DATE NOT NULL,
    actual_capacity INT,
    PRIMARY KEY (room_id, r_date),
    FOREIGN KEY (venue_id, r_date) REFERENCES venues_dates(venue_id, v_date)
);

create table beds_dates (
	bed_id SMALLINT NOT NULL,
	room_id SMALLINT NOT NULL references rooms(id),
	b_date DATE NOT NULL,
	is_bed_active BOOL default false,
	PRIMARY KEY (room_id, b_date, bed_id),
	FOREIGN KEY (room_id, b_date) REFERENCES rooms_dates(room_id, r_date)
);

CREATE OR REPLACE FUNCTION insert_rooms_dates_for_venue()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert one room_date per room in the venue, using capacity from rooms table
    INSERT INTO rooms_dates (venue_id, room_id, r_date, actual_capacity)
    SELECT
        r.venue_id,
        r.id as room_id,
        NEW.v_date,
        r.capacity
    FROM rooms r
    WHERE r.venue_id = NEW.venue_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insert_rooms_dates
AFTER INSERT ON venues_dates
FOR EACH ROW
EXECUTE FUNCTION insert_rooms_dates_for_venue();

CREATE OR REPLACE FUNCTION create_beds_after_room_date()
RETURNS TRIGGER AS $$
BEGIN
    FOR i IN 1..NEW.actual_capacity LOOP
        INSERT INTO beds_dates (bed_id, room_id, b_date)
        VALUES (i, NEW.room_id, NEW.r_date);
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_create_beds_after_insert
AFTER INSERT ON rooms_dates
FOR EACH ROW
EXECUTE FUNCTION create_beds_after_room_date();

CREATE OR REPLACE FUNCTION update_beds_on_capacity_change()
RETURNS TRIGGER AS $$
DECLARE
    current_count INT;
BEGIN
    IF NEW.actual_capacity = OLD.actual_capacity THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*) INTO current_count FROM beds_dates
    WHERE room_id = NEW.room_id AND b_date = NEW.r_date;

    -- If capacity increased
    IF NEW.actual_capacity > current_count THEN
        FOR i IN (current_count + 1)..NEW.actual_capacity LOOP
            INSERT INTO beds_dates (bed_id, room_id, b_date)
            VALUES (i, NEW.room_id, NEW.r_date);
        END LOOP;
    END IF;

    -- If capacity decreased
    IF NEW.actual_capacity < current_count THEN
        DELETE FROM beds_dates
        WHERE room_id = NEW.room_id AND b_date = NEW.r_date
              AND bed_id > NEW.actual_capacity
              AND is_bed_active = false;
              
        -- Ensure we didn't fail due to active beds
        SELECT COUNT(*) INTO current_count FROM beds_dates
        WHERE room_id = NEW.room_id AND b_date = NEW.r_date;

        IF current_count > NEW.actual_capacity THEN
            RAISE EXCEPTION 'Cannot reduce capacity: some excess beds are active.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_beds_after_capacity_change
AFTER UPDATE OF actual_capacity ON rooms_dates
FOR EACH ROW
EXECUTE FUNCTION update_beds_on_capacity_change();

CREATE OR REPLACE FUNCTION prevent_deleting_active_beds()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.is_bed_active THEN
        RAISE EXCEPTION 'Cannot delete an active bed.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_bed_deletion
BEFORE DELETE ON beds_dates
FOR EACH ROW
EXECUTE FUNCTION prevent_deleting_active_beds();

CREATE OR REPLACE FUNCTION check_room_capacity_limit()
RETURNS TRIGGER AS $$
DECLARE
    max_capacity INT;
BEGIN
    SELECT full_capacity INTO max_capacity
    FROM rooms WHERE id = NEW.room_id;

    IF NEW.actual_capacity > max_capacity THEN
        RAISE EXCEPTION 'actual_capacity (%), exceeds room.full_capacity (%)', NEW.actual_capacity, max_capacity;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_actual_capacity
BEFORE INSERT OR UPDATE ON rooms_dates
FOR EACH ROW
EXECUTE FUNCTION check_room_capacity_limit();

