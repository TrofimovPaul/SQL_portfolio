--=============== ������ 2. ������ � ������ ������ =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
--SET search_path TO "public";
SET search_path TO "dvd-rental";-- � ��� ������ ����� ������������� � "dvd-rental"

--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� ������� �� ������� �������.
select distinct city as unique_city_name from city

--select count(city) from city --600

--select count (distinct city) "distinct" from city --599

--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� ������,
--�������� ������� ���������� �� �L� � ������������� �� �a�, � �������� �� �������� ��������.
select city as "city_name_L%a" from city
where city like 'L%a' and city not like 'L% %a'

--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ���� 2005 ���� �� 19 ���� 2005 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.


--select * from payment p --������� id, ��������� � ���� �������

--select pg_typeof(payment_date) from payment --timestamp without time zone

--explain analyze --482
select payment_id, payment_date, amount from payment
where amount>1 and payment_date::date >= '17.06.2005' and payment_date::date <='19.06.2005'
order by payment_date 

--explain analyze --482
select payment_id, payment_date, amount
from payment 
where amount > 1 and payment_date::date between '17.06.2005' and '19.06.2005'
order by payment_date



--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.
select payment_id, payment_date, amount 
from payment
order by payment_date desc 
limit 10

--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.
select 
	concat(LAst_name, ' ', FIRst_name) as "������ ����������",
	email as "�������� �����",
	length (email) "����� ��������� ������",
	cast (last_update as date) "���� ����������" 
from customer;

select 
	concat(last_name, ' ', FIRst_name) as "������ ����������",
	email as "�������� �����",
	--character_length(email), --���
	length (email) "����� ��������� ������",
	cast (last_update as date) --������ ��� ���������� ����������� ��� timestamp?
from customer;


--������� �6
--�������� ����� �������� ������ �������� �����������, ����� ������� KELLY ��� WILLIE.
--��� ����� � ������� � ����� �� �������� �������� ������ ���� ���������� � ������ �������.

select  lower (last_name) last_name, lower (first_name) first_name, active
from customer
where (first_name = 'KELLY' or first_name = 'WILLIE') and active = 1


--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.
select film_id , title, description , rating, rental_rate 
from film
	where 
	(rating::text = 'R' and rental_rate between 0 and 3)
	or
	(rating::text ilike 'PG-13' and rental_rate >=4)



--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.

select film_id , title, description , length (description) as "����� ��������"
from film
order by character_length(description) desc
limit 3

/*select max(description) ������� ����� ����� �������� ����� �������� �������� "A Unbelieveable Yarn of a Student And a Database Administrator who must Outgun a Husband in An Abandoned Mine Shaft"
from film f 

select film_id, title
from film f 
where description = 'A Unbelieveable Yarn of a Student And a Database Administrator who must Outgun a Husband in An Abandoned Mine Shaft'*/

--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.
--explain analyze 18
select split_part(email, '@', 1) "before @", 
split_part(email, '@', 2) "after @"
from customer 

--explain analyze 26
select 
left(email, strpos(email, '@')-1) "Before @",
right(email, length(email)-strpos(email, '@')) "After @"
from customer 




--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.

--explain analyze 32
select 
	concat(
		left(email, 1), 
		lower(right(split_part(email, '@', 1), -1))
		) "Before @", 
	concat(
		upper(left(split_part(email, '@', 2), 1)),
		right(split_part(email, '@', 2), -1)
		) "After @"
from customer 

--explain analyze 42 
select 
concat(
	upper(left(email, 1)), 
	lower(substring(left(email, strpos(email, '@')-1),2))) "Before @",
concat(
	upper(left(substring(email, strpos(email, '@')+1),1)),
	lower(substring(email, strpos(email, '@')+2)))
from customer 


