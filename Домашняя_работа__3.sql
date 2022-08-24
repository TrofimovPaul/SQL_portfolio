--=============== ������ 3. ������ SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO "dvd-rental";--� ��� ������ ���� dvd-rental 

SET search_path TO "public";

--======== �������� ����� ==============

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.

select concat(c.last_name, ' ', c.first_name), a.address, city.city, cn.country 
from customer c
join address a on c.address_id=a.address_id 
join city on a.city_id=city.city_id 
join country cn on city.country_id=cn.country_id

--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.
select  store_id "ID ��������", count(customer) "���������� �����������" from customer 
group by (store_id)




--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.
select  store_id "ID ��������", count(customer) "���������� �����������" from customer 
group by (store_id)
having count(customer)>300




-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.
select  
	c.store_id "ID ��������", 
	count(c.customer_id)  "���������� �����������" ,  
	city.city "�������� ������", 
	concat(s.last_name, ' ', s.first_name) "������ ����������" 
from customer c
	join store str on str.store_id =c.store_id 
	join address a on str.address_id=a.address_id 
	join city on a.city_id=city.city_id 
	join staff s on s.staff_id = str.manager_staff_id 
group by (c.store_id, city.city, s.last_name, s.first_name)
having count(c.customer_id)>300

--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������

/*select concat (c.last_name, ' ', c.first_name), count(r.rental_id) from rental r
join customer c on r.customer_id =c.customer_id 
group by (c.customer_id)
order by (count(r.rental_id)) desc
limit 5*/

/*select concat (c.last_name, ' ', c.first_name) "������ ����������", count(r.rental_id) "���������� �������" from rental r
join customer c on r.customer_id =c.customer_id 
group by (c.customer_id)
order by ("���������� �������") desc
limit 5*/

select concat (c.last_name, ' ', c.first_name) "������ ����������", count(r.rental_id) "���������� �������" from rental r
join customer c on r.customer_id =c.customer_id 
group by (c.customer_id)
order by (2) desc
limit 5



--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������

--��� ���� �����������
--explain analyze --1388
select
	concat (c.last_name, ' ', c.first_name) "������ ����������",
	count(r.rental_id) "���������� �������",
	round(sum(p.amount)),
	MIN (p.amount),
	max (p.amount) "Max"
from rental r
	join customer c on r.customer_id =c.customer_id 
	join inventory i on r.inventory_id =i.inventory_id 
	join film f on f.film_id =i.film_id
	join payment p on p.rental_id = r.rental_id 
	group by (c.customer_id)

--�������� �� ��������� �� ���������
--explain analyze --902
select
	concat (c.last_name, ' ', c.first_name) "������ ����������",
	count(r.rental_id) "���������� �������",
	round(sum(p.amount)) "����� ����� �������",
	MIN (p.amount) "Min",
	max (p.amount) "Max"
from rental r
	join customer c on r.customer_id =c.customer_id 
	join inventory i on r.inventory_id =i.inventory_id 
	join film f on f.film_id =i.film_id
	join payment p on p.rental_id = r.rental_id 
group by (c.customer_id)
having lower(c.last_name) in ('collazo','crouse','wiles','tubbs', 'watson')

/*select
	concat (c.last_name, ' ', c.first_name) "������ ����������",
	count(r.rental_id) "���������� �������",
	round(sum(p.amount)) "����� ����� �������",
	MIN (p.amount) "Min,
	max (p.amount) "Max"
from rental r
	join customer c on r.customer_id =c.customer_id 
	join inventory i on r.inventory_id =i.inventory_id 
	join film f on f.film_id =i.film_id
	join payment p on p.rental_id = r.rental_id 
group by (c.customer_id)
having c.last_name in (upper('collazo'),upper('crouse'),upper('wiles'),upper('tubbs'),upper( 'watson'))*/ --��� ���� ��������

--in ilike ������������ :(


--�������� ������ ��� �������� �� ���������. ������ ��� �������
--explain analyze --3740
select
	concat (c.last_name, ' ', c.first_name) "������ ����������",
	count(r.rental_id) "���������� �������",
	round(sum(p.amount)) "����� ����� �������",
	MIN (p.amount),
	max (p.amount) "Max"
from rental r
	join customer c on r.customer_id =c.customer_id 
	join inventory i on r.inventory_id =i.inventory_id 
	join film f on f.film_id =i.film_id
	join payment p on p.rental_id = r.rental_id 
where c.last_name ilike 'crouse'
	group by (c.customer_id)
union all 
select
		concat (c.last_name, ' ', c.first_name) "������ ����������",
		count(r.rental_id) "���������� �������",
		round(sum(p.amount)) "����� ����� �������",
		MIN (p.amount),
		max (p.amount) "Max"
	from rental r
		join customer c on r.customer_id =c.customer_id 
		join inventory i on r.inventory_id =i.inventory_id 
		join film f on f.film_id =i.film_id
		join payment p on p.rental_id = r.rental_id 
	where c.last_name ilike 'collazo'
		group by (c.customer_id)
	union
select
			concat (c.last_name, ' ', c.first_name) "������ ����������",
			count(r.rental_id) "���������� �������",
			round(sum(p.amount)) "����� ����� �������",
			MIN (p.amount),
			max (p.amount) "Max"
		from rental r
			join customer c on r.customer_id =c.customer_id 
			join inventory i on r.inventory_id =i.inventory_id 
			join film f on f.film_id =i.film_id
			join payment p on p.rental_id = r.rental_id 
		where c.last_name ilike 'wiles'
			group by (c.customer_id)
		union 
			select
				concat (c.last_name, ' ', c.first_name) "������ ����������",
				count(r.rental_id) "���������� �������",
				round(sum(p.amount)) "����� ����� �������",
				MIN (p.amount),
				max (p.amount) "Max"
			from rental r
				join customer c on r.customer_id =c.customer_id 
				join inventory i on r.inventory_id =i.inventory_id 
				join film f on f.film_id =i.film_id
				join payment p on p.rental_id = r.rental_id 
			where c.last_name ilike 'tubbs'
				group by (c.customer_id)
			union 
				select
					concat (c.last_name, ' ', c.first_name) "������ ����������",
					count(r.rental_id) "���������� �������",
					round(sum(p.amount)) "����� ����� �������",
					MIN (p.amount),
					max (p.amount) "Max"
				from rental r
					join customer c on r.customer_id =c.customer_id 
					join inventory i on r.inventory_id =i.inventory_id 
					join film f on f.film_id =i.film_id
					join payment p on p.rental_id = r.rental_id 
				where c.last_name ilike 'watson'
					group by (c.customer_id)





--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.

				
select c1.city, c2.city from city c1 -- ����� ����� ��� �������� 359398
cross join city c2
where c1.city not in (c2.city) 

 /*select c1.city, c2.city from city c1 --����� ����� ����� 360000
 cross join city c2*/
 
 --360000-359398=602
 
 /*select c1.city, c2.city from city c1 --602 ������ ��� ����������� inner join
join city c2 on c1.city = c2.city*/
 
 /*select city,count(city) from city --2 ������ London ����������� � ������� ��
group by (city)
having count(city)>1*/
 
 /*select c1.city, c2.city from city c1 --4 ������ London ��� ����������� cross join
 cross join city c2
 where c1.city ilike 'london' and c1.city=c2.city*/

/*select city, 
city_id from city where city='London'*/ --2 id ��� ������ ������

/*select city from city --600*/

--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.

--explain analyze-- 549
select customer_id "ID ����������", round(avg(return_date::date-rental_date::date) , 2) "������� ���������� ���� ������"
from rental r 
group by (r.customer_id)
order by (r.customer_id)

--����� �� ����� ������ � ������ ����������� ������ � ������ ����������� :D 
--explain analyze--732
/*select customer_id, round(((
date_part('days', avg(age(return_date,rental_date)))+
date_part('hours', avg(age(return_date,rental_date)))/24+
date_part('minutes', avg(age(return_date,rental_date)))/1440+
date_part('second', avg(age(return_date,rental_date)))/86400)+
date_part('millisecond', avg(age(return_date,rental_date)))/86400000)::numeric(10,2), 2)
from rental r 
group by (r.customer_id)
order by (r.customer_id)*/

--����� � ���� ���������. ����� �����
--explain analyze--467 
/*select customer_id, avg(age(return_date,rental_date))
from rental r 
group by (r.customer_id)
order by (r.customer_id)*/

--�� �����
/*select customer_id, return_date::date, rental_date::date
from rental r 
group by (r.customer_id, return_date::date, rental_date::date)
order by (r.customer_id)*/


--select pg_typeof(rental_date) from rental --timestamp without time zone


--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.

-- 1 ������� ����� ������� �������
select f.film_id, count (i.inventory_id) from film f --1000
left join inventory i ON f.film_id = i.film_id 
group by (f.film_id)
order by (f.film_id)

--������� ����� ������� ���� ���� �� � ����� ���������� --958
select f.film_id, count (i.inventory_id) from film f 
left join inventory i ON f.film_id = i.film_id 
group by (f.film_id)
having count (i.inventory_id) >0
order by (f.film_id)

--���������� �������� ����������. ������� ����� ������� ���� ���� �� � ����� ���������� --958
/*select f.film_id, count (i.inventory_id) from film f 
join inventory i ON f.film_id = i.film_id 
group by (f.film_id)
order by (f.film_id)*/

--����� �������, �������� ������ ������� ��� ������� � ������ ����� � �����-���� ����������� �������. ��������, �����-�� ����� ���� ���� ����������� �����, �� �� ��� ���� (���������, �������� � �.�.)

--������ � ��������� ���������� ����� � ���� ���������, ���������� ����� � ��������� ������ �� �� �����
select  
	f.title "�������� ������", 
	f.rating "�������", 
	c."name" "����",
	COUNT(distinct i.inventory_id) "����� ����� ������", 
	count(distinct r.rental_id) "���������� �����", 
	f.rental_rate*count(distinct r.rental_id) "����� ��������� ������"
from film f
	full join inventory i ON f.film_id = i.film_id --�������, ��� ������� �� left join
	full join rental r on i.inventory_id = r.inventory_id
	join film_category fc on fc.film_id = f.film_id
	join category c on c.category_id = fc.category_id
group by (f.film_id, c."name")
having count (r.rental_id) >=0
order by (f.film_id)


� �������, ����������� �� ������ �� ����, � � ����������� ��������� � ������ �������� 
�������� ������-�� ��� ��� ����� �������� /*sum(p.amount),*/ 
� �� ��� ����� ��������� ������ (����� �����, ���������� �� ���������) --f.rental_rate*count(distinct r.rental_id).
��� ������ � ������ ������? �� ���� ������� ������ ����������, �� �������� ��������

select p.rental_id "lD ������", count(p.payment_id) "���������� ��������" from payment p 
group by (p.rental_id)
order by (p.rental_id) --��� ����������, ��� � ��� � ���� � ������ ������� ��������� �� ������ ���� ������

--����������� �������
select  
	f.title "�������� ������", 
	f.rating "�������", 
	c."name" "����",
	COUNT(distinct i.inventory_id) "����� ����� ������", 
	count(distinct r.rental_id) "���������� �����", 
	f.rental_rate*count(distinct r.rental_id) "����� ��������� ������",
	sum(p.amount) "����� ����� ��������" --������� ������ �������, ����� ��������������� ���������, �� �� ������� ��� �������� ��������
from film f
	full join inventory i ON f.film_id = i.film_id --�������, ��� ������� �� left join
	full join rental r on i.inventory_id = r.inventory_id
	full join film_category fc on fc.film_id = f.film_id
	full join category c on c.category_id = fc.category_id
	full join payment p on p.rental_id = r.rental_id
group by (f.film_id, c."name")
having count (r.rental_id) >=0
order by (f.film_id)

--����� ����� ������ �� ���� � ������ ��� ������ �� ������� � ������� --43
select 
	F.FILM_ID,  
	f.title, 
	i.inventory_id "ID ����� ������", 
	count(r.rental_id) "���������� �����" 
from film f
full join inventory i ON f.film_id = i.film_id 
full join rental r on i.inventory_id = r.inventory_id 
group by (f.film_id,i.inventory_id)
having count (r.rental_id) =0
order by (f.film_id, i.inventory_id)

--������� ��� ����� ������ ���� ����� � ������ 
select f.film_id, i.inventory_id , count(r.rental_id) "���������� �����" from film f
left join inventory i ON f.film_id = i.film_id 
left join ren
tal r on i.inventory_id =r.inventory_id 
group by (f.film_id,i.inventory_id)
order by (f.film_id)

--������� ������� ��� ����� --42
select i.inventory_id, count (f.film_id) "����� ������� ��� �����" from film f 
left join inventory i ON f.film_id = i.film_id 
group by (i.inventory_id)
having count (i.inventory_id) =0

--����� ������ � ��� ��� ����� 
select f.film_id, count (i.inventory_id) "����� ����� ������" from film f 
left join inventory i ON f.film_id = i.film_id 
group by (f.film_id)
having count (i.inventory_id) =0
order by (f.film_id)


--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.

select  
	f.title "�������� ������", 
	f.rating "�������", 
	c."name" "����",
	COUNT(distinct i.inventory_id) "����� ����� ������", 
	count(distinct r.rental_id) "���������� �����", 
	f.rental_rate*count(distinct r.rental_id) "����� ��������� ������",
	sum(p.amount) "����� ����� ��������" --������� ������ �������, ����� ��������������� ���������, �� �� ������� ��� �������� ��������
from film f
	full join inventory i ON f.film_id = i.film_id --�������, ��� ������� �� left join
	full join rental r on i.inventory_id = r.inventory_id
	full join film_category fc on fc.film_id = f.film_id
	full join category c on c.category_id = fc.category_id
	full join payment p on p.rental_id = r.rental_id
group by (f.film_id, c."name")
having count (r.rental_id) =0
order by (f.film_id)




--������� �3
--���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� "������".
--���� ���������� ������ ��������� 7300, �� �������� � ������� ����� "��", ����� ������ ���� �������� "���".

select staff_id "ID ����������", count(payment_id) "���������� ������",
	case 
	when count(payment_id) > 7300 then '��'
	else '���'
	end as "������"
from payment 
group by staff_id






