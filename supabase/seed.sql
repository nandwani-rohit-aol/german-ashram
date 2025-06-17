insert into tenants (name, code)
values
    ('Germany', 'DE'),
    ('India', 'IN') ;

insert into venues (tenant_id, name, capacity, full_capacity)
values
    (1, 'Bad Antogast Ashram', 200, 300),
    (2, 'Bangalore ashram', 2000, 3500) ;

insert into halls (venue_id, name, capacity, full_capacity)
values
    (1, 'Krishna', 50, 70),
    (1, 'Jesus', 70, 100),
    (1, 'Buddha', 20, 25),
    (2, 'Buddha', 45, 60) ;

insert into rooms (venue_id, name, capacity, full_capacity)
values
    (1, 'F201', 2, 4),
    (1, 'F202', 3, 5),
    (1, 'M301', 2, 4),
    (1, 'M302', 3, 4),
    (2, 'Aparna 203', 3, 4) ;



--- 
insert into venues_dates (venue_id, v_date)
values
    (1, '2025-06-01'),
    (1, '2025-06-02'),
    (1, '2025-06-03'),
    (1, '2025-06-04'),
    (1, '2025-06-05') ;

