--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO "dvd-rental";--в моём случае база dvd-rental 

SET search_path TO "public";

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select concat(c.last_name, ' ', c.first_name), a.address, city.city, cn.country 
from customer c
join address a on c.address_id=a.address_id 
join city on a.city_id=city.city_id 
join country cn on city.country_id=cn.country_id

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select  store_id "ID магазина", count(customer) "Количество покупателей" from customer 
group by (store_id)




--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select  store_id "ID магазина", count(customer) "Количество покупателей" from customer 
group by (store_id)
having count(customer)>300




-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select  
	c.store_id "ID магазина", 
	count(c.customer_id)  "Количество покупателей" ,  
	city.city "Название города", 
	concat(s.last_name, ' ', s.first_name) "Данные сотрудника" 
from customer c
	join store str on str.store_id =c.store_id 
	join address a on str.address_id=a.address_id 
	join city on a.city_id=city.city_id 
	join staff s on s.staff_id = str.manager_staff_id 
group by (c.store_id, city.city, s.last_name, s.first_name)
having count(c.customer_id)>300

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

/*select concat (c.last_name, ' ', c.first_name), count(r.rental_id) from rental r
join customer c on r.customer_id =c.customer_id 
group by (c.customer_id)
order by (count(r.rental_id)) desc
limit 5*/

/*select concat (c.last_name, ' ', c.first_name) "Данные покупателя", count(r.rental_id) "Количество фильмов" from rental r
join customer c on r.customer_id =c.customer_id 
group by (c.customer_id)
order by ("Количество фильмов") desc
limit 5*/

select concat (c.last_name, ' ', c.first_name) "Данные покупателя", count(r.rental_id) "Количество фильмов" from rental r
join customer c on r.customer_id =c.customer_id 
group by (c.customer_id)
order by (2) desc
limit 5



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

--для всех покупателей
--explain analyze --1388
select
	concat (c.last_name, ' ', c.first_name) "Данные покупателя",
	count(r.rental_id) "Количество фильмов",
	round(sum(p.amount)),
	MIN (p.amount),
	max (p.amount) "Max"
from rental r
	join customer c on r.customer_id =c.customer_id 
	join inventory i on r.inventory_id =i.inventory_id 
	join film f on f.film_id =i.film_id
	join payment p on p.rental_id = r.rental_id 
	group by (c.customer_id)

--проверка по значениям со скриншота
--explain analyze --902
select
	concat (c.last_name, ' ', c.first_name) "Данные покупателя",
	count(r.rental_id) "Количество фильмов",
	round(sum(p.amount)) "Общая сумма платежа",
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
	concat (c.last_name, ' ', c.first_name) "Данные покупателя",
	count(r.rental_id) "Количество фильмов",
	round(sum(p.amount)) "Общая сумма платежа",
	MIN (p.amount) "Min,
	max (p.amount) "Max"
from rental r
	join customer c on r.customer_id =c.customer_id 
	join inventory i on r.inventory_id =i.inventory_id 
	join film f on f.film_id =i.film_id
	join payment p on p.rental_id = r.rental_id 
group by (c.customer_id)
having c.last_name in (upper('collazo'),upper('crouse'),upper('wiles'),upper('tubbs'),upper( 'watson'))*/ --так тоже работает

--in ilike несовместимы :(


--безумный запрос для проверки по значениям. просто для анализа
--explain analyze --3740
select
	concat (c.last_name, ' ', c.first_name) "Данные покупателя",
	count(r.rental_id) "Количество фильмов",
	round(sum(p.amount)) "Общая сумма платежа",
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
		concat (c.last_name, ' ', c.first_name) "Данные покупателя",
		count(r.rental_id) "Количество фильмов",
		round(sum(p.amount)) "Общая сумма платежа",
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
			concat (c.last_name, ' ', c.first_name) "Данные покупателя",
			count(r.rental_id) "Количество фильмов",
			round(sum(p.amount)) "Общая сумма платежа",
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
				concat (c.last_name, ' ', c.first_name) "Данные покупателя",
				count(r.rental_id) "Количество фильмов",
				round(sum(p.amount)) "Общая сумма платежа",
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
					concat (c.last_name, ' ', c.first_name) "Данные покупателя",
					count(r.rental_id) "Количество фильмов",
					round(sum(p.amount)) "Общая сумма платежа",
					MIN (p.amount),
					max (p.amount) "Max"
				from rental r
					join customer c on r.customer_id =c.customer_id 
					join inventory i on r.inventory_id =i.inventory_id 
					join film f on f.film_id =i.film_id
					join payment p on p.rental_id = r.rental_id 
				where c.last_name ilike 'watson'
					group by (c.customer_id)





--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.

				
select c1.city, c2.city from city c1 -- число строк без повторов 359398
cross join city c2
where c1.city not in (c2.city) 

 /*select c1.city, c2.city from city c1 --общее число строк 360000
 cross join city c2*/
 
 --360000-359398=602
 
 /*select c1.city, c2.city from city c1 --602 записи при объединении inner join
join city c2 on c1.city = c2.city*/
 
 /*select city,count(city) from city --2 записи London повторяются в таблице БД
group by (city)
having count(city)>1*/
 
 /*select c1.city, c2.city from city c1 --4 записи London при объединении cross join
 cross join city c2
 where c1.city ilike 'london' and c1.city=c2.city*/

/*select city, 
city_id from city where city='London'*/ --2 id для одного города

/*select city from city --600*/

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.

--explain analyze-- 549
select customer_id "ID покупателя", round(avg(return_date::date-rental_date::date) , 2) "Среднее количество дней аренды"
from rental r 
group by (r.customer_id)
order by (r.customer_id)

--вроде бы более точный и оттого бесполезный расчёт с учётом миллисекунд :D 
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

--вывод в виде интервала. пусть будет
--explain analyze--467 
/*select customer_id, avg(age(return_date,rental_date))
from rental r 
group by (r.customer_id)
order by (r.customer_id)*/

--не нужно
/*select customer_id, return_date::date, rental_date::date
from rental r 
group by (r.customer_id, return_date::date, rental_date::date)
order by (r.customer_id)*/


--select pg_typeof(rental_date) from rental --timestamp without time zone


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

-- 1 сколько всего фильмов имеется
select f.film_id, count (i.inventory_id) from film f --1000
left join inventory i ON f.film_id = i.film_id 
group by (f.film_id)
order by (f.film_id)

--сколько всего фильмов есть хотя бы в одном экземпляре --958
select f.film_id, count (i.inventory_id) from film f 
left join inventory i ON f.film_id = i.film_id 
group by (f.film_id)
having count (i.inventory_id) >0
order by (f.film_id)

--аналогично верхнему результату. сколько всего фильмов есть хотя бы в одном экземпляре --958
/*select f.film_id, count (i.inventory_id) from film f 
join inventory i ON f.film_id = i.film_id 
group by (f.film_id)
order by (f.film_id)*/

--таким образом, остается понять сколько раз сдавали в аренду фильм с каким-либо инвентарным номером. Возможно, какой-то фильм имел свой инвентарный номер, но не был взят (потерялся, сломался и т.п.)

--фильмы с указанием количества копий в двух магазинах, количества аренд и стоимости аренды за всё время
select  
	f.title "Название фильма", 
	f.rating "Рейтинг", 
	c."name" "Жанр",
	COUNT(distinct i.inventory_id) "Число копий фильма", 
	count(distinct r.rental_id) "Количество аренд", 
	f.rental_rate*count(distinct r.rental_id) "Общая стоимость аренды"
from film f
	full join inventory i ON f.film_id = i.film_id --понимаю, что хватило бы left join
	full join rental r on i.inventory_id = r.inventory_id
	join film_category fc on fc.film_id = f.film_id
	join category c on c.category_id = fc.category_id
group by (f.film_id, c."name")
having count (r.rental_id) >=0
order by (f.film_id)


В примере, разобранном на лекции по зуму, и в приложенном скриншоте в личном кабинете 
разговор почему-то идёт про сумму платежей /*sum(p.amount),*/ 
а не про общую стоимость аренды (число аренд, умноженное на стоимость) --f.rental_rate*count(distinct r.rental_id).
Что делать в данном случае? То есть условие задачи простейшее, но написано ошибочно

select p.rental_id "lD аренды", count(p.payment_id) "Количество платежей" from payment p 
group by (p.rental_id)
order by (p.rental_id) --это показывает, что у нас в базе к одному платежу относится не всегда одна аренда

--подогнанный вариант
select  
	f.title "Название фильма", 
	f.rating "Рейтинг", 
	c."name" "Жанр",
	COUNT(distinct i.inventory_id) "Число копий фильма", 
	count(distinct r.rental_id) "Количество аренд", 
	f.rental_rate*count(distinct r.rental_id) "Общая стоимость аренды",
	sum(p.amount) "Общая сумма платежей" --добавил данный столбец, чтобы соответствовало скриншоту, но по условию это неверный параметр
from film f
	full join inventory i ON f.film_id = i.film_id --понимаю, что хватило бы left join
	full join rental r on i.inventory_id = r.inventory_id
	full join film_category fc on fc.film_id = f.film_id
	full join category c on c.category_id = fc.category_id
	full join payment p on p.rental_id = r.rental_id
group by (f.film_id, c."name")
having count (r.rental_id) >=0
order by (f.film_id)

--какие копии фильма не были в аренде или вообще не имеются в наличии --43
select 
	F.FILM_ID,  
	f.title, 
	i.inventory_id "ID копии фильма", 
	count(r.rental_id) "Количество аренд" 
from film f
full join inventory i ON f.film_id = i.film_id 
full join rental r on i.inventory_id = r.inventory_id 
group by (f.film_id,i.inventory_id)
having count (r.rental_id) =0
order by (f.film_id, i.inventory_id)

--сколько раз копия фильма была сдана в аренду 
select f.film_id, i.inventory_id , count(r.rental_id) "Количество аренд" from film f
left join inventory i ON f.film_id = i.film_id 
left join ren
tal r on i.inventory_id =r.inventory_id 
group by (f.film_id,i.inventory_id)
order by (f.film_id)

--сколько фильмов без копии --42
select i.inventory_id, count (f.film_id) "Число фильмов без копии" from film f 
left join inventory i ON f.film_id = i.film_id 
group by (i.inventory_id)
having count (i.inventory_id) =0

--какие фильмы у нас без копий 
select f.film_id, count (i.inventory_id) "Число копий фильма" from film f 
left join inventory i ON f.film_id = i.film_id 
group by (f.film_id)
having count (i.inventory_id) =0
order by (f.film_id)


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select  
	f.title "Название фильма", 
	f.rating "Рейтинг", 
	c."name" "Жанр",
	COUNT(distinct i.inventory_id) "Число копий фильма", 
	count(distinct r.rental_id) "Количество аренд", 
	f.rental_rate*count(distinct r.rental_id) "Общая стоимость аренды",
	sum(p.amount) "Общая сумма платежей" --добавил данный столбец, чтобы соответствовало скриншоту, но по условию это неверный параметр
from film f
	full join inventory i ON f.film_id = i.film_id --понимаю, что хватило бы left join
	full join rental r on i.inventory_id = r.inventory_id
	full join film_category fc on fc.film_id = f.film_id
	full join category c on c.category_id = fc.category_id
	full join payment p on p.rental_id = r.rental_id
group by (f.film_id, c."name")
having count (r.rental_id) =0
order by (f.film_id)




--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

select staff_id "ID сотрудника", count(payment_id) "Количество продаж",
	case 
	when count(payment_id) > 7300 then 'Да'
	else 'Нет'
	end as "Премия"
from payment 
group by staff_id






