--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO "homework"; --в моём случае

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаёте новую схему с префиксом в --виде фамилии, название должно быть на латинице в нижнем регистре и таблицы создаете --в этой новой схеме, 
--если подключение к локальному серверу, то создаёте новую схему и --в ней создаёте таблицы.

--Спроектируйте базу данных, содержащую три справочника:
--· язык (английский, французский и т. п.);
--· народность (славяне, англосаксы и т. п.);
--· страны (Россия, Германия и т. п.).
--Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.
--Требования к таблицам-справочникам:
--· наличие ограничений первичных ключей.
--· идентификатору сущности должен присваиваться автоинкрементом;
--· наименования сущностей не должны содержать null-значения, не должны допускаться --дубликаты в названиях сущностей.
--Требования к таблицам со связями:
--· наличие ограничений первичных и внешних ключей.

--В качестве ответа на задание пришлите запросы создания таблиц и запросы по --добавлению в каждую таблицу по 5 строк с данными.
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table "language"  (
language_id serial PRIMARY key,
"name" varchar(50) unique not null,
"last_update" timestamp default now()
);

select * from "language"

--drop table "language" ,nationality , "language-nationality" , "nationality-country" , country 

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
insert into "language" (name)
values ('Английский'),
('Французский'),
('Немецкий'),
('Китайский'),
('Русский')

select * from "language"

--drop table "language" 

/*добавление столбца с русскими названиями языков
--alter table "language" add column "name_ru" varchar(50) unique

удаление добавленного столбца*/ 
--alter table "language" drop column "name_ru"

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
create table nationality  (
nationality_id serial primary key,
nationality_name varchar(100) unique not null,
"last_update" timestamp default now()
);

select * from nationality

--drop table nationality

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
alter table nationality drop column last_update

insert into nationality (nationality_name)
values 
('Русские'),
('Немцы'), 
('Французы'),
('Китайцы'),
('Англичане')

select * from nationality

--drop table nationality

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table country (
country_id serial primary key,
country varchar(100) unique not null,
"last_update" timestamp default now()
);

select * from country


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
insert into country (country)
values ('Россия'), ('Германия'), ('Франция'), ('Китай'), ('Англия') 

select * from country

--drop table "language", nationality , country 

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table "language-nationality"  (
language_id integer references "language" (language_id),
nationality_id integer, 
"last_update" timestamp default now(),
primary key (language_id, nationality_id),
foreign key (nationality_id) references nationality (nationality_id)
);

select * from "language-nationality"

--drop table "language-nationality"

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into "language-nationality" (language_id, nationality_id)
values (1, 5), (2, 3), (3,2), (4,4), (5,1)

/* 
не даёт сработать, если нет значений в таблицах

insert into "language-nationality" (language_id, nationality_id)
values (10, 5)

insert into "language-nationality" (language_id, nationality_id)
values (1, 55)*/

--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table "nationality-country"  (
nationality_id integer not null,
country_id integer references country (country_id),
"last_update" timestamp default now(),
primary key (country_id, nationality_id),
foreign key (nationality_id) references nationality (nationality_id)
);

select * from "nationality-country"

--drop table  "nationality-country"

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
-ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

insert into "nationality-country" (country_id, nationality_id)
values (1, 1), (2, 2), (3,3), (4,4), (5,5)

select * from "nationality-country"

select n.nationality_name "Народность", l."name" "Язык", c.country "Страна" from 
nationality n 
join "language-nationality" ln2 on n.nationality_id = ln2.nationality_id 
join "nationality-country" nc ON n.nationality_id = nc.nationality_id 
join "language" l on ln2.language_id =l.language_id 
join country c on c.country_id =nc.country_id 

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new (
film_id serial primary key,
film_name varchar (255) not null, 
film_year integer check (film_year > 0),
film_rental_rate numeric(4,2) default 0.99,
film_duration integer not null check (film_duration > 0)
)

select * from film_new

drop table film_new 
--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select
	unnest(array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List']),
	unnest(array[1994, 1999, 1985, 1994, 1993]),
	unnest(array[2.99, 0.99, 1.99, 2.99, 3.99]),
	unnest(array[142, 189, 116, 142, 195])
	
select * from film_new

--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41

update film_new
set film_rental_rate = film_rental_rate + 1.41

select * from film_new

--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new

delete from film_new
where film_name ilike 'Back to the Future'

select * from film_new 

--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('Airplane Sierra', 2006, 4.99, 62)

--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых

select *, round(film_duration::numeric/60 , 1) as "Длительность фильма в часах" from film_new


--ЗАДАНИЕ №7 
--Удалите таблицу film_new

drop table film_new