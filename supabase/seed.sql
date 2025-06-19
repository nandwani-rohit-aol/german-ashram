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
    (1, 'F202', 2, 4),
    (1, 'F204', 3, 4), 
    (1, 'F205', 2, 4),
    (1, 'F206', 3, 5),
    (1, 'F207', 2, 4),
    (1, 'F208', 3, 4), 
    (1, 'F209', 2, 4),
    (1, 'F210', 3, 4), 
    (2, 'Aparna 203', 3, 4) ;

----------------------------------------
insert into users (name) values 
    ('sunil'),
    ('rohit'),
    ('nandu'),
    ('raju'),
    ('Jhans'),
    ('suresh'),
    ('karthik'),
    ('srinivas'),
    ('priya'),
    ('anil'),
    ('sanjay'),
    ('manoj'),
    ('deepak'),
    ('ravi'),
    ('arun'),
    ('nithya'),
    ('sudha'),
    ('kavitha'),
    ('mohan'),
    ('gopal'),
    ('vijay'),
    ('ramu'),
    ('suresh kumar'),
    ('rahul'),
    ('santosh'),
    ('pradeep'),
    ('suresh babu'),
    ('karthik kumar'),
    ('srinivas reddy'),
    ('priya kumari'),
    ('anil kumar'),
    ('sanjay kumar'),
    ('manoj kumar'),
    ('deepak kumar'),
    ('ravi kumar'),
    ('arun kumar') ;
    
----------------------------------------
insert into venues_dates (venue_id, v_date)
values 
    (1, '2025-06-01'),
    (1, '2025-06-02'),
    (1, '2025-06-03'),
    (1, '2025-06-04'),
    (1, '2025-06-05'),
    (1, '2025-06-06'),
    (1, '2025-06-07'),
    (1, '2025-06-08'),
    (1, '2025-06-09'),
    (1, '2025-06-10'),
    (1, '2025-06-11'),
    (1, '2025-06-12'),
    (1, '2025-06-13'),
    (1, '2025-06-14'),
    (1, '2025-06-15'),
    (1, '2025-06-16'),
    (1, '2025-06-17'),
    (1, '2025-06-18'),
    (1, '2025-06-19'),
    (1, '2025-06-20'),
    (1, '2025-06-21'),
    (1, '2025-06-22'),
    (1, '2025-06-23'),
    (1, '2025-06-24'),
    (1, '2025-06-25'),
    (1, '2025-06-26'),
    (1, '2025-06-27'),
    (1, '2025-06-28'),
    (1, '2025-06-29'),
    (1, '2025-06-30') ;