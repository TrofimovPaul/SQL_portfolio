- - -�������� ������- - -


�1 � ����� ������� ������ ������ ���������?

--explain analyze --5.08
select a.city "�������� ������" --,count(a.airport_code) "���������� ����������"
from airports a 
group by a.city
having count(a.airport_code) > 1

/*--���� ���������� �������� ������ ����������, �� ����� ������� ���������
--explain analyze --8.91
select a.airport_code "��� ���������",
	a.airport_name "�������� ���������",
	a.city "�������� ������",
	a.longitude "�������",
	a.latitude "������",
	a.timezone "��������� ����"
from airports a
join (
	select a.city 
	from airports a 
	group by a.city
	having count(a.airport_code) > 1) t1 using (city)
	
*/

/*--����� ����� ���� ��������� ������ �� �������� ��
SELECT 
	a.airport_code as code,
	a.airport_name,
	a.city,
	a.longitude,
	a.latitude,
	a.timezone
FROM airports a
WHERE a.city IN (
	SELECT aa.city
	FROM airports aa
	GROUP BY aa.city
	HAVING COUNT(*) > 1
	)
ORDER BY a.city, a.airport_code*/

�2 � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?
- ���������

--����� ������������, ��� �� ��� ������� ��������� ������ �� ������ � ����� � ���� ������������, 
--�����, ���� ���������, ���� ������� ������ ��������� ��� ������ ������ ��������.
--��� ������������� ����� ���������, ��������� ���������� �� ���������� ������ � ������ � ������� UNION (UNION ALL) ��. ������� #3
--����� �����������, ��� �������� � ����� ������ �� 9, � � ���� ������. 
--��������������, ����� ���� ������� ������������� ����� ������ ����� �������, � ��� ������, ��� ���������� ��������� ������� MAX ��� ����������.

--#1 ������� � ����������� �� ����� ������� 
--explain analyze --836
select /*distinct*/ f.departure_airport, f.aircraft_code from 
flights f
where f.aircraft_code = (
	select aircraft_code 
	from aircrafts a
	order by "range" desc
	limit 1)	
group by f.departure_airport, f.aircraft_code

/*--#2 ������� � �������� MAX
--explain analyze --837 ������ group by �� distinct �� ������ ��������� 
select /*distinct*/ f.departure_airport, f.aircraft_code from 
flights f
where f.aircraft_code = (
	select a1.aircraft_code 
	from aircrafts a1 
	where a1."range" = (
		select max(a2."range") 
		from aircrafts a2)
	)
group by f.departure_airport, f.aircraft_code*/

/*--#3 ������� � ���������, ������� �� ���������� ���������
--explain analyze --1721
select f.departure_airport as "�������� ������", f.aircraft_code "��� �������" from 
flights f
where f.aircraft_code = (
	select aircraft_code 
	from aircrafts a
	order by "range" desc
	limit 1)	
group by f.departure_airport, f.aircraft_code
union
select f.arrival_airport as "�������� ������", f.aircraft_code "��� �������" from 
flights f
where f.aircraft_code = (
	select aircraft_code 
	from aircrafts a
	order by "range" desc
	limit 1)
group by f.arrival_airport , f.aircraft_code*/

/*--������ ����� ���������� � ��������������, ��� ������� ��������� ����� � ���� ������������, ��� ������� ���������� �������������� ������������� ��� ������� ������� aircrafts
--explain analyze --819
select distinct f.departure_airport, f.aircraft_code from 
flights f
where f.aircraft_code = '773'
group by f.departure_airport, f.aircraft_code*/

�3 ������� 10 ������ � ������������ �������� �������� ������
- �������� LIMIT*/

select f.flight_id, (f.actual_departure - f.scheduled_departure) as max_delay
from flights f 
where (f.actual_departure - f.scheduled_departure) is not null /*and (f.actual_departure - f.scheduled_departure)!='00:00:00'*/
order by (f.actual_departure - f.scheduled_departure) desc
limit 10

�4 ���� �� �����, �� ������� �� ���� �������� ���������� ������? 
- ������ ��� JOIN*/

select distinct t.book_ref as "����� �����"/*, t.ticket_no as "������ from tickets", bp.ticket_no as "������ from boarding_passes" */
from tickets t 
left join boarding_passes bp using (ticket_no)
where bp.ticket_no is null --91388 ���������� ������, �� ������� �� ���� �������� ���������� ������ --127899 ������, �� ������� �� ���� �������� ���������� ������


/* 
select t.book_ref , t.ticket_no, bp.ticket_no 
from tickets t 
left join boarding_passes bp using (ticket_no) --707585 ��� ��� ���� ��������� ����� ���������� ������ ����������

select tf.ticket_no 
from ticket_flights tf --1045726 ��� ��������� ���������� ������ (�������� �� flight_id)

select distinct tf.ticket_no --366733 ����� ���������� �������
from ticket_flights tf

select t.book_ref "����� �����" --366733 ��� ������ ����� � �������� �������� ��� ������ �������
from tickets t
order by t.book_ref 

select distinct t.book_ref "����� �����" --262788 ����� ���������� ������� �����
from tickets t

select * from boarding_passes bp --579686 �������� ���������� �������

--explain analyze
select distinct tf.ticket_no as r1, bp.ticket_no as r2 --127899 ��� ������, �� ������� �� ���� �������� ���������� ������
from ticket_flights tf --����� ���� ��������, ��� �� ������ ������ �� ������� ����� ���� �����, � �� ������� �� �������� ��������� �������
left join boarding_passes bp using (ticket_no) 
where bp.ticket_no is null*/

/*������ ���� �������� �� ������ ���� �� ����� �����, � �������������� � �����, ��� ���������� ����� �� ��� ���� �� ������ �������� �� (������� ������� �� �����������, ������ � ��������� � �.�.).
�� ����, ���� �� �� ���� �� ������ �� ��� �� ���� ���������� ����� �� �����-���� �������, 
� �������� ������� �������� �� ��� �����, ����� �����. ���������� � ������� ���������� not null ������� ��������, � ������,
�� �������� �� ������ ���� ����, �� ������� �� ��� ���� ���������� �����, � ����� ���� ����� ��� ������. 
����� �� �������������� ����� ����� ����� �������� ������ ������, �� ������� �� ���� ����� ���������� ������ (�� �������, ����� �� ������������ ������)
� ������� �������, ��� ����������� �� ������ ������ ������ �� ������� ����������� �������, � �����, ���� ������� ������ 'Scheduled', 'On Time' ��� 'Delayed'.
��, ��� �� �����, (��� ������������� � ������� not null), ����� ������ ���, ��� ������� ��� � ���, 
��� �� ������ �������� �� ��� ��������� ������� ���� �� ����� ����������� �� �����, � ��������� ���������� �� ������*/

/*--���������� � ������� ������ ������, �� ������� �� ����� ���������� ������ � �� ������� �� ����� ��� �����
select /*count (*/distinct tf.flight_id/*)*//*, sub3.s1 */--���������� � ������� ������ ������, �� ������� �� ����� ���������� ������ � �� ������� �� ����� ��� �����
from (
	--������ ������� � �����, �� ������� �� ����� ���������� ������ sub1
	select distinct 
		t1.book_ref as "����� �����", 
		t1.ticket_no as tick1,
		bp.ticket_no as "������ from boarding_passes"
	from tickets t1 
		left join boarding_passes bp using (ticket_no)
	where bp.ticket_no is null
	) sub1
join ticket_flights tf on sub1.tick1 = tf.ticket_no
left join (--������������ ������� �� ���������� sub3=(sub-t) � ������� ���� �������� �� ����� ������� sub1
	--�����, ������� ������������ � ������� sub � ����������� � ������� t, sub3=(sub-t). �� ���� ������ ��� ������ ������ ����������� 
	select s1 
	from (
		--��� �����, ������� �������� ��� �������� sub
		select fv.flight_id as s1, fv.status as st1, t.flight_id  as s2, t.status as st2 -- �������� ���� fv, ������ fv, ���� t, ������ t
		from flights_v fv 
		left join (-- ������������ ������� �� ���������� t � ������� ���� �������� �� ����� ������� flights_v fv
			--�����, ������� �������� ��� �������� � ������� �������� �� t	
			select --  �������� �����, ������, ����� �����������, ����� ����������� ����, ������� ����� �������� �������� ������� � �������� �����������
				fv2.flight_id , 
				fv2.status,
				fv2.scheduled_departure, 
				fv2.actual_departure,
				bookings.now()-fv2.scheduled_departure as difference
			from flights_v fv2
			where fv2.status not in ('Scheduled', 'On Time', 'Delayed') and --2 ��������� ��������, ������� �� �����, ������� ������� ��� ������������ � �����������, 
			(fv2.scheduled_departure <= bookings.now() or fv2.actual_departure <= bookings.now()) -- � ��, � ������� ����� ����������� ��������� ������, ��� ���� ������� ��
			order by fv2.flight_id) t using (flight_id) -- ��������� �������� �� �����
		where fv.status not in ('Scheduled', 'On Time', 'Delayed')) sub
	where sub.s2 is null ) sub3 on tf.flight_id = sub3.s1 --�����, ������� ������������ � ������� sub � ����������� � ������� t, sub3=(sub-t). �� ���� ������ ������ ������ ����������� 
where sub3.s1 is /*not*/ null 
order by tf.flight_id */

/*
select fv.flight_id , fv.status 
from flights_v fv 
where fv.status not in ('Scheduled', 'On Time', 'Delayed') --17179 ��� �������, ������� ��� �������� ��� ��������*/

/*
select 
fv.flight_id ,
fv.status,
fv.scheduled_departure, 
fv.actual_departure,
bookings.now()-fv.scheduled_departure as difference
from flights_v fv
where fv.status not in ('Scheduled', 'On Time', 'Delayed') and (fv.scheduled_departure <= bookings.now() or fv.actual_departure <= bookings.now())
order by flight_id --16773 �����, ������� ��� ������� ��� ���� �������� �� ������ �������� ��. �� ���� ��� �����, �� ������� ��������� ����������� �� ������ �������� ��.*/

/*
select s1 from (select fv.flight_id as s1, fv.status as st1, t.flight_id  as s2, t.status as st2
from flights_v fv 
left join (
select 
fv2.flight_id ,
fv2.status,
fv2.scheduled_departure, 
fv2.actual_departure,
bookings.now()-fv2.scheduled_departure as difference
from flights_v fv2
where fv2.status not in ('Scheduled', 'On Time', 'Delayed') and (fv2.scheduled_departure <= bookings.now() or fv2.actual_departure <= bookings.now())
order by fv2.flight_id) t using (flight_id)
where fv.status not in ('Scheduled', 'On Time', 'Delayed') --��� �������, �� ������� ������ ���� ������ ����������� �� ������ �������� �� 
) sub
where sub.s2 is null*/

/*
select ticket_no, count(flight_id) --238834
from boarding_passes bp
group by ticket_no
having count(flight_id)=1
order by count desc

6 3310
5 97
4 67303
3 3298
2 115409
1 49417

262788		366733			1045726
book 	-> 	ticket1 	-> 	boarding_pass1
		-> 	ticket2 	-> 	boarding_pass1
						-> 	boarding_pass2

������ ������������ ����� �������� ��������� �������, �� ������ �� ������� ���������.
�����, � ���� �������, ����� �������� ��������� ���������. 
����� ����� ���������� ����� (ticket_no), ��������� �� 13 ����.
������ ���������� � ������������ ��������� � ���� ��������: bookings, tickets � ticket_flights.

��� ����������� �� ����, ������� �������� �� ����� �� �������� ���� �����������,
��������� �������� ���������� �����. �� ���������������� �����, ��� � ������� �
������� ������ � ������� �����.
���������� ������� ������������� ���������������� ������ (boarding_no) � �������
����������� ���������� �� ���� (���� ����� ����� ���������� ������ � �������� �������
�����). � ���������� ������ ����������� ����� ����� (seat_no).*/


�5 ������� ���������� ��������� ���� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
�������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
�.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ � ������� ���.
- ������� �������
- ���������� ���/� CTE

select * , 
sum(sub.seats-"free") 
over 
(partition by sub.scheduled_departure::date, sub.departure_airport order by sub.flight_id )
as peoplesum_from_airport_in_day
from (
	select distinct 
		tf.flight_id, 
		a.aircraft_code,
		sub1.seats,
		f.departure_airport, 
		f.scheduled_departure::date,
		(sub1.seats - count(tf.ticket_no) over (partition by tf.flight_id)) "free",
		((sub1.seats-count(tf.ticket_no) over (partition by tf.flight_id))/sub1.seats)*100 "% free/sum"
	from ticket_flights tf 
	join flights f using (flight_id)
	join aircrafts a using (aircraft_code)
	join (
		--max seats
		select s.aircraft_code , sum(count(s.seat_no)) over (partition by s.aircraft_code) as seats
		from seats s
		group by s.aircraft_code
		) sub1 
	using (aircraft_code)
	order by f.scheduled_departure::date	
	) sub

�6 ������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.
- ��������� ��� ����
- �������� ROUND

/*select sum("% of flights_sum")--100.001
from (*/
	select f.aircraft_code, 
	round((count(f.flight_id )/sum(count(f.flight_id)) over ())*100, 3)::numeric(10,5) as "% of flights_sum"
	from flights f
	group by f.aircraft_code
/*) sub1*/


�7 ���� �� ������, � ������� ����� ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?
- CTE

/*����� �������� ���� ��� ��������� ��������� (ticket_flights). ��������� ��������� �����
���������� � ����� � �������, ����� ��� ������� �����, ������������ ������
����������� � ���������� (����� � �����������), ���� ����� ����� ���� ����� � �������.
� ����� ������ ��� �������� �����������, �� ��������������, ��� ��� ������ � �����
������������ ����� ���������� ����� ���������.
������ = ����*/

--EXISTS ����� ���������� �������, � ������� ����� ���� ��������� ������ - ������� �������, ��� ������-������� � ������ �������� �� ������ �������� ��
--explain analyze --729288
select count("�������� ������") "���-�� �������" 
from (
	--����� ���������� �������
	select distinct "�������� ������" 
	from (
			--����� ������� (� ������) � ������� ��������� ������-������ � ��������� ������-������
			select distinct fv.arrival_city "�������� ������",/* tf.flight_id "ID �����",*/ tf.amount "��������� ������-������", sub.amount "��������� ������-������"
			from ticket_flights tf 
			join (
				select tf1.flight_id, tf1.fare_conditions, tf1.amount 
				from ticket_flights tf1 
				where fare_conditions = 'Economy' --����� � ������-�������
				) sub using (flight_id)
			join flights_v fv using (flight_id)
			where tf.fare_conditions = 'Business' --����� � ������-�������
			) sub1
	where "��������� ������-������" < "��������� ������-������" ) sub2
where exists (
select "�������� ������" where "�������� ������"<>'0')

--��� EXISTS. ����� �������, ��� ������-����� ������� ������-������
--explain analyze --727183
select * from (
	--����� �������, � ������� ����� ��������� ������ - ������� �������, ��� ������-������� � ������ �������� �� ������ �������� ��
	select distinct
		a.city "�������� ������",
		tf.flight_id "ID �����",
		tf.amount "��������� ������-������",
		sub.amount "��������� ������-������"
	from ticket_flights tf 
	join (
		select tf1.flight_id, tf1.fare_conditions, tf1.amount 
		from ticket_flights tf1 
		where fare_conditions = 'Economy' --����� � ������-�������
		) sub using (flight_id)
	join flights f using (flight_id)
	join airports a on a.airport_code = f.arrival_airport 
	where tf.fare_conditions = 'Business' --����� � ������-�������
		) sub1
		where "��������� ������-������" < "��������� ������-������"

-- �� �� ����� � ����� ������������ ����� �������������
--explain analyze --727490
select * from (
	--����� �������, � ������� ����� ���� ��������� ������ - ������� �������, ��� ������-������� � ������ �������� �� ������ �������� ��
	select distinct
		fv.arrival_city "�������� ������",
		tf.flight_id "ID �����",
		tf.amount "��������� ������-������",
		sub.amount "��������� ������-������"
	from ticket_flights tf 
	join (
		select tf1.flight_id, tf1.fare_conditions, tf1.amount 
		from ticket_flights tf1 
		where fare_conditions = 'Economy' --����� � ������-�������
		) sub using (flight_id)
	join flights_v fv using (flight_id)
	where tf.fare_conditions = 'Business' --����� � ������-�������
		) sub1
		where "��������� ������-������" < "��������� ������-������"		

/*
--���������� ������, � ������� ������ ������� ������� ������ � ������
select distinct fv.arrival_city "�������� ������"/*, tf.flight_id "ID �����", tf.amount "��������� ������-������", sub.amount "��������� ������-������"*/
		from ticket_flights tf 
		join (
			select tf1.flight_id, tf1.fare_conditions, tf1.amount 
			from ticket_flights tf1 
			where fare_conditions = 'Economy' --����� � ������-�������
			) sub using (flight_id)
		join flights_v fv using (flight_id)
		where tf.fare_conditions = 'Business'
		
select distinct fv.arrival_city, fv.departure_airport ,s.fare_conditions from flights_v fv 
join seats s using (aircraft_code)
where s.fare_conditions = 'Comfort'

--������, � ������� ��� �� ��������� ������� ������� ������ � ������
select distinct fv1.arrival_city, "�������� ������", sub1.fare_conditions from flights_v fv1
left join (select distinct fv.arrival_city "�������� ������", sub3.fare_conditions /*, tf.flight_id "ID �����", tf.amount "��������� ������-������", sub.amount "��������� ������-������"*/
		from ticket_flights tf 
		join (
			select tf1.flight_id, tf1.fare_conditions, tf1.amount 
			from ticket_flights tf1 
			where fare_conditions = 'Economy' --����� � ������-�������
			) sub using (flight_id)
		join flights_v fv using (flight_id)
		join (select distinct fv.arrival_city, s.fare_conditions from flights_v fv 
join seats s using (aircraft_code)) sub3 using (arrival_city)
		where tf.fare_conditions = 'Business') sub1 on "�������� ������"=fv1.arrival_city
where "�������� ������" is null

select * from flights_v fv 
where fv.arrival_city = '�����������'

select * from seats s 
where aircraft_code = 'CR2'


/*select * from ticket_flights tf -- ��� ���������� ������ 1045726

select distinct ticket_no, count (flight_id) from ticket_flights tf
group by ticket_no --��� ������ 366733

select ticket_no from boarding_passes bp -- ��� ������ ���������� ������ 579686 

select distinct ticket_no from boarding_passes bp --238834 ��� ������ , �� ������� ���� ���� �� ���� �� �������

select distinct t.book_ref "����� �����" --262788 ����� ���������� ������� �����
from tickets t

select b.book_ref , b.total_amount, t.ticket_no, bp.flight_id 
from bookings b 
join tickets t using (book_ref)
join boarding_passes bp using (ticket_no)*/

*/

�8 ����� ������ �������� ��� ������ ������? - ��������� ������������ � ����������� FROM - �������������� ��������� �������������
(���� �������� �����������, �� ��� �������������) - �������� EXCEPT

--�������� ������������������ ������������� �� ����� ������ �������
create materialized view "all_pairs" as
select distinct a1.city as city1, a2.city as city2 --���������� ������ 101 
from airports a1, airports a2 -- ����� ����������� 101*101=10201, �� �� ������� ������ ����� ������� �������� � 100 �������, �������������� 101*100=10100, �� ���� �����������, ������ 10100/2=5050
where a1.city < a2.city 
with no data

--���������� ������������������ �������������
refresh materialized view all_pairs

--drop materialized view all_pairs

--�������� ������������� � ���������� ������ �������
create view "unique_pairs" as (
select distinct r.departure_city as city1, r.arrival_city as city2 -- ���������� ����� 516/2=258
from routes r
where r.departure_city < r.arrival_city)

--drop view unique_pairs

--4792 ���� ������� ��� ������ ������
--explain analyze 
select * from all_pairs ap 
except
select * from unique_pairs up 
order by city1

/*--��������
--������, ������� �� ����� ������ ������ � �����-����������� --78
select * from (
select * from all_pairs ap 
except
select * from unique_pairs up 
order by city1 ) t
where t.city1 = '�����-���������' or t.city2 = '�����-���������'

--������, ������� ����� ������ ����� � �����-����������� --22
SELECT distinct r.departure_city,
r.arrival_city 
FROM routes r
where r.departure_city < r.arrival_city and (r.departure_city = '�����-���������' or r.arrival_city = '�����-���������')

--�������� ������� 22+78=100*/

�9 ��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� ������������ ���������� ��������� � ���������, ������������� ��� �����
- �������� RADIANS ���
������������� SIND/COSD
- CASE
* - � �������� ���� ���������� ��������� � ������� airports_data.coordinates - ���������,
��� � ��������. � ��������� ���� ���������� ��������� � �������� airports.longitude �
airports.latitude.
���������� ���������� ����� ����� ������� A � B �� ������ ����������� (���� �������
�� �� �����) ������������ ������������:
d = arccos {sin(latitude_a)�sin(latitude_b) + cos(latitude_a)�cos(latitude_b)�cos(longitude_a -
longitude_b)}, ��� latitude_a � latitude_b � ������, longitude_a, longitude_b � �������
������ �������, d � ���������� ����� �������� ���������� � �������� ������ ����
�������� ����� ������� ����.
���������� ����� ��������, ���������� � ����������, ������������ �� �������:
L = d�R, ��� R = 6371 �� � ������� ������ ������� ����

select 
	sub1."�������� �1", 
	sub1."�������� �2", 
	sub1."���������� ����� �����������", 
	case
		when sub1."��������� �����" > sub1."���������� ����� �����������" then '������ �������'
		else '���������� ������������� �������'
	end as "�������� �� ���������"/*,
	case
		when sub1."��������� �����" > sub1."���������� ����� �����������" then "��������� �����"-"���������� ����� �����������"
		else "��������� �����"-"���������� ����� �����������"
	end as "����� �� ���������"*/
from (
select distinct 
	r.departure_airport, 
	r.departure_airport_name as "�������� �1",
	a1.longitude as dep_longitude, 
	a1.latitude as dep_latitude, 
	r.arrival_airport, 
	r.arrival_airport_name as "�������� �2",
	a2.longitude as arr_longitude, 
	a2.latitude as arr_latitude,
	radians(acosd(sind(a1.latitude)*sind(a2.latitude)+cosd(a1.latitude)*cosd(a2.latitude)*cosd(a1.longitude-a2.longitude)))*6371 as "���������� ����� �����������",
	a3.model "������ �������",
	a3."range" as "��������� �����"
from routes r
join airports a1 on r.departure_airport = a1.airport_code 
join airports a2 on r.arrival_airport = a2.airport_code
join aircrafts a3 using (aircraft_code)
where r.departure_airport < r.arrival_airport) sub1
order by "�������� �� ���������", sub1."�������� �1", sub1."���������� ����� �����������"
