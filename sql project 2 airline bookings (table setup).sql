SET GLOBAL local_infile = 1;

CREATE DATABASE airline_booking_clean;
USE airline_booking_clean;

CREATE TABLE airports (
	airport_code varchar(10) primary key,
    airport_name varchar(100),
    city varchar(50),
    country varchar(50),
    timezone varchar(50)
);

LOAD DATA LOCAL INFILE "C:\\Users\\91766\\Downloads\\cleaned_data\\1_airports_clean.csv"
into table airports
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows 
(airport_code, airport_name, city, country, timezone);

select count(*) from airports;
select * from airports;


create table airplanes (
	airplane_code varchar(10) primary key,
    model varchar(50),
    range_km int,
    speed_kmh int,
    seat_capacity int
);

load data local infile "C:\\Users\\91766\\Downloads\\cleaned_data\\2_airplanes_clean.csv"
into table airplanes
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows 
(airplane_code, model, range_km, speed_kmh, seat_capacity);

select count(*) from airplanes;
select * from airplanes;

create table seats(
	airplane_code varchar(10),
    seat_no varchar(10),
    fare_conditions varchar(20),
    primary key (airplane_code, seat_no),
    foreign key (airplane_code) references airplanes (airplane_code)
);

load data local infile "C:\\Users\\91766\\Downloads\\cleaned_data\\3_seats_clean.csv"
into table seats 
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(airplane_code, seat_no, fare_conditions);

select count(*) from seats;
select fare_conditions, count(*) from seats group by fare_conditions;


create table flights(
	flight_id int primary key,
    flight_no varchar(10),
    airplane_code varchar(10),
    departure_airport varchar(10),
    arrival_airport varchar(10),
    scheduled_departure datetime,
    scheduled_arrival datetime,
    actual_departure datetime,
    actual_arrival datetime,
    status varchar(20),
    foreign key (airplane_code) references airplanes(airplane_code),
    foreign key (departure_airport) references airports(airport_code),
    foreign key (arrival_airport) references airports(airport_code)
);

load data local infile "C:\\Users\\91766\\Downloads\\cleaned_data\\4_flights_clean.csv"
into table flights 
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows 
(flight_id, flight_no, airplane_code, departure_airport, arrival_airport,
scheduled_departure, scheduled_arrival, @actual_departure, @actual_arrival, status)
set
	actual_departure = nullif(@actual_departure, ''),
    actual_arrival = nullif(@actual_arrival, '');
    
select count(*) from flights;
select count(*) from flights where actual_departure is null;
select status, count(*) from flights group by status;


create table bookings(
	book_ref varchar(10) primary key,
    book_date datetime,
    total_amount decimal(10,2)
);

load data local infile "C:\\Users\\91766\\Downloads\\cleaned_data\\5_bookings_clean.csv"
into table bookings
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(book_ref, book_date, total_amount);

select count(*) from bookings;
select round(avg(total_amount),2), min(total_amount), max(total_amount) from bookings;
select count(*) from bookings where total_amount > 50000 and year(book_date) = 2025;


create table tickets(
	ticket_no varchar(20) primary key,
    book_ref varchar(10),
    passenger_id varchar(20),
    passenger_name varchar(100),
    outbound tinyint,
    foreign key (book_ref) references bookings(book_ref)
);

load data local infile "C:\\Users\\91766\\Downloads\\cleaned_data\\6_tickets_clean.csv"
into table tickets
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows 
(ticket_no, book_ref, passenger_id, passenger_name, @outbound)
set outbound = (@outbound = 'True');

select count(*) from tickets;
select outbound, count(*) from tickets group by outbound;
select count(*) from tickets where passenger_name like 'A%' and outbound = 1;

create table segments(
	ticket_no varchar(20),
    flight_id int,
    fare_conditions varchar(20),
    price decimal (10,2),
    seat_no varchar(10),
    boarding_no int,
    boarding_time datetime,
    primary key (ticket_no, flight_id),
    foreign key (ticket_no) references tickets (ticket_no),
    foreign key (flight_id) references flights (flight_id)
);

LOAD DATA LOCAL INFILE "C://Users//91766//Downloads//cleaned_data//7_segments_clean.csv"
INTO TABLE segments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ticket_no, flight_id, fare_conditions, price, @seat_no, @boarding_no, @boarding_time)
SET
  seat_no       = NULLIF(@seat_no, ''),
  boarding_no   = NULLIF(@boarding_no, ''),
  boarding_time = NULLIF(@boarding_time, '');
  
SELECT COUNT(*) FROM segments;                           
SELECT ROUND(SUM(price),2) FROM segments;                 
SELECT COUNT(*) FROM segments WHERE seat_no IS NOT NULL; 

SELECT 'airports'  AS tbl, COUNT(*) AS `rows` FROM airports
UNION ALL SELECT 'airplanes', COUNT(*) FROM airplanes
UNION ALL SELECT 'seats',     COUNT(*) FROM seats
UNION ALL SELECT 'flights',   COUNT(*) FROM flights
UNION ALL SELECT 'bookings',  COUNT(*) FROM bookings
UNION ALL SELECT 'tickets',   COUNT(*) FROM tickets
UNION ALL SELECT 'segments',  COUNT(*) FROM segments;