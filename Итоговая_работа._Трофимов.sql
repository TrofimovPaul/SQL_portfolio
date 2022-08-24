- - -ИТОГОВАЯ РАБОТА- - -


№1 В КАКИХ ГОРОДАХ БОЛЬШЕ ОДНОГО АЭРОПОРТА?

--explain analyze --5.08
select a.city "Название города" --,count(a.airport_code) "Количество аэропортов"
from airports a 
group by a.city
having count(a.airport_code) > 1

/*--если необходимо получить больше информации, то можно создать подзапрос
--explain analyze --8.91
select a.airport_code "Код аэропорта",
	a.airport_name "Название аэропорта",
	a.city "Название города",
	a.longitude "Долгота",
	a.latitude "Широта",
	a.timezone "Временная зона"
from airports a
join (
	select a.city 
	from airports a 
	group by a.city
	having count(a.airport_code) > 1) t1 using (city)
	
*/

/*--также можно было выполнить запрос из описания БД
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

№2 В КАКИХ АЭРОПОРТАХ ЕСТЬ РЕЙСЫ, ВЫПОЛНЯЕМЫЕ САМОЛЕТОМ С МАКСИМАЛЬНОЙ ДАЛЬНОСТЬЮ ПЕРЕЛЕТА?
- ПОДЗАПРОС

--Можно предположить, что не все самолёты совершают перелёт из города в город в двух направлениях, 
--вдруг, есть аэропорты, куда самолёты только прилетают или откуда только вылетают.
--Это предположение можно проверить, объединив результаты по аэропортам вылета и прилёта с помощью UNION (UNION ALL) см. вариант #3
--Также предположим, что самолётов в нашем списке не 9, а в разы больше. 
--Соответственно, поиск кода самолёта пользователем может занять много времени, а это значит, что необходимо применить функцию MAX или сортировку.

--#1 вариант с сортировкой по длине перелёта 
--explain analyze --836
select /*distinct*/ f.departure_airport, f.aircraft_code from 
flights f
where f.aircraft_code = (
	select aircraft_code 
	from aircrafts a
	order by "range" desc
	limit 1)	
group by f.departure_airport, f.aircraft_code

/*--#2 вариант с функцией MAX
--explain analyze --837 замена group by на distinct не меняет стоимости 
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

/*--#3 вариант с проверкой, имеются ли уникальные аэропорты
--explain analyze --1721
select f.departure_airport as "Аэропорт вылета", f.aircraft_code "Код самолёта" from 
flights f
where f.aircraft_code = (
	select aircraft_code 
	from aircrafts a
	order by "range" desc
	limit 1)	
group by f.departure_airport, f.aircraft_code
union
select f.arrival_airport as "Аэропорт прилёта", f.aircraft_code "Код самолёта" from 
flights f
where f.aircraft_code = (
	select aircraft_code 
	from aircrafts a
	order by "range" desc
	limit 1)
group by f.arrival_airport , f.aircraft_code*/

/*--Прямой выбор аэропортов с предположением, что самолёты совершают полёты в двух направлениях, код самолёта выбирается самостоятельно пользователем при анализе таблицы aircrafts
--explain analyze --819
select distinct f.departure_airport, f.aircraft_code from 
flights f
where f.aircraft_code = '773'
group by f.departure_airport, f.aircraft_code*/

№3 ВЫВЕСТИ 10 РЕЙСОВ С МАКСИМАЛЬНЫМ ВРЕМЕНЕМ ЗАДЕРЖКИ ВЫЛЕТА
- ОПЕРАТОР LIMIT*/

select f.flight_id, (f.actual_departure - f.scheduled_departure) as max_delay
from flights f 
where (f.actual_departure - f.scheduled_departure) is not null /*and (f.actual_departure - f.scheduled_departure)!='00:00:00'*/
order by (f.actual_departure - f.scheduled_departure) desc
limit 10

№4 БЫЛИ ЛИ БРОНИ, ПО КОТОРЫМ НЕ БЫЛИ ПОЛУЧЕНЫ ПОСАДОЧНЫЕ ТАЛОНЫ? 
- ВЕРНЫЙ ТИП JOIN*/

select distinct t.book_ref as "Номер брони"/*, t.ticket_no as "Билеты from tickets", bp.ticket_no as "Билеты from boarding_passes" */
from tickets t 
left join boarding_passes bp using (ticket_no)
where bp.ticket_no is null --91388 количество броней, по которым не были получены посадочные талоны --127899 билеты, по которым не были получены посадочные талоны


/* 
select t.book_ref , t.ticket_no, bp.ticket_no 
from tickets t 
left join boarding_passes bp using (ticket_no) --707585 так как есть дубликаты число получается больше ожидаемого

select tf.ticket_no 
from ticket_flights tf --1045726 все возможные посадочные талоны (разбивка по flight_id)

select distinct tf.ticket_no --366733 всего уникальных билетов
from ticket_flights tf

select t.book_ref "Номер брони" --366733 все номера брони с повтором значений для разных билетов
from tickets t
order by t.book_ref 

select distinct t.book_ref "Номер брони" --262788 всего уникальных номеров брони
from tickets t

select * from boarding_passes bp --579686 получено посадочных талонов

--explain analyze
select distinct tf.ticket_no as r1, bp.ticket_no as r2 --127899 все билеты, по которым не были получены посадочные талоны
from ticket_flights tf --может быть ситуация, что по одному билету не получен всего один талон, а по другому не получены несколько талонов
left join boarding_passes bp using (ticket_no) 
where bp.ticket_no is null*/

/*запрос ниже отвечает на вопрос были ли такие рейсы, а соответственно и брони, где посадочный талон не был взят на момент создания БД (человек опоздал на регистрацию, ошибка в значениях и т.п.).
То есть, если бы на один из рейсов не был бы взят посадочный талон по какой-либо причине, 
в конечном запросе вывелись бы все рейсы, кроме этого. Добавление в условие фильтрации not null изменит ситуацию, а именно,
мы получили бы только этот рейс, на который не был взят посадочный талон, и взять этот талон уже нельзя. 
Затем по идентификатору этого рейса можно выцепить номера броней, по которым не были взяты посадочные талоны (не указано, чтобы не загромождать запрос)
В запросе принято, что регистрация на самолёт длится вплоть до времени отправления самолёта, а также, если имеется статус 'Scheduled', 'On Time' или 'Delayed'.
Но, как мы видим, (при использовании в условии not null), таких рейсов нет, что говорит нам о том, 
что на момент создания БД все улетевшие самолёты были со всеми пассажирами на борту, а отменённые вычеркнуты из списка*/

/*--Сравниваем и выводим номера рейсов, по которым не взяты посадочные талоны и по которым их взять ещё можно
select /*count (*/distinct tf.flight_id/*)*//*, sub3.s1 */--Сравниваем и выводим номера рейсов, по которым не взяты посадочные талоны и по которым их взять ещё можно
from (
	--номера билетов и брони, по которым не взяты посадочные талоны sub1
	select distinct 
		t1.book_ref as "Номер брони", 
		t1.ticket_no as tick1,
		bp.ticket_no as "Билеты from boarding_passes"
	from tickets t1 
		left join boarding_passes bp using (ticket_no)
	where bp.ticket_no is null
	) sub1
join ticket_flights tf on sub1.tick1 = tf.ticket_no
left join (--присоединяем таблицу из подзапроса sub3=(sub-t) с выводом всех значений из левой таблицы sub1
	--рейсы, которые присутствуют в таблице sub и отсутствуют в таблице t, sub3=(sub-t). По этим рейсам уже нельзя пройти регистрацию 
	select s1 
	from (
		--все рейсы, которые отменены или вылетели sub
		select fv.flight_id as s1, fv.status as st1, t.flight_id  as s2, t.status as st2 -- выбираем рейс fv, статус fv, рейс t, статус t
		from flights_v fv 
		left join (-- присоединяем таблицу из подзапроса t с выводом всех значений из левой таблицы flights_v fv
			--рейсы, которые отменены или вылетели к моменту создания БД t	
			select --  выбираем рейсы, статус, время отправления, время отправления факт, разницу между временем создания таблицы и временем отправления
				fv2.flight_id , 
				fv2.status,
				fv2.scheduled_departure, 
				fv2.actual_departure,
				bookings.now()-fv2.scheduled_departure as difference
			from flights_v fv2
			where fv2.status not in ('Scheduled', 'On Time', 'Delayed') and --2 фильтруем значения, убираем те рейсы, которые открыты для бронирования и регистрации, 
			(fv2.scheduled_departure <= bookings.now() or fv2.actual_departure <= bookings.now()) -- и те, у которых время отправления наступило раньше, чем была создана БД
			order by fv2.flight_id) t using (flight_id) -- сортируем значения по рейсу
		where fv.status not in ('Scheduled', 'On Time', 'Delayed')) sub
	where sub.s2 is null ) sub3 on tf.flight_id = sub3.s1 --рейсы, которые присутствуют в таблице sub и отсутствуют в таблице t, sub3=(sub-t). По этим рейсам нельзя пройти регистрацию 
where sub3.s1 is /*not*/ null 
order by tf.flight_id */

/*
select fv.flight_id , fv.status 
from flights_v fv 
where fv.status not in ('Scheduled', 'On Time', 'Delayed') --17179 все самолёты, которые уже вылетели или отменены*/

/*
select 
fv.flight_id ,
fv.status,
fv.scheduled_departure, 
fv.actual_departure,
bookings.now()-fv.scheduled_departure as difference
from flights_v fv
where fv.status not in ('Scheduled', 'On Time', 'Delayed') and (fv.scheduled_departure <= bookings.now() or fv.actual_departure <= bookings.now())
order by flight_id --16773 рейсы, которые уже улетели или были отменены на момент создания БД. То есть все рейсы, на которые закончена регистрация на момент создания БД.*/

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
where fv.status not in ('Scheduled', 'On Time', 'Delayed') --все самолёты, по которым нельзя было пройти регистрацию на момент создания БД 
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

Каждое бронирование может включать несколько билетов, по одному на каждого пассажира.
Билет, в свою очередь, может включать несколько перелетов. 
Билет имеет уникальный номер (ticket_no), состоящий из 13 цифр.
Полная информация о бронировании находится в трех таблицах: bookings, tickets и ticket_flights.

При регистрации на рейс, которая возможна за сутки до плановой даты отправления,
пассажиру выдается посадочный талон. Он идентифицируется также, как и перелет —
номером билета и номером рейса.
Посадочным талонам присваиваются последовательные номера (boarding_no) в порядке
регистрации пассажиров на рейс (этот номер будет уникальным только в пределах данного
рейса). В посадочном талоне указывается номер места (seat_no).*/


№5 НАЙДИТЕ КОЛИЧЕСТВО СВОБОДНЫХ МЕСТ ДЛЯ КАЖДОГО РЕЙСА, ИХ % ОТНОШЕНИЕ К ОБЩЕМУ КОЛИЧЕСТВУ МЕСТ В САМОЛЕТЕ.
ДОБАВЬТЕ СТОЛБЕЦ С НАКОПИТЕЛЬНЫМ ИТОГОМ - СУММАРНОЕ НАКОПЛЕНИЕ КОЛИЧЕСТВА ВЫВЕЗЕННЫХ ПАССАЖИРОВ ИЗ КАЖДОГО АЭРОПОРТА НА КАЖДЫЙ ДЕНЬ. 
Т.Е. В ЭТОМ СТОЛБЦЕ ДОЛЖНА ОТРАЖАТЬСЯ НАКОПИТЕЛЬНАЯ СУММА - СКОЛЬКО ЧЕЛОВЕК УЖЕ ВЫЛЕТЕЛО ИЗ ДАННОГО АЭРОПОРТА НА ЭТОМ ИЛИ БОЛЕЕ РАННИХ РЕЙСАХ В ТЕЧЕНИИ ДНЯ.
- ОКОННАЯ ФУНКЦИЯ
- ПОДЗАПРОСЫ ИЛИ/И CTE

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

№6 НАЙДИТЕ ПРОЦЕНТНОЕ СООТНОШЕНИЕ ПЕРЕЛЕТОВ ПО ТИПАМ САМОЛЕТОВ ОТ ОБЩЕГО КОЛИЧЕСТВА.
- ПОДЗАПРОС ИЛИ ОКНО
- ОПЕРАТОР ROUND

/*select sum("% of flights_sum")--100.001
from (*/
	select f.aircraft_code, 
	round((count(f.flight_id )/sum(count(f.flight_id)) over ())*100, 3)::numeric(10,5) as "% of flights_sum"
	from flights f
	group by f.aircraft_code
/*) sub1*/


№7 БЫЛИ ЛИ ГОРОДА, В КОТОРЫЕ МОЖНО ДОБРАТЬСЯ БИЗНЕС - КЛАССОМ ДЕШЕВЛЕ, ЧЕМ ЭКОНОМ-КЛАССОМ В РАМКАХ ПЕРЕЛЕТА?
- CTE

/*Билет включает один или несколько перелетов (ticket_flights). Несколько перелетов могут
включаться в билет в случаях, когда нет прямого рейса, соединяющего пункты
отправления и назначения (полет с пересадками), либо когда билет взят «туда и обратно».
В схеме данных нет жесткого ограничения, но предполагается, что все билеты в одном
бронировании имеют одинаковый набор перелетов.
Перелёт = рейс*/

--EXISTS выбор количества городов, в которые можно было добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета на момент создания БД
--explain analyze --729288
select count("Название города") "Кол-во городов" 
from (
	--выбор уникальных городов
	select distinct "Название города" 
	from (
			--выбор городов (и рейсов) с выводом стоимости бизнес-класса и стоимости эконом-класса
			select distinct fv.arrival_city "Название города",/* tf.flight_id "ID рейса",*/ tf.amount "Стоимость бизнес-класса", sub.amount "Стоимость эконом-класса"
			from ticket_flights tf 
			join (
				select tf1.flight_id, tf1.fare_conditions, tf1.amount 
				from ticket_flights tf1 
				where fare_conditions = 'Economy' --рейсы с эконом-классом
				) sub using (flight_id)
			join flights_v fv using (flight_id)
			where tf.fare_conditions = 'Business' --рейсы с бизнес-классом
			) sub1
	where "Стоимость бизнес-класса" < "Стоимость эконом-класса" ) sub2
where exists (
select "Название города" where "Название города"<>'0')

--без EXISTS. Выбор городов, где бизнес-класс дешевле эконом-класса
--explain analyze --727183
select * from (
	--вывод городов, в которые можно добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета на момент создания БД
	select distinct
		a.city "Название города",
		tf.flight_id "ID рейса",
		tf.amount "Стоимость бизнес-класса",
		sub.amount "Стоимость эконом-класса"
	from ticket_flights tf 
	join (
		select tf1.flight_id, tf1.fare_conditions, tf1.amount 
		from ticket_flights tf1 
		where fare_conditions = 'Economy' --рейсы с эконом-классом
		) sub using (flight_id)
	join flights f using (flight_id)
	join airports a on a.airport_code = f.arrival_airport 
	where tf.fare_conditions = 'Business' --рейсы с бизнес-классом
		) sub1
		where "Стоимость бизнес-класса" < "Стоимость эконом-класса"

-- то же самое с одним объединением через представление
--explain analyze --727490
select * from (
	--вывод городов, в которые можно было добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета на момент создания БД
	select distinct
		fv.arrival_city "Название города",
		tf.flight_id "ID рейса",
		tf.amount "Стоимость бизнес-класса",
		sub.amount "Стоимость эконом-класса"
	from ticket_flights tf 
	join (
		select tf1.flight_id, tf1.fare_conditions, tf1.amount 
		from ticket_flights tf1 
		where fare_conditions = 'Economy' --рейсы с эконом-классом
		) sub using (flight_id)
	join flights_v fv using (flight_id)
	where tf.fare_conditions = 'Business' --рейсы с бизнес-классом
		) sub1
		where "Стоимость бизнес-класса" < "Стоимость эконом-класса"		

/*
--уникальные города, в которые летали самолёты классов бизнес и эконом
select distinct fv.arrival_city "Название города"/*, tf.flight_id "ID рейса", tf.amount "Стоимость бизнес-класса", sub.amount "Стоимость эконом-класса"*/
		from ticket_flights tf 
		join (
			select tf1.flight_id, tf1.fare_conditions, tf1.amount 
			from ticket_flights tf1 
			where fare_conditions = 'Economy' --рейсы с эконом-классом
			) sub using (flight_id)
		join flights_v fv using (flight_id)
		where tf.fare_conditions = 'Business'
		
select distinct fv.arrival_city, fv.departure_airport ,s.fare_conditions from flights_v fv 
join seats s using (aircraft_code)
where s.fare_conditions = 'Comfort'

--города, в которые ещё не прилетали самолёты классов бизнес и эконом
select distinct fv1.arrival_city, "Название города", sub1.fare_conditions from flights_v fv1
left join (select distinct fv.arrival_city "Название города", sub3.fare_conditions /*, tf.flight_id "ID рейса", tf.amount "Стоимость бизнес-класса", sub.amount "Стоимость эконом-класса"*/
		from ticket_flights tf 
		join (
			select tf1.flight_id, tf1.fare_conditions, tf1.amount 
			from ticket_flights tf1 
			where fare_conditions = 'Economy' --рейсы с эконом-классом
			) sub using (flight_id)
		join flights_v fv using (flight_id)
		join (select distinct fv.arrival_city, s.fare_conditions from flights_v fv 
join seats s using (aircraft_code)) sub3 using (arrival_city)
		where tf.fare_conditions = 'Business') sub1 on "Название города"=fv1.arrival_city
where "Название города" is null

select * from flights_v fv 
where fv.arrival_city = 'Архангельск'

select * from seats s 
where aircraft_code = 'CR2'


/*select * from ticket_flights tf -- все посадочные талоны 1045726

select distinct ticket_no, count (flight_id) from ticket_flights tf
group by ticket_no --все билеты 366733

select ticket_no from boarding_passes bp -- все взятые посадочные талоны 579686 

select distinct ticket_no from boarding_passes bp --238834 все билеты , по которым взят хотя бы один из талонов

select distinct t.book_ref "Номер брони" --262788 всего уникальных номеров брони
from tickets t

select b.book_ref , b.total_amount, t.ticket_no, bp.flight_id 
from bookings b 
join tickets t using (book_ref)
join boarding_passes bp using (ticket_no)*/

*/

№8 МЕЖДУ КАКИМИ ГОРОДАМИ НЕТ ПРЯМЫХ РЕЙСОВ? - ДЕКАРТОВО ПРОИЗВЕДЕНИЕ В ПРЕДЛОЖЕНИИ FROM - САМОСТОЯТЕЛЬНО СОЗДАННЫЕ ПРЕДСТАВЛЕНИЯ
(ЕСЛИ ОБЛАЧНОЕ ПОДКЛЮЧЕНИЕ, ТО БЕЗ ПРЕДСТАВЛЕНИЯ) - ОПЕРАТОР EXCEPT

--СОЗДАНИЕ МАТЕРИАЛИЗОВАННОГО ПРЕДСТАВЛЕНИЯ СО ВСЕМИ ПАРАМИ ГОРОДОВ
create materialized view "all_pairs" as
select distinct a1.city as city1, a2.city as city2 --уникальные города 101 
from airports a1, airports a2 -- всего пересечений 101*101=10201, но из каждого города можно попасть максимум в 100 городов, соответственно 101*100=10100, но пары повторяются, потому 10100/2=5050
where a1.city < a2.city 
with no data

--ОБНОВЛЕНИЕ МАТЕРИАЛИЗОВАННОГО ПРЕДСТАВЛЕНИЯ
refresh materialized view all_pairs

--drop materialized view all_pairs

--СОЗДАНИЕ ПРЕДСТАВЛЕНИЯ С ИМЕЮЩИМИСЯ ПАРАМИ ГОРОДОВ
create view "unique_pairs" as (
select distinct r.departure_city as city1, r.arrival_city as city2 -- уникальные рейсы 516/2=258
from routes r
where r.departure_city < r.arrival_city)

--drop view unique_pairs

--4792 ПАРЫ ГОРОДОВ БЕЗ ПРЯМЫХ РЕЙСОВ
--explain analyze 
select * from all_pairs ap 
except
select * from unique_pairs up 
order by city1

/*--ПРОВЕРКА
--Города, которые не имеют прямых рейсов с Санкт-Петербургом --78
select * from (
select * from all_pairs ap 
except
select * from unique_pairs up 
order by city1 ) t
where t.city1 = 'Санкт-Петербург' or t.city2 = 'Санкт-Петербург'

--Города, которые имеют прямые рейсы с Санкт-Петербургом --22
SELECT distinct r.departure_city,
r.arrival_city 
FROM routes r
where r.departure_city < r.arrival_city and (r.departure_city = 'Санкт-Петербург' or r.arrival_city = 'Санкт-Петербург')

--Проверка успешна 22+78=100*/

№9 ВЫЧИСЛИТЕ РАССТОЯНИЕ МЕЖДУ АЭРОПОРТАМИ, СВЯЗАННЫМИ ПРЯМЫМИ РЕЙСАМИ, СРАВНИТЕ С ДОПУСТИМОЙ МАКСИМАЛЬНОЙ ДАЛЬНОСТЬЮ ПЕРЕЛЕТОВ В САМОЛЕТАХ, ОБСЛУЖИВАЮЩИХ ЭТИ РЕЙСЫ
- ОПЕРАТОР RADIANS ИЛИ
ИСПОЛЬЗОВАНИЕ SIND/COSD
- CASE
* - В облачной базе координаты находятся в столбце airports_data.coordinates - работаете,
как с массивом. В локальной базе координаты находятся в столбцах airports.longitude и
airports.latitude.
Кратчайшее расстояние между двумя точками A и B на земной поверхности (если принять
ее за сферу) определяется зависимостью:
d = arccos {sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a -
longitude_b)}, где latitude_a и latitude_b — широты, longitude_a, longitude_b — долготы
данных пунктов, d — расстояние между пунктами измеряется в радианах длиной дуги
большого круга земного шара.
Расстояние между пунктами, измеряемое в километрах, определяется по формуле:
L = d·R, где R = 6371 км — средний радиус земного шара

select 
	sub1."Аэропорт №1", 
	sub1."Аэропорт №2", 
	sub1."Расстояние между аэропортами", 
	case
		when sub1."Дальность полёта" > sub1."Расстояние между аэропортами" then 'Самолёт долетит'
		else 'Необходима промежуточная посадка'
	end as "Проверка по дальности"/*,
	case
		when sub1."Дальность полёта" > sub1."Расстояние между аэропортами" then "Дальность полёта"-"Расстояние между аэропортами"
		else "Дальность полёта"-"Расстояние между аэропортами"
	end as "Запас по дальности"*/
from (
select distinct 
	r.departure_airport, 
	r.departure_airport_name as "Аэропорт №1",
	a1.longitude as dep_longitude, 
	a1.latitude as dep_latitude, 
	r.arrival_airport, 
	r.arrival_airport_name as "Аэропорт №2",
	a2.longitude as arr_longitude, 
	a2.latitude as arr_latitude,
	radians(acosd(sind(a1.latitude)*sind(a2.latitude)+cosd(a1.latitude)*cosd(a2.latitude)*cosd(a1.longitude-a2.longitude)))*6371 as "Расстояние между аэропортами",
	a3.model "Модель самолёта",
	a3."range" as "Дальность полёта"
from routes r
join airports a1 on r.departure_airport = a1.airport_code 
join airports a2 on r.arrival_airport = a2.airport_code
join aircrafts a3 using (aircraft_code)
where r.departure_airport < r.arrival_airport) sub1
order by "Проверка по дальности", sub1."Аэропорт №1", sub1."Расстояние между аэропортами"
