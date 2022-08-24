--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO "dvd-rental";

--======== �������� ����� ==============

--������� �1
--�������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:
--������������ ��� ������� �� 1 �� N �� ����

/*�������� �������

select customer_id , payment_id , payment_date,  
row_number () over ()
from payment p*/

--������ �������

--explain analyse --1942
select *
from (
	select customer_id , payment_id , payment_date,
	row_number () over (order by payment_date) as "������ �������� �� ����"
	from payment p) t 
where payment_id in (5,14,3,32,10)

--������� ������� � count
select * 
from (
	select customer_id , payment_id , payment_date,
	count (payment_id) over (order by payment_date ) as "������ �������� �� ����"
	from payment p ) t
where payment_id in (5,14,3,32,10)

--������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����

--explain analyse --1982
select * 
from (
	select customer_id , payment_id , payment_date ,
	row_number () over (partition by customer_id order by payment_date)  
	from payment p) t
where payment_id in (5,14,3,32,10)

--���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ 
--���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������

--explain analyse --1982
select * 
from (
	select customer_id , payment_id , payment_date , amount,
	sum(amount) over (partition by customer_id order by payment_date) as "����"
	from payment p) t
where payment_id in (5,14,3,32,10)	
order by customer_id, "����"

--�������� ���������
/*select * 
from (
	select customer_id , payment_id , payment_date , amount,
	sum(amount) over (partition by customer_id order by payment_date::date) as "����"
	from payment p) t
where payment_id in (5,14,3,32,10)	
order by customer_id, "����"*/



--������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� 
--���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
--����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.

--explain analyse --1982
select * 
from (
	select customer_id , payment_id, payment_date , amount ,
	dense_rank () over (partition by customer_id order by amount desc)  
	from payment p) t 
where payment_id in (5,14,3,32,10)

--explain analyse 1982
select * 
from (
	select customer_id , payment_id, payment_date , amount ,
	rank () over (partition by customer_id order by amount desc)  
	from payment p) t
where payment_id in (5,14,3,32,10)


--����� ������

--explain analyze --7769
select t1.customer_id , t1.payment_id, t1.payment_date, "������ �������� �� ����", "������� ������� ����������" ,  "����", "��������� �� ���������" 
from (
		select customer_id , payment_id , payment_date,
		row_number () over (order by payment_date) as "������ �������� �� ����"
		from payment p) t1 
join (
		select customer_id , payment_id , payment_date ,
		row_number () over (partition by customer_id order by payment_date) as "������� ������� ����������"   
		from payment p) t2  using (payment_id)
join (
	select customer_id , payment_id , payment_date , amount,
		sum(amount) over (partition by customer_id order by payment_date) as  "����"
		from payment p) t3  using (payment_id)
join (
		select customer_id , payment_id, payment_date , amount ,
		dense_rank () over (partition by customer_id order by amount desc) as "��������� �� ���������" 
		from payment p) t4  using (payment_id)
where t1.payment_id in (5,14,3,32,10)
--order by t1.customer_id, "����"

--������� �2
--� ������� ������� ������� �������� ��� ������� ���������� ��������� ������� � ��������� 
--������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.

select customer_id, payment_id , payment_date , amount , 
lag (amount, 1, 0.0) over (partition by customer_id order by payment_date)
from payment p 
limit 5



--������� �3
--� ������� ������� ������� ����������, �� ������� ������ ��������� ������ ���������� ������ ��� ������ ��������.

select customer_id, payment_id , payment_date , amount , 
amount - lead (amount) over (partition by customer_id order by payment_date) as difference
from payment p 
limit 5

select customer_id, payment_id , payment_date , amount , 
amount - lag (amount, -1) over (partition by customer_id order by payment_date) as difference
from payment p 
limit 5


--������� �4
--� ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.

--explain analyze
select distinct on (customer_id) customer_id, payment_id , payment_date ,
first_value (amount) over (partition by customer_id order by (payment_date , payment_id )desc) as last_amount
from payment p 
limit 5

/*select distinct on (customer_id) customer_id, payment_id , payment_date ,
last_value (amount) over (partition by customer_id order by (payment_date, payment_id) desc ) as last_amount
from payment p 
limit 5*/

select distinct on (customer_id) customer_id, payment_id , payment_date ,
first_value (amount) over (partition by customer_id order by payment_date desc
rows between unbounded preceding and unbounded following) from payment p 
limit 5

--explain analyze
/*select  distinct on (customer_id) customer_id, payment_id , payment_date , amount, 
last_value (amount) over (partition by customer_id order by payment_date desc) as last_amount
from payment p */


--======== �������������� ����� ==============

--������� �1
--� ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ������ 2005 ���� 
--� ����������� ������ �� ������� ���������� � �� ������ ���� ������� (��� ����� �������) 
--� ����������� �� ����.


select distinct 
staff_id, payment_date::date date,
sum(amount) over (partition by (staff_id, cast (payment_date as date)) order by payment_date::date) as "sum(amount)",
sum(sum(amount)) over (partition by staff_id order by payment_date::date) as sum
from payment
where payment_date::date between '01.08.2005' and '31.08.2005'
group by staff_id , payment_date, amount 


--������� �2
--20 ������� 2005 ���� � ��������� ��������� �����: ���������� ������� ������ ������� �������
--�������������� ������ �� ��������� ������. � ������� ������� ������� �������� ���� �����������,
--������� � ���� ���������� ����� �������� ������

--explain analyse 
select *
from (
	select *, row_number () over (order by payment_date) num
	from (
		select customer_id , payment_date , amount
		from payment p
		where payment_date::date = '20.08.2005') t ) t1
where t1.num % 100 = 0


--������� �3
--��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
-- 1. ����������, ������������ ���������� ���������� �������
-- 2. ����������, ������������ ������� �� ����� ������� �����
-- 3. ����������, ������� ��������� ��������� �����

with 
cte1 as (
	select 
		c.customer_id, 
		c3.country_id, 
		count(i.film_id),
		sum(p.amount), 
		max(r.rental_date)
	from customer c
		join rental r on r.customer_id = c.customer_id
		join inventory i on i.inventory_id = r.inventory_id
		join payment p on p.rental_id = r.rental_id
		join address a on a.address_id = c.address_id
		join city c2 on c2.city_id = a.city_id
		join country c3 on c3.country_id = c2.country_id
	group by c.customer_id, c3.country_id),
cte2 as (
	select 
		customer_id, 
		country_id,
		row_number () over (partition by country_id order by count desc) countf,
		row_number () over (partition by country_id order by sum desc) suma,
		row_number () over (partition by country_id order by max desc) maxd
	from cte1
)
select c.country, 
	concat (c5.first_name, ' ',c5.last_name ) "������ �������", 
	concat (c6.first_name, ' ',c6.last_name ) "������ ����� ��������", 
	concat (c7.first_name, ' ',c7.last_name ) "����� ��������� ������"
from country c
	left join cte2 cte_1 on cte_1.country_id = c.country_id and cte_1.countf = 1
	left join cte2 cte_2 on cte_2.country_id = c.country_id and cte_2.suma = 1
	left join cte2 cte_3 on cte_3.country_id = c.country_id and cte_3.maxd = 1
	left join customer c5 on c5.customer_id = cte_1.customer_id 
	left join customer c6 on c6.customer_id = cte_2.customer_id
	left join customer c7 on c7.customer_id = cte_3.customer_id 
order by 1

