-- Final Exam MIS 443 Q4 - 2024-2025 - Skeleton
-- Your ID: 2132300562
-- Your Name: Nguyen Thanh Dat
/*
Question 1 (10 marks): Create a database named “yourfullname” (e.g: dangthaidoan”) use PGAdmin, then create a schema name “cd” that has three tables: members, bookings and facilities 
using SQL statements. Ensure each table includes appropriate primary and foreign keys, and data types. 
Submit the SQL script as part of your answer.
*/
-- Create a new table named 'students':

CREATE TABLE ba.students (
    studentid integer NOT NULL,
    fullname varchar(50) NOT NULL,
    email varchar(50) NOT NULL
);
INSERT INTO ba.students(studentid, fullname, email) VALUES
(2132300562, 'Nguyen Thanh Dat', 'dat.n.bbs21@eiu.edu.vn')

-- Q1.A Check tables
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'ba' 
ORDER BY table_name, ordinal_position;

-- Q1. B. check table student
-- Your answer here
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'ba' and table_name = 'students'
ORDER BY table_name, ordinal_position;
-- End your answer

/*
Question 2 (10 marks): Write an SQL query to find the top 3 facilities that have been booked the most number of total slots (not just number of bookings).
Display their facility ID and the total number of slots booked, sorted from highest to lowest.
*/
-- Your answer here
select facid, total_slots from (select
	bo.facid,
	sum(slots) as total_slots,
	rank() over(order by sum(slots) desc) as ranking
from ba.bookings bo
group by bo.facid)
where ranking <= 3
order by total_slots desc;
-- End your answer
/*
Question 3 (20 marks): Write an SQL query to display all bookings that lasted more than 2 slots, along with the member ID, facility ID, and facility name, 
sorted by member ID and then by start time (ascending).
*/
-- Your answer here
select bo.bookid, bo.memid, bo.facid, fa.name as facility_name, starttime, slots from ba.bookings bo
left join ba.facilities fa on fa.facid = bo.facid
where slots > 2
order by bo.memid, starttime;
-- End your answer
/*
Question 4 (20 marks):  Write an SQL query to display each member and the number of bookings they made for facility ID = 1. 
Include all members, even those who have never booked that facility.
*/
-- Your answer here
with memid_and_fa1_books as (
	select bo.memid, count(bookid) as facility1_bookings from ba.bookings bo
	where bo.facid = 1
	group by bo.memid
	order by facility1_bookings desc)
select
	mb.memid,
	mb.firstname || ' ' || mb.surname as member_name,
	fa1.facility1_bookings
from ba.members mb
left join memid_and_fa1_books fa1 on fa1.memid = mb.memid
order by (case when fa1.facility1_bookings is null then 1 else 0 end), fa1.facility1_bookings desc, mb.memid;
-- End your answer
/*
Question 5 (20 marks):   Write an SQL query to show the total number of slots booked by guests (memid = 0) for each facility.
Include the facility name and display the result in descending order of total slots used.
*/
-- Your answer here
with filtered_0_memid as (select * from ba.bookings bo
where memid = 0)
select cte.facid, fa.name, sum(cte.slots) as total_slots from filtered_0_memid cte
left join ba.facilities fa on fa.facid = cte.facid
group by cte.facid, fa.name
order by total_slots desc
-- End your answer
/*
Question 6 (20 marks): Write an SQL query to rank members based on their total number of bookings. 
Members with the same number of bookings should have the same rank. Only include members who have made at least one booking
*/
-- Your answer here
with members_and_bookings as (
	select
		bo.memid,
		mb.firstname || ' ' || mb.surname as member_name,
		count(bookid) as total_bookings
	from ba.bookings bo
	left join ba.members mb on mb.memid = bo.memid
	group by bo.memid, member_name
	order by total_bookings desc)
select
	mab.memid,
	mab.member_name,
	mab.total_bookings,
	rank() over(order by total_bookings desc)
from members_and_bookings mab
where total_bookings > 0;
-- End your answer
