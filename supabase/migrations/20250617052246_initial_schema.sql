drop table if exists room_dates;
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

create table room_dates (
    venue_id SMALLINT NOT NULL REFERENCES venues(id),
    room_id INT NOT NULL REFERENCES rooms(id),
    r_date DATE NOT NULL,
    actual_capacity INT,
    PRIMARY KEY (room_id, r_date),
    FOREIGN KEY (venue_id, r_date) REFERENCES venues_dates(venue_id, v_date)
);

CREATE OR REPLACE FUNCTION insert_room_dates_for_venue()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert one room_date per room in the venue, using capacity from rooms table
    INSERT INTO room_dates (venue_id, room_id, r_date, actual_capacity)
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

CREATE TRIGGER trg_insert_room_dates
AFTER INSERT ON venues_dates
FOR EACH ROW
EXECUTE FUNCTION insert_room_dates_for_venue();

