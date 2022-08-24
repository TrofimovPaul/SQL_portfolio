--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO "dvd-rental";

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".


--#1 выбираем строки, где спец. атрибуты включают значение "Behind the Scenes" независимо от регистра (ilike)
--explain analyze --72.5 
select film_id , title, special_features
from film f 
where special_features::text ilike '%Behind the Scenes%'

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

--#2 выбираем строки, где спец. атрибут "Behind the Scenes" совпадает с каким-либо элементом текстового массива (any) 
--explain analyze --77.5
select film_id , title, special_features
from film f 
where 'Behind the Scenes' = any (special_features)

--#3 выбираем строки, для которых в спец. атрибутах найдена позиция начала значения "Behind the Scenes" (strpos). lower даёт возможность вывести строки независимо от регистра --77.5
--explain analyze--75
select film_id , title, special_features
from (
	select film_id , title, special_features, strpos(/*lower*/("special_features"::text) ,/*lower*/('Behind the Scenes'))
	from film f ) t
where strpos != 0

--#4 выбираем строки, для которых значения спец. атрибутов не соответствуют колонке с выброшенным значением "Behind the Scenes" (split_part) 
--explain analyze --80
select film_id , title, special_features
from film f
where split_part(special_features::text, 'Behind the Scenes', 1) != special_features::text


--#5 аналогично #2 выбираем строки, где спец. атрибут "Behind the Scenes" совпадает с каким-либо элементом текстового массива (case). сравнение с null требует меньше ресурсов, чем сравнение со значением
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


--#7 выбираем строки, где найдено совпадение в массиве с заданным значением (array_position)
--explain analyze -- 67.5
select film_id , title, special_features
from film f 
where array_position (special_features, 'Behind the Scenes') is not null

--#8 выбираем строки, где пересекаются массивы (&&)
--explain analyze --67.5
select film_id , title, special_features
from film f 
where special_features && array['Behind the Scenes']


--#9 выбираем строки, после транспонирования массива и сравнения значений (unnest + ilike) ЧРЕЗМЕРНО!
--explain analyze --247.5
select film_id , title, special_features
from (
	select film_id , title, special_features, unnest (special_features)
	from film f) t
where "unnest" ilike 'Behind the Scenes'

/* считаем длину массива по всем измерениям
select max(cardinality(special_features))
from film f*/ 

/* считаем длину массива в указанной размерности
select max(array_length(special_features, 1))
from film f */

--подсчёт символов в строке
--select length('Behind the Scenes') - length(replace('Behind the Scenes', 'e', ''))


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

--вариант с cte
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



--прямой запрос
--explain analyze --158
select customer_id, count(film_id)
from film f 
join inventory i using (film_id)
join rental using (inventory_id)
where special_features::text ilike '%Behind the Scenes%'
group by customer_id

--вариант с оконной функцией
--explain analyze --159
select customer_id, sum(count(film_id)) over (partition by customer_id)
from film f 
join inventory i using (film_id)
join rental r using (inventory_id)	
where special_features::text ilike '%Behind the Scenes%'
group by (customer_id)
	
--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

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



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления


create materialized view "Фильмы Behind the Scenes по покупателям"
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

select * from "Фильмы Behind the Scenes по покупателям"

refresh materialized view "Фильмы Behind the Scenes по покупателям"

drop materialized view "Фильмы Behind the Scenes по покупателям"

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее

#1 выбираем строки, где спец. атрибуты включают значение "Behind the Scenes" независимо от регистра (ilike)
explain analyze --72.5 
#2 выбираем строки, где спец. атрибут "Behind the Scenes" совпадает с каким-либо элементом текстового массива (any) 
explain analyze --77.5
#3 выбираем строки, для которых в спец. атрибутах найдена позиция начала значения "Behind the Scenes" (strpos). lower даёт возможность вывести строки независимо от регистра --77.5
explain analyze--75
#4 выбираем строки, для которых значения спец. атрибутов не соответствуют колонке с выброшенным значением "Behind the Scenes" (split_part) 
explain analyze --80
#5 аналогично #2 выбираем строки, где спец. атрибут "Behind the Scenes" совпадает с каким-либо элементом текстового массива (case). сравнение с null требует меньше ресурсов, чем сравнение со значением
explain analyze --77.5
#7 выбираем строки, где найдено совпадение в массиве с заданным значением (array_position)
explain analyze -- 67.5
#8 выбираем строки, где пересекаются массивы (&&)
explain analyze --67.5
#9 выбираем строки, после транспонирования массива и сравнения значений (unnest + ilike) ЧРЕЗМЕРНО!
explain analyze --247.5

таким образом можно заключить, что лучше всего работают функции для работы с массивами && и array_position  
сравнение значений с null занимает меньше ресурсов, чем сравнение с конкретными значениями 
практически идентично работают все строковые функции
ilike работает лучше остальных строковых функций, но похуже чем функции для работы с массивами 
unnest очевидно работает дольше, но приведён для сравнения, хотя запись с ним и чрезмерна

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
В моём случае cte работало одинаково с подзапросом, что, в принципе, логично. Вероятно, различие можно будет наблюдать при выполнении больших запросов




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

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
Сортировка при работе distinct
        ->  WindowAgg  (cost=1090.19..1090.30 rows=5 width=44) (actual time=29.100..32.229 rows=8632 loops=1)
Использование оконных функций
вместе с distinct не особо требуется
              ->  Sort  (cost=1090.19..1090.20 rows=5 width=21) (actual time=29.086..29.510 rows=8632 loops=1)
                    Sort Key: cu.customer_id
                    Sort Method: quicksort  Memory: 1057kB
Сортировка / ключ сортировки. Сортирует набор по столбцам, указанным в ключе сортировки.
Используемое место в памяти
                    ->  Nested Loop Left Join  (cost=82.09..1090.13 rows=5 width=21) (actual time=0.368..27.185 rows=8632 loops=1)
                          ->  Nested Loop Left Join  (cost=81.82..1088.66 rows=5 width=6) (actual time=0.363..18.551 rows=8632 loops=1)
Вложенный цикл . Соединяет две таблицы, 
                                ->  Subquery Scan on inv  (cost=77.50..996.42 rows=5 width=4) (actual time=0.326..4.340 rows=2494 loops=1)
Сканирование подзапроса. Раскрывается подзапрос
Использование с full join излишне
                                      Filter: (inv.sf_string ~~ '%Behind the Scenes%'::text)
                                      Rows Removed by Filter: 7274
Фильтрация по условию
                                      ->  ProjectSet  (cost=77.50..423.80 rows=45810 width=712) (actual time=0.324..3.585 rows=9768 loops=1)
Работа функции unnest.есть данные, которые размножаются по строкам.
Одно из узких мест.
                                            ->  Hash Full Join  (cost=77.50..160.39 rows=4581 width=63) (actual time=0.321..1.450 rows=4623 loops=1)
Таблица фильм-инвентарь
                                                  Hash Cond: (i.film_id = f.film_id)
Не записывая таблицу инвентаря в хэш, соединяет с таблицей фильмов
                                                  ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.006..0.267 rows=4581 loops=1)
Сканирование таблицы инвентаря
                                                  ->  Hash  (cost=65.00..65.00 rows=1000 width=63) (actual time=0.311..0.312 rows=1000 loops=1)
Запись в хэш
                                                        Buckets: 1024  Batches: 1  Memory Usage: 104kB
Количество выделенной памяти на жёстком диске
                                                        ->  Seq Scan on film f  (cost=0.00..65.00 rows=1000 width=63) (actual time=0.007..0.207 rows=1000 loops=1)
Сканирование таблицы с фильмами
                                ->  Bitmap Heap Scan on rental r  (cost=4.32..18.41 rows=4 width=6) (actual time=0.002..0.003 rows=3 loops=2494)
                                      Recheck Cond: (inventory_id = inv.inventory_id)
Повторная проверка состояния
                                      Heap Blocks: exact=8602
Сканирование блоков по битовой карте 
Количество блоков 
                                      ->  Bitmap Index Scan on idx_fk_inventory_id  (cost=0.00..4.32 rows=4 width=0) (actual time=0.001..0.001 rows=3 loops=2494)
                                            Index Cond: (inventory_id = inv.inventory_id)
Сканирование индекса по битовой карте
                          ->  Index Scan using customer_pkey on customer cu  (cost=0.28..0.30 rows=1 width=17) (actual time=0.001..0.001 rows=1 loops=8632)
                                Index Cond: (customer_id = r.customer_id)
Сканирование индекса
Planning Time: 0.675 ms
Планируемое время
Execution Time: 41.652 ms
Затраченное время

по сравнению с моими запросами это весьма тяжёлый запрос, который выполняется 40+ мс против 10 мс на моих запросах. И стоимость этого запроса выше почти в 7 раз

select 1090/158.--6.899


--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
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


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

select "ID Магазина", "День больших продаж", "Кол-во арендованных фильмов", "День минимальной выручки", "Выручка"
from (
	select i.store_id "ID Магазина", r.rental_date::date "День больших продаж", count(i.film_id) "Кол-во арендованных фильмов", 
		row_number() over (partition by i.store_id order by count(i.film_id) desc) rowcount 
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	group by i.store_id, r.rental_date::date) t1
join (
	select s.store_id, p.payment_date::date "День минимальной выручки", sum(p.amount) "Выручка", 
		row_number() over (partition by s.store_id order by sum(p.amount)) rowsum
	from payment p 
	join staff s on s.staff_id = p.staff_id
	group by s.store_id, p.payment_date::date) t2 on "ID Магазина" = t2.store_id
where rowcount = 1 and rowsum = 1

