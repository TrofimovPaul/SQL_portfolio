--=============== ������ 4. ���������� � SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO "homework"; --� ��� ������

--======== �������� ����� ==============

--������� �1
--���� ������: ���� ����������� � �������� ����, �� ������� ����� ����� � ��������� � --���� �������, �������� ������ ���� �� �������� � ������ �������� � ������� �������� --� ���� ����� �����, 
--���� ����������� � ���������� �������, �� ������� ����� ����� � --� ��� ������� �������.

--������������� ���� ������, ���������� ��� �����������:
--� ���� (����������, ����������� � �. �.);
--� ���������� (�������, ���������� � �. �.);
--� ������ (������, �������� � �. �.).
--��� ������� �� �������: ����-���������� � ����������-������, ��������� ������ �� ������. ������ ������� �� ������� � film_actor.
--���������� � ��������-������������:
--� ������� ����������� ��������� ������.
--� �������������� �������� ������ ������������� ���������������;
--� ������������ ��������� �� ������ ��������� null-��������, �� ������ ����������� --��������� � ��������� ���������.
--���������� � �������� �� �������:
--� ������� ����������� ��������� � ������� ������.

--� �������� ������ �� ������� �������� ������� �������� ������ � ������� �� --���������� � ������ ������� �� 5 ����� � �������.
 
--�������� ������� �����
create table "language"  (
language_id serial PRIMARY key,
"name" varchar(50) unique not null,
"last_update" timestamp default now()
);

select * from "language"

--drop table "language" ,nationality , "language-nationality" , "nationality-country" , country 

--�������� ������ � ������� �����
insert into "language" (name)
values ('����������'),
('�����������'),
('��������'),
('���������'),
('�������')

select * from "language"

--drop table "language" 

/*���������� ������� � �������� ���������� ������
--alter table "language" add column "name_ru" varchar(50) unique

�������� ������������ �������*/ 
--alter table "language" drop column "name_ru"

--�������� ������� ����������
create table nationality  (
nationality_id serial primary key,
nationality_name varchar(100) unique not null,
"last_update" timestamp default now()
);

select * from nationality

--drop table nationality

--�������� ������ � ������� ����������
alter table nationality drop column last_update

insert into nationality (nationality_name)
values 
('�������'),
('�����'), 
('��������'),
('�������'),
('���������')

select * from nationality

--drop table nationality

--�������� ������� ������
create table country (
country_id serial primary key,
country varchar(100) unique not null,
"last_update" timestamp default now()
);

select * from country


--�������� ������ � ������� ������
insert into country (country)
values ('������'), ('��������'), ('�������'), ('�����'), ('������') 

select * from country

--drop table "language", nationality , country 

--�������� ������ ������� �� �������
create table "language-nationality"  (
language_id integer references "language" (language_id),
nationality_id integer, 
"last_update" timestamp default now(),
primary key (language_id, nationality_id),
foreign key (nationality_id) references nationality (nationality_id)
);

select * from "language-nationality"

--drop table "language-nationality"

--�������� ������ � ������� �� �������
insert into "language-nationality" (language_id, nationality_id)
values (1, 5), (2, 3), (3,2), (4,4), (5,1)

/* 
�� ��� ���������, ���� ��� �������� � ��������

insert into "language-nationality" (language_id, nationality_id)
values (10, 5)

insert into "language-nationality" (language_id, nationality_id)
values (1, 55)*/

--�������� ������ ������� �� �������
create table "nationality-country"  (
nationality_id integer not null,
country_id integer references country (country_id),
"last_update" timestamp default now(),
primary key (country_id, nationality_id),
foreign key (nationality_id) references nationality (nationality_id)
);

select * from "nationality-country"

--drop table  "nationality-country"

--�������� ������ � ������� �� �������
-�������� ������ � ������� �� �������

insert into "nationality-country" (country_id, nationality_id)
values (1, 1), (2, 2), (3,3), (4,4), (5,5)

select * from "nationality-country"

select n.nationality_name "����������", l."name" "����", c.country "������" from 
nationality n 
join "language-nationality" ln2 on n.nationality_id = ln2.nationality_id 
join "nationality-country" nc ON n.nationality_id = nc.nationality_id 
join "language" l on ln2.language_id =l.language_id 
join country c on c.country_id =nc.country_id 

--======== �������������� ����� ==============


--������� �1 
--�������� ����� ������� film_new �� ���������� ������:
--�   	film_name - �������� ������ - ��� ������ varchar(255) � ����������� not null
--�   	film_year - ��� ������� ������ - ��� ������ integer, �������, ��� �������� ������ ���� ������ 0
--�   	film_rental_rate - ��������� ������ ������ - ��� ������ numeric(4,2), �������� �� ��������� 0.99
--�   	film_duration - ������������ ������ � ������� - ��� ������ integer, ����������� not null � �������, ��� �������� ������ ���� ������ 0
--���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

create table film_new (
film_id serial primary key,
film_name varchar (255) not null, 
film_year integer check (film_year > 0),
film_rental_rate numeric(4,2) default 0.99,
film_duration integer not null check (film_duration > 0)
)

select * from film_new

drop table film_new 
--������� �2 
--��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
--�       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--�       film_year - array[1994, 1999, 1985, 1994, 1993]
--�       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--�   	  film_duration - array[142, 189, 116, 142, 195]

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select
	unnest(array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler�s List']),
	unnest(array[1994, 1999, 1985, 1994, 1993]),
	unnest(array[2.99, 0.99, 1.99, 2.99, 3.99]),
	unnest(array[142, 189, 116, 142, 195])
	
select * from film_new

--������� �3
--�������� ��������� ������ ������� � ������� film_new � ������ ����������, 
--��� ��������� ������ ���� ������� ��������� �� 1.41

update film_new
set film_rental_rate = film_rental_rate + 1.41

select * from film_new

--������� �4
--����� � ��������� "Back to the Future" ��� ���� � ������, 
--������� ������ � ���� ������� �� ������� film_new

delete from film_new
where film_name ilike 'Back to the Future'

select * from film_new 

--������� �5
--�������� � ������� film_new ������ � ����� ������ ����� ������

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('Airplane Sierra', 2006, 4.99, 62)

--������� �6
--�������� SQL-������, ������� ������� ��� ������� �� ������� film_new, 
--� ����� ����� ����������� ������� "������������ ������ � �����", ���������� �� �������

select *, round(film_duration::numeric/60 , 1) as "������������ ������ � �����" from film_new


--������� �7 
--������� ������� film_new

drop table film_new