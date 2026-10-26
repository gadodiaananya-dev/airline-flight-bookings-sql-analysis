USE airline_booking_clean;

-- 1.  Find all bookings made in 2025 with a total amount greater than 50000.
select * from bookings where year(book_date) = 2025 and total_amount > 50000;

-- 2. Find the top 10 highest priced segments (fare paid per flight leg).
select * from segments order by price desc limit 10;

-- 3. Find passengers whose names start with "A" and who are on an outbound journey
select * from tickets where passenger_name like "A%" and outbound = 1; 

 -- 4. Find the total number of segments, total revenue, average price, minimum price 
 -- and maximum price 
 select count(*), round(sum(price),2) as total_revenue, round(avg(price),2) as avg_price, 
 min(price), max(price) from segments;
 
 -- 5. Find the number of segments and total revenue for each fare condition
 select count(*), sum(price) as total_revenue, fare_conditions from segments group by fare_conditions;
 
 -- 6. Find airports having more than 40 departing flights 
 select count(*), departure_airport from flights group by departure_airport having count(*) >40;
 
 -- 7. Display each passenger's name in uppercase along with the length of their name 
 select ticket_no, book_ref, upper(passenger_name), length(passenger_name) from tickets;
 
 -- 8. Find the number of flights scheduled in each month
 select count(*), monthname(scheduled_departure) from flights group by monthname(scheduled_departure);
 
 -- 9. Categorize segments based on price as low, Medium, or High.
 select ticket_no, flight_id,price,
 case
	when price < 5000 then "Low"
    when price between 5000 and 20000 then "Medium"
    else "High" end as price_category from segments;
    
-- 10. Find the average flight duration (in minutes) for each flight status.
select round(avg(timestampdiff(minute, scheduled_departure, scheduled_arrival)),3) as avg_flight_duration, status from flights group by status;

-- 11. Display each flight along with its departure and arrival airport names
select flight_id, airplane_code, departure_airport, arrival_airport from flights;

-- 12. Display flight details along with the airplane model and seat capacity
select
	flights.flight_id,
    flights.flight_no,
    flights.airplane_code,
    airplanes.model,
    airplanes.seat_capacity
from flights join airplanes on
				flights.airplane_code = airplanes.airplane_code;
                
-- 13. Find the total number of segments and total revenue for each departure airport 
select 
	count(*) as total_segments,
    round(sum(segments.price),2) as total_revenue,
    flights.departure_airport,
    airports.airport_code,
    airports.airport_name
from segments join flights on 
	segments.flight_id = flights.flight_id
join airports on
	flights.departure_airport = airports.airport_code
group by 
	airports.airport_code,
    airports.airport_name;

-- 14. Display airplanes along with their model, range, speed and seat capacity
select * from airplanes;

-- 15. Find the top 5 routes (departure-arrival pairs) based on total revenue 
select
	flights.departure_airport,
    flights.arrival_airport,
    round(sum(segments.price),3) as total_revenue
from flights join segments on
	flights.flight_id = segments.flight_id
group by 
	flights.departure_airport,
    flights.arrival_airport
order by 
	total_revenue desc
limit 5;

-- 16. Display segments along with their check in status (seat assigned or not)
select ticket_no,flight_id, seat_no,
case
	when seat_no is not null then "Checked_In"
    else "Not Checked In" end as check_in_status from segments;
    
-- 17. Find the total booking amount for each month
select 
	round(sum(total_amount),3) as booking_amount, 
    month(book_date) as booking_month
from bookings
group by booking_month;

-- 18. Find bookings whose total amount is greater than the average total amount of all bookings
select * from bookings where total_amount > (select round(avg(total_amount),2) as avg_total_amount from bookings);

-- 19. Find airplanes whose seat capacity is higher than the average seat capacity of all airplanes
select * from airplanes where seat_capacity > (
select avg(seat_capacity) from airplanes);

-- 20. Find segments whose price is greater than the average price of all Business Class segments
select ticket_no, flight_id, price from segments where price > (
select avg(price) from segments where fare_conditions = "Business");

-- 21. Using a CTE, calculate the total segments and total revenue for each departure airport,
-- then display airports generating more than 1000000 in revenue.
with airport_stats as(
	select
		count(*) as total_segments,
        round(sum(segments.price),2) as total_revenue,
        flights.departure_airport
	from segments join flights on
		segments.flight_id = flights.flight_id
	group by flights.departure_airport)
select 
	airports.airport_name, 
    airport_stats.total_segments,
    round(airport_stats.total_revenue,3) as total_revenue
from airport_stats join airports on
	airport_stats.departure_airport = airports.airport_code
where airport_stats.total_revenue > 1000000
order by airport_stats.total_revenue desc;

-- 22. Create a view showing high-value bookings with a total amount of 50,000 or above
create view high_value_bookings as
select book_ref, book_date, total_amount from bookings where total_amount >= 50000;

select * from high_value_bookings;

-- 23. Rank segments within each flight based on the price paid.
select ticket_no, flight_id, price, rank() over (partition by flight_id order by price desc)
as price_rank from segments;

-- 24. Display each segment along with the previous segment's price for the same ticket
select ticket_no, flight_id, price, lag(price) over (partition by ticket_no) as previous_segment_pr
from segments;

-- 25. Assign a row number to flights within each airplane based on scheduled departure time.
select flight_id, flight_no, airplane_code, scheduled_departure,
row_number() over (partition by airplane_code order by scheduled_departure) as flight_sequence
from flights;