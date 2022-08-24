--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO "dvd-rental";

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате

/*неверное решение

select customer_id , payment_id , payment_date,  
row_number () over ()
from payment p*/

--верное решение

--explain analyse --1942
select *
from (
	select customer_id , payment_id , payment_date,
	row_number () over (order by payment_date) as "Список платежей по дате"
	from payment p) t 
where payment_id in (5,14,3,32,10)

--вариант решения с count
select * 
from (
	select customer_id , payment_id , payment_date,
	count (payment_id) over (order by payment_date ) as "Список платежей по дате"
	from payment p ) t
where payment_id in (5,14,3,32,10)

--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате

--explain analyse --1982
select * 
from (
	select customer_id , payment_id , payment_date ,
	row_number () over (partition by customer_id order by payment_date)  
	from payment p) t
where payment_id in (5,14,3,32,10)

--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей

--explain analyse --1982
select * 
from (
	select customer_id , payment_id , payment_date , amount,
	sum(amount) over (partition by customer_id order by payment_date) as "Итог"
	from payment p) t
where payment_id in (5,14,3,32,10)	
order by customer_id, "Итог"

--неверный результат
/*select * 
from (
	select customer_id , payment_id , payment_date , amount,
	sum(amount) over (partition by customer_id order by payment_date::date) as "Итог"
	from payment p) t
where payment_id in (5,14,3,32,10)	
order by customer_id, "Итог"*/



--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

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


--Общий запрос

--explain analyze --7769
select t1.customer_id , t1.payment_id, t1.payment_date, "Список платежей по дате", "Платежи каждого покупателя" ,  "Итог", "Нумерация по стоимости" 
from (
		select customer_id , payment_id , payment_date,
		row_number () over (order by payment_date) as "Список платежей по дате"
		from payment p) t1 
join (
		select customer_id , payment_id , payment_date ,
		row_number () over (partition by customer_id order by payment_date) as "Платежи каждого покупателя"   
		from payment p) t2  using (payment_id)
join (
	select customer_id , payment_id , payment_date , amount,
		sum(amount) over (partition by customer_id order by payment_date) as  "Итог"
		from payment p) t3  using (payment_id)
join (
		select customer_id , payment_id, payment_date , amount ,
		dense_rank () over (partition by customer_id order by amount desc) as "Нумерация по стоимости" 
		from payment p) t4  using (payment_id)
where t1.payment_id in (5,14,3,32,10)
--order by t1.customer_id, "Итог"

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

select customer_id, payment_id , payment_date , amount , 
lag (amount, 1, 0.0) over (partition by customer_id order by payment_date)
from payment p 
limit 5



--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

select customer_id, payment_id , payment_date , amount , 
amount - lead (amount) over (partition by customer_id order by payment_date) as difference
from payment p 
limit 5

select customer_id, payment_id , payment_date , amount , 
amount - lag (amount, -1) over (partition by customer_id order by payment_date) as difference
from payment p 
limit 5


--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

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


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.


select distinct 
staff_id, payment_date::date date,
sum(amount) over (partition by (staff_id, cast (payment_date as date)) order by payment_date::date) as "sum(amount)",
sum(sum(amount)) over (partition by staff_id order by payment_date::date) as sum
from payment
where payment_date::date between '01.08.2005' and '31.08.2005'
group by staff_id , payment_date, amount 


--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку

--explain analyse 
select *
from (
	select *, row_number () over (order by payment_date) num
	from (
		select customer_id , payment_date , amount
		from payment p
		where payment_date::date = '20.08.2005') t ) t1
where t1.num % 100 = 0


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

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
	concat (c5.first_name, ' ',c5.last_name ) "Больше фильмов", 
	concat (c6.first_name, ' ',c6.last_name ) "Больше сумма платежей", 
	concat (c7.first_name, ' ',c7.last_name ) "Самая последняя аренда"
from country c
	left join cte2 cte_1 on cte_1.country_id = c.country_id and cte_1.countf = 1
	left join cte2 cte_2 on cte_2.country_id = c.country_id and cte_2.suma = 1
	left join cte2 cte_3 on cte_3.country_id = c.country_id and cte_3.maxd = 1
	left join customer c5 on c5.customer_id = cte_1.customer_id 
	left join customer c6 on c6.customer_id = cte_2.customer_id
	left join customer c7 on c7.customer_id = cte_3.customer_id 
order by 1

