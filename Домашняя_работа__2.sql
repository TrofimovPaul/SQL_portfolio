--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
--SET search_path TO "public";
SET search_path TO "dvd-rental";-- в моём случае схема переименована в "dvd-rental"

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.
select distinct city as unique_city_name from city

--select count(city) from city --600

--select count (distinct city) "distinct" from city --599

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
select city as "city_name_L%a" from city
where city like 'L%a' and city not like 'L% %a'

--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.


--select * from payment p --выберем id, стоимость и дату платежа

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



--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.
select payment_id, payment_date, amount 
from payment
order by payment_date desc 
limit 10

--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.
select 
	concat(LAst_name, ' ', FIRst_name) as "Данные покупателя",
	email as "Почтовый адрес",
	length (email) "Длина почтового адреса",
	cast (last_update as date) "Дата обновления" 
from customer;

select 
	concat(last_name, ' ', FIRst_name) as "Данные покупателя",
	email as "Почтовый адрес",
	--character_length(email), --или
	length (email) "Длина почтового адреса",
	cast (last_update as date) --почему без псевдонима сохраняется тип timestamp?
from customer;


--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.

select  lower (last_name) last_name, lower (first_name) first_name, active
from customer
where (first_name = 'KELLY' or first_name = 'WILLIE') and active = 1


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.
select film_id , title, description , rating, rental_rate 
from film
	where 
	(rating::text = 'R' and rental_rate between 0 and 3)
	or
	(rating::text ilike 'PG-13' and rental_rate >=4)



--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

select film_id , title, description , length (description) as "Длина описания"
from film
order by character_length(description) desc
limit 3

/*select max(description) попытка найти через максимум выдаёт неверное значение "A Unbelieveable Yarn of a Student And a Database Administrator who must Outgun a Husband in An Abandoned Mine Shaft"
from film f 

select film_id, title
from film f 
where description = 'A Unbelieveable Yarn of a Student And a Database Administrator who must Outgun a Husband in An Abandoned Mine Shaft'*/

--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.
--explain analyze 18
select split_part(email, '@', 1) "before @", 
split_part(email, '@', 2) "after @"
from customer 

--explain analyze 26
select 
left(email, strpos(email, '@')-1) "Before @",
right(email, length(email)-strpos(email, '@')) "After @"
from customer 




--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.

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


