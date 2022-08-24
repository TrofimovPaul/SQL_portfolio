--=============== ������ 6. POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO "dvd-rental";

--======== �������� ����� ==============

--������� �1
--�������� SQL-������, ������� ������� ��� ���������� � ������� 
--�� ����������� ��������� "Behind the Scenes".


--#1 �������� ������, ��� ����. �������� �������� �������� "Behind the Scenes" ���������� �� �������� (ilike)
--explain analyze --72.5 
select film_id , title, special_features
from film f 
where special_features::text ilike '%Behind the Scenes%'

--������� �2
--�������� ��� 2 �������� ������ ������� � ��������� "Behind the Scenes",
--��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.

--#2 �������� ������, ��� ����. ������� "Behind the Scenes" ��������� � �����-���� ��������� ���������� ������� (any) 
--explain analyze --77.5
select film_id , title, special_features
from film f 
where 'Behind the Scenes' = any (special_features)

--#3 �������� ������, ��� ������� � ����. ��������� ������� ������� ������ �������� "Behind the Scenes" (strpos). lower ��� ����������� ������� ������ ���������� �� �������� --77.5
--explain analyze--75
select film_id , title, special_features
from (
	select film_id , title, special_features, strpos(/*lower*/("special_features"::text) ,/*lower*/('Behind the Scenes'))
	from film f ) t
where strpos != 0

--#4 �������� ������, ��� ������� �������� ����. ��������� �� ������������� ������� � ����������� ��������� "Behind the Scenes" (split_part) 
--explain analyze --80
select film_id , title, special_features
from film f
where split_part(special_features::text, 'Behind the Scenes', 1) != special_features::text


--#5 ���������� #2 �������� ������, ��� ����. ������� "Behind the Scenes" ��������� � �����-���� ��������� ���������� ������� (case). ��������� � null ������� ������ ��������, ��� ��������� �� ���������
--explain analyze --77.5
select film_id , title, special_features 
from (
	select film_id , title, special_features,
	case
		when 'Behind the Scenes' = any (special_features) then 1
	end
	from film f ) t
where "case" is not null 

--#6 
--explain analyze --80
select film_id , title, special_features 
from (
	select film_id , title, special_features,
	case
		when 'Behind the Scenes' = any (special_features) then 1
		/*else 0*/
	end
	from film f ) t
where "case" = 1


--#7 �������� ������, ��� ������� ���������� � ������� � �������� ��������� (array_position)
--explain analyze -- 67.5
select film_id , title, special_features
from film f 
where array_position (special_features, 'Behind the Scenes') is not null

--#8 �������� ������, ��� ������������ ������� (&&)
--explain analyze --67.5
select film_id , title, special_features
from film f 
where special_features && array['Behind the Scenes']


--#9 �������� ������, ����� ���������������� ������� � ��������� �������� (unnest + ilike) ���������!
--explain analyze --247.5
select film_id , title, special_features
from (
	select film_id , title, special_features, unnest (special_features)
	from film f) t
where "unnest" ilike 'Behind the Scenes'

/* ������� ����� ������� �� ���� ����������
select max(cardinality(special_features))
from film f*/ 

/* ������� ����� ������� � ��������� �����������
select max(array_length(special_features, 1))
from film f */

--������� �������� � ������
--select length('Behind the Scenes') - length(replace('Behind the Scenes', 'e', ''))


--������� �3
--��� ������� ���������� ���������� ������� �� ���� � ������ ������� 
--�� ����������� ��������� "Behind the Scenes.

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, 
--���������� � CTE. CTE ���������� ������������ ��� ������� �������.

--������� � cte
--explain analyze --158

with cte as (
	select film_id, title, special_features
	from film f 
	where special_features::text ilike '%Behind the Scenes%'
)
select customer_id, count (film_id)
from cte
join inventory i using (film_id)
join rental r using (inventory_id)
group by customer_id



--������ ������
--explain analyze --158
select customer_id, count(film_id)
from film f 
join inventory i using (film_id)
join rental using (inventory_id)
where special_features::text ilike '%Behind the Scenes%'
group by customer_id

--������� � ������� ��������
--explain analyze --159
select customer_id, sum(count(film_id)) over (partition by customer_id)
from film f 
join inventory i using (film_id)
join rental r using (inventory_id)	
where special_features::text ilike '%Behind the Scenes%'
group by (customer_id)
	
--������� �4
--��� ������� ���������� ���������� ������� �� ���� � ������ �������
-- �� ����������� ��������� "Behind the Scenes".

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1,
--���������� � ���������, ������� ���������� ������������ ��� ������� �������.

--explain analyze--158
select customer_id, count (film_id) 
from (
	select film_id, title, special_features
	from film f 
	where special_features::text ilike '%Behind the Scenes%'
) t
join inventory i using (film_id)
join rental r using (inventory_id)
group by (customer_id)



--������� �5
--�������� ����������������� ������������� � �������� �� ����������� �������
--� �������� ������ ��� ���������� ������������������ �������������


create materialized view "������ Behind the Scenes �� �����������"
as select customer_id, count (film_id) 
from (
	select film_id, title, special_features
	from film f 
	where special_features::text ilike '%Behind the Scenes%'
) t
join inventory i using (film_id)
join rental r using (inventory_id)
group by (customer_id)
with no data

select * from "������ Behind the Scenes �� �����������"

refresh materialized view "������ Behind the Scenes �� �����������"

drop materialized view "������ Behind the Scenes �� �����������"

--������� �6
--� ������� explain analyze ��������� ������ �������� ���������� ��������
-- �� ���������� ������� � �������� �� �������:

--1. ����� ���������� ��� �������� ����� SQL, ������������ ��� ���������� ��������� �������, 
--   ����� �������� � ������� ���������� �������

#1 �������� ������, ��� ����. �������� �������� �������� "Behind the Scenes" ���������� �� �������� (ilike)
explain analyze --72.5 
#2 �������� ������, ��� ����. ������� "Behind the Scenes" ��������� � �����-���� ��������� ���������� ������� (any) 
explain analyze --77.5
#3 �������� ������, ��� ������� � ����. ��������� ������� ������� ������ �������� "Behind the Scenes" (strpos). lower ��� ����������� ������� ������ ���������� �� �������� --77.5
explain analyze--75
#4 �������� ������, ��� ������� �������� ����. ��������� �� ������������� ������� � ����������� ��������� "Behind the Scenes" (split_part) 
explain analyze --80
#5 ���������� #2 �������� ������, ��� ����. ������� "Behind the Scenes" ��������� � �����-���� ��������� ���������� ������� (case). ��������� � null ������� ������ ��������, ��� ��������� �� ���������
explain analyze --77.5
#7 �������� ������, ��� ������� ���������� � ������� � �������� ��������� (array_position)
explain analyze -- 67.5
#8 �������� ������, ��� ������������ ������� (&&)
explain analyze --67.5
#9 �������� ������, ����� ���������������� ������� � ��������� �������� (unnest + ilike) ���������!
explain analyze --247.5

����� ������� ����� ���������, ��� ����� ����� �������� ������� ��� ������ � ��������� && � array_position  
��������� �������� � null �������� ������ ��������, ��� ��������� � ����������� ���������� 
����������� ��������� �������� ��� ��������� �������
ilike �������� ����� ��������� ��������� �������, �� ������ ��� ������� ��� ������ � ��������� 
unnest �������� �������� ������, �� ������� ��� ���������, ���� ������ � ��� � ���������

--2. ����� ������� ���������� �������� �������: 
--   � �������������� CTE ��� � �������������� ����������
� ��� ������ cte �������� ��������� � �����������, ���, � ��������, �������. ��������, �������� ����� ����� ��������� ��� ���������� ������� ��������




--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� � ����� ������ �� ����� ���������

--explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc


Unique  (cost=1090.36..1090.40 rows=5 width=44) (actual time=40.601..41.414 rows=600 loops=1)
  ->  Sort  (cost=1090.36..1090.38 rows=5 width=44) (actual time=40.600..40.844 rows=8632 loops=1)
        Sort Key: (count(r.inventory_id) OVER (?)) DESC, ((((cu.first_name)::text || ' '::text) || (cu.last_name)::text))
        Sort Method: quicksort  Memory: 1058kB
���������� ��� ������ distinct
        ->  WindowAgg  (cost=1090.19..1090.30 rows=5 width=44) (actual time=29.100..32.229 rows=8632 loops=1)
������������� ������� �������
������ � distinct �� ����� ���������
              ->  Sort  (cost=1090.19..1090.20 rows=5 width=21) (actual time=29.086..29.510 rows=8632 loops=1)
                    Sort Key: cu.customer_id
                    Sort Method: quicksort  Memory: 1057kB
���������� / ���� ����������. ��������� ����� �� ��������, ��������� � ����� ����������.
������������ ����� � ������
                    ->  Nested Loop Left Join  (cost=82.09..1090.13 rows=5 width=21) (actual time=0.368..27.185 rows=8632 loops=1)
                          ->  Nested Loop Left Join  (cost=81.82..1088.66 rows=5 width=6) (actual time=0.363..18.551 rows=8632 loops=1)
��������� ���� . ��������� ��� �������, 
                                ->  Subquery Scan on inv  (cost=77.50..996.42 rows=5 width=4) (actual time=0.326..4.340 rows=2494 loops=1)
������������ ����������. ������������ ���������
������������� � full join �������
                                      Filter: (inv.sf_string ~~ '%Behind the Scenes%'::text)
                                      Rows Removed by Filter: 7274
���������� �� �������
                                      ->  ProjectSet  (cost=77.50..423.80 rows=45810 width=712) (actual time=0.324..3.585 rows=9768 loops=1)
������ ������� unnest.���� ������, ������� ������������ �� �������.
���� �� ����� ����.
                                            ->  Hash Full Join  (cost=77.50..160.39 rows=4581 width=63) (actual time=0.321..1.450 rows=4623 loops=1)
������� �����-���������
                                                  Hash Cond: (i.film_id = f.film_id)
�� ��������� ������� ��������� � ���, ��������� � �������� �������
                                                  ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.006..0.267 rows=4581 loops=1)
������������ ������� ���������
                                                  ->  Hash  (cost=65.00..65.00 rows=1000 width=63) (actual time=0.311..0.312 rows=1000 loops=1)
������ � ���
                                                        Buckets: 1024  Batches: 1  Memory Usage: 104kB
���������� ���������� ������ �� ������ �����
                                                        ->  Seq Scan on film f  (cost=0.00..65.00 rows=1000 width=63) (actual time=0.007..0.207 rows=1000 loops=1)
������������ ������� � ��������
                                ->  Bitmap Heap Scan on rental r  (cost=4.32..18.41 rows=4 width=6) (actual time=0.002..0.003 rows=3 loops=2494)
                                      Recheck Cond: (inventory_id = inv.inventory_id)
��������� �������� ���������
                                      Heap Blocks: exact=8602
������������ ������ �� ������� ����� 
���������� ������ 
                                      ->  Bitmap Index Scan on idx_fk_inventory_id  (cost=0.00..4.32 rows=4 width=0) (actual time=0.001..0.001 rows=3 loops=2494)
                                            Index Cond: (inventory_id = inv.inventory_id)
������������ ������� �� ������� �����
                          ->  Index Scan using customer_pkey on customer cu  (cost=0.28..0.30 rows=1 width=17) (actual time=0.001..0.001 rows=1 loops=8632)
                                Index Cond: (customer_id = r.customer_id)
������������ �������
Planning Time: 0.675 ms
����������� �����
Execution Time: 41.652 ms
����������� �����

�� ��������� � ����� ��������� ��� ������ ������ ������, ������� ����������� 40+ �� ������ 10 �� �� ���� ��������. � ��������� ����� ������� ���� ����� � 7 ���

select 1090/158.--6.899


--������� �2
--��������� ������� ������� �������� ��� ������� ����������
--�������� � ����� ������ ������� ����� ����������.
--explain analyze 

with cte as(
select 	p.staff_id,	film_id,title,first_name, last_name  ,amount, payment_date , 
	row_number () over (partition by p.staff_id order by payment_date) as one
from payment p
	join customer c using (customer_id)
	join rental r using (rental_id)
	join inventory i using (inventory_id)
	join film f using (film_id)
)
select 	staff_id,film_id,title,first_name, last_name  ,amount, payment_date 
from cte
where one = 1


--������� �3
--��� ������� �������� ���������� � �������� ����� SQL-�������� ��������� ������������� ����������:
-- 1. ����, � ������� ���������� ������ ����� ������� (���� � ������� ���-�����-����)
-- 2. ���������� ������� ������ � ������ � ���� ����
-- 3. ����, � ������� ������� ������� �� ���������� ����� (���� � ������� ���-�����-����)
-- 4. ����� ������� � ���� ����

select "ID ��������", "���� ������� ������", "���-�� ������������ �������", "���� ����������� �������", "�������"
from (
	select i.store_id "ID ��������", r.rental_date::date "���� ������� ������", count(i.film_id) "���-�� ������������ �������", 
		row_number() over (partition by i.store_id order by count(i.film_id) desc) rowcount 
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	group by i.store_id, r.rental_date::date) t1
join (
	select s.store_id, p.payment_date::date "���� ����������� �������", sum(p.amount) "�������", 
		row_number() over (partition by s.store_id order by sum(p.amount)) rowsum
	from payment p 
	join staff s on s.staff_id = p.staff_id
	group by s.store_id, p.payment_date::date) t2 on "ID ��������" = t2.store_id
where rowcount = 1 and rowsum = 1

