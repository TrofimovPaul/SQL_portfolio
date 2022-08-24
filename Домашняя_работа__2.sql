--=============== ÌÎÄÓËÜ 2. ÐÀÁÎÒÀ Ñ ÁÀÇÀÌÈ ÄÀÍÍÛÕ  =======================================
--= ÏÎÌÍÈÒÅ, ×ÒÎ ÍÅÎÁÕÎÄÈÌÎ ÓÑÒÀÍÎÂÈÒÜ ÂÅÐÍÎÅ ÑÎÅÄÈÍÅÍÈÅ È ÂÛÁÐÀÒÜ ÑÕÅÌÓ PUBLIC===========
--SET search_path TO "public";
SET search_path TO "dvd-rental";-- â ìî¸ì ñëó÷àå ñõåìà ïåðåèìåíîâàíà â "dvd-rental"

--======== ÎÑÍÎÂÍÀß ×ÀÑÒÜ ==============

--ÇÀÄÀÍÈÅ ¹1
--Âûâåäèòå óíèêàëüíûå íàçâàíèÿ ãîðîäîâ èç òàáëèöû ãîðîäîâ.
select distinct city as unique_city_name from city

--select count(city) from city --600

--select count (distinct city) "distinct" from city --599

--ÇÀÄÀÍÈÅ ¹2
--Äîðàáîòàéòå çàïðîñ èç ïðåäûäóùåãî çàäàíèÿ, ÷òîáû çàïðîñ âûâîäèë òîëüêî òå ãîðîäà,
--íàçâàíèÿ êîòîðûõ íà÷èíàþòñÿ íà “L” è çàêàí÷èâàþòñÿ íà “a”, è íàçâàíèÿ íå ñîäåðæàò ïðîáåëîâ.
select city as "city_name_L%a" from city
where city like 'L%a' and city not like 'L% %a'

--ÇÀÄÀÍÈÅ ¹3
--Ïîëó÷èòå èç òàáëèöû ïëàòåæåé çà ïðîêàò ôèëüìîâ èíôîðìàöèþ ïî ïëàòåæàì, êîòîðûå âûïîëíÿëèñü 
--â ïðîìåæóòîê ñ 17 èþíÿ 2005 ãîäà ïî 19 èþíÿ 2005 ãîäà âêëþ÷èòåëüíî, 
--è ñòîèìîñòü êîòîðûõ ïðåâûøàåò 1.00.
--Ïëàòåæè íóæíî îòñîðòèðîâàòü ïî äàòå ïëàòåæà.


--select * from payment p --âûáåðåì id, ñòîèìîñòü è äàòó ïëàòåæà

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



--ÇÀÄÀÍÈÅ ¹4
-- Âûâåäèòå èíôîðìàöèþ î 10-òè ïîñëåäíèõ ïëàòåæàõ çà ïðîêàò ôèëüìîâ.
select payment_id, payment_date, amount 
from payment
order by payment_date desc 
limit 10

--ÇÀÄÀÍÈÅ ¹5
--Âûâåäèòå ñëåäóþùóþ èíôîðìàöèþ ïî ïîêóïàòåëÿì:
--  1. Ôàìèëèÿ è èìÿ (â îäíîé êîëîíêå ÷åðåç ïðîáåë)
--  2. Ýëåêòðîííàÿ ïî÷òà
--  3. Äëèíó çíà÷åíèÿ ïîëÿ email
--  4. Äàòó ïîñëåäíåãî îáíîâëåíèÿ çàïèñè î ïîêóïàòåëå (áåç âðåìåíè)
--Êàæäîé êîëîíêå çàäàéòå íàèìåíîâàíèå íà ðóññêîì ÿçûêå.
select 
	concat(LAst_name, ' ', FIRst_name) as "Äàííûå ïîêóïàòåëÿ",
	email as "Ïî÷òîâûé àäðåñ",
	length (email) "Äëèíà ïî÷òîâîãî àäðåñà",
	cast (last_update as date) "Äàòà îáíîâëåíèÿ" 
from customer;

select 
	concat(last_name, ' ', FIRst_name) as "Äàííûå ïîêóïàòåëÿ",
	email as "Ïî÷òîâûé àäðåñ",
	--character_length(email), --èëè
	length (email) "Äëèíà ïî÷òîâîãî àäðåñà",
	cast (last_update as date) --ïî÷åìó áåç ïñåâäîíèìà ñîõðàíÿåòñÿ òèï timestamp?
from customer;


--ÇÀÄÀÍÈÅ ¹6
--Âûâåäèòå îäíèì çàïðîñîì òîëüêî àêòèâíûõ ïîêóïàòåëåé, èìåíà êîòîðûõ KELLY èëè WILLIE.
--Âñå áóêâû â ôàìèëèè è èìåíè èç âåðõíåãî ðåãèñòðà äîëæíû áûòü ïåðåâåäåíû â íèæíèé ðåãèñòð.

select  lower (last_name) last_name, lower (first_name) first_name, active
from customer
where (first_name = 'KELLY' or first_name = 'WILLIE') and active = 1


--======== ÄÎÏÎËÍÈÒÅËÜÍÀß ×ÀÑÒÜ ==============

--ÇÀÄÀÍÈÅ ¹1
--Âûâåäèòå îäíèì çàïðîñîì èíôîðìàöèþ î ôèëüìàõ, ó êîòîðûõ ðåéòèíã "R" 
--è ñòîèìîñòü àðåíäû óêàçàíà îò 0.00 äî 3.00 âêëþ÷èòåëüíî, 
--à òàêæå ôèëüìû c ðåéòèíãîì "PG-13" è ñòîèìîñòüþ àðåíäû áîëüøå èëè ðàâíîé 4.00.
select film_id , title, description , rating, rental_rate 
from film
	where 
	(rating::text = 'R' and rental_rate between 0 and 3)
	or
	(rating::text ilike 'PG-13' and rental_rate >=4)



--ÇÀÄÀÍÈÅ ¹2
--Ïîëó÷èòå èíôîðìàöèþ î òð¸õ ôèëüìàõ ñ ñàìûì äëèííûì îïèñàíèåì ôèëüìà.

select film_id , title, description , length (description) as "Äëèíà îïèñàíèÿ"
from film
order by character_length(description) desc
limit 3

/*select max(description) ïîïûòêà íàéòè ÷åðåç ìàêñèìóì âûäà¸ò íåâåðíîå çíà÷åíèå "A Unbelieveable Yarn of a Student And a Database Administrator who must Outgun a Husband in An Abandoned Mine Shaft"
from film f 

select film_id, title
from film f 
where description = 'A Unbelieveable Yarn of a Student And a Database Administrator who must Outgun a Husband in An Abandoned Mine Shaft'*/

--ÇÀÄÀÍÈÅ ¹3
-- Âûâåäèòå Email êàæäîãî ïîêóïàòåëÿ, ðàçäåëèâ çíà÷åíèå Email íà 2 îòäåëüíûõ êîëîíêè:
--â ïåðâîé êîëîíêå äîëæíî áûòü çíà÷åíèå, óêàçàííîå äî @, 
--âî âòîðîé êîëîíêå äîëæíî áûòü çíà÷åíèå, óêàçàííîå ïîñëå @.
--explain analyze 18
select split_part(email, '@', 1) "before @", 
split_part(email, '@', 2) "after @"
from customer 

--explain analyze 26
select 
left(email, strpos(email, '@')-1) "Before @",
right(email, length(email)-strpos(email, '@')) "After @"
from customer 




--ÇÀÄÀÍÈÅ ¹4
--Äîðàáîòàéòå çàïðîñ èç ïðåäûäóùåãî çàäàíèÿ, ñêîððåêòèðóéòå çíà÷åíèÿ â íîâûõ êîëîíêàõ: 
--ïåðâàÿ áóêâà äîëæíà áûòü çàãëàâíîé, îñòàëüíûå ñòðî÷íûìè.

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


