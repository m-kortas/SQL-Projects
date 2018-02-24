SELECT kwota_rekompensaty_oryginalna, kwota_rekompensaty, (kwota_rekompensaty-wnioski.kwota_rekompensaty_oryginalna) as roznica
FROM wnioski
ORDER BY roznica

SELECT kwota_rekompensaty, liczba_pasazerow, kwota_rekompensaty/liczba_pasazerow as kwotakoncowa
FROM wnioski
WHERE kwota_rekompensaty/liczba_pasazerow != 250 or kwota_rekompensaty/liczba_pasazerow != 400 or kwota_rekompensaty/liczba_pasazerow != 600
order by kwota_rekompensaty, liczba_pasazerow


SELECT kwota_rekompensaty_oryginalna, kwota_rekompensaty, (kwota_rekompensaty-wnioski.kwota_rekompensaty_oryginalna) as roznica
FROM wnioski
GROUP BY roznica, wnioski.kwota_rekompensaty_oryginalna, kwota_rekompensaty

select count(case when kwota_rekompensaty != wnioski.kwota_rekompensaty_oryginalna then 1 end), count(1),
      round(count(case when kwota_rekompensaty != wnioski.kwota_rekompensaty_oryginalna then 0 end)/count(1)::NUMERIC, 4)

from wnioski


SELECT  min(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty), max(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty), avg(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty),
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 200 then 1 end) as less_than_200,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 500 then 2 end) as less_than_500,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 1000 then 3 end) as less_than_1000,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty > 1000 then 4 end) as more_than_1000

FROM wnioski
WHERE  kwota_rekompensaty != wnioski.kwota_rekompensaty_oryginalna



SELECT  id, to_char(data_utworzenia, 'YYYY-Q'), min(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty), max(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty), avg(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty),
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 200 then 1 end) as less_than_200,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 500 then 2 end) as less_than_500,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 1000 then 3 end) as less_than_1000,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty > 1000 then 4 end) as more_than_1000,

count(case when data_utworzenia < '2013-01-01' then 5 end) as before2013,
count(case when data_utworzenia < '2014-01-01' then 6 end) as in2013,
count(case when data_utworzenia < '2015-01-01' then 7 end) as in2014,
count(case when data_utworzenia > '2015-01-01' then 8 end) as after2014
FROM wnioski
WHERE  kwota_rekompensaty != wnioski.kwota_rekompensaty_oryginalna
GROUP BY 1


SELECT  to_char(data_utworzenia, 'YYYY-Q'),
  count(case when kwota_rekompensaty-wnioski.kwota_rekompensaty_oryginalna != 0 then id end) as liczbarozn,
  min(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty),
  max(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty),
  avg(wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty)
FROM wnioski
WHERE  kwota_rekompensaty != wnioski.kwota_rekompensaty_oryginalna
GROUP BY 1



SELECT  id, to_char(data_utworzenia, 'YYYY-Q'),
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 200 then 1 end) as less_than_200,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 500 then 2 end) as less_than_500,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty < 1000 then 3 end) as less_than_1000,
count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty > 1000 then 4 end) as more_than_1000,

count(case when data_utworzenia < '2013-01-01' then 5 end) as before2013,
count(case when data_utworzenia < '2014-01-01' then 6 end) as in2013,
count(case when data_utworzenia < '2015-01-01' then 7 end) as in2014,
count(case when data_utworzenia > '2015-01-01' then 8 end) as after2014
FROM wnioski
WHERE  kwota_rekompensaty != wnioski.kwota_rekompensaty_oryginalna
GROUP BY 1


SELECT
  CASE
 when kwota_rekompensaty_oryginalna-kwota_rekompensaty < 100 then '<100'
 when kwota_rekompensaty_oryginalna-kwota_rekompensaty < 250 then '<250'
 when kwota_rekompensaty_oryginalna-kwota_rekompensaty < 600 then '<600'
 else '>600' end,
 count(case when wnioski.kwota_rekompensaty_oryginalna-kwota_rekompensaty != 0 then id end) as liczba_roznych
FROM wnioski
WHERE  kwota_rekompensaty != wnioski.kwota_rekompensaty_oryginalna
GROUP BY 1
ORDER BY 1

select count(w.id) wszystkie,
       count(a.id) ocenione,
       count(a.id)/count(w.id)::NUMERIC procent_ocenionych,
       count(case WHEN a.status = 'zaakceptowany' then a.id end)/count(w.id)::numeric proc_zaaakceptowanych,
       count(case WHEN a.status = 'zaakceptowany' then a.id end)/count(a.id)::numeric proc_zaaakceptowanych_od_ocenionych
from wnioski w
LEFT JOIN analizy_wnioskow a ON w.id = a.id_wniosku;


select to_char(w.data_utworzenia, 'YYYY-Q'),
       count(case WHEN a.status = 'odrzucony' then a.id end)::numeric liczb_odrzuconych,
       count(case WHEN a.status = 'odrzucony' then a.id end)/count(w.id)::numeric proc_odrzuconych,
       count(case WHEN a.status = 'odrzucony' then a.id end)/count(a.id)::numeric proc_odrzuconych_od_ocenionych

from wnioski w
LEFT JOIN analizy_wnioskow a ON w.id = a.id_wniosku
group by 1
order by 1;

select to_char(a.data_zakonczenia, 'YYYY-Q'),
       count(case WHEN a.status = 'odrzucony' then a.id end)::numeric liczb_odrzuconych,
       count(case WHEN a.status = 'odrzucony' then a.id end)/count(w.id)::numeric proc_odrzuconych,
       count(case WHEN a.status = 'odrzucony' then a.id end)/count(a.id)::numeric proc_odrzuconych_od_ocenionych

from wnioski w
JOIN analizy_wnioskow a ON w.id = a.id_wniosku
group by 1
order by 1;

select to_char(w.data_utworzenia, 'YYYY' ) data_utw,
      to_char(a.data_zakonczenia, 'YYYY') data_analizy,
      count(w.id) liczba_wnioskow,
      sum(count(w.id)) over(partition by to_char(w.data_utworzenia, 'YYYY' )) wnioskow_w_oknie,
      count(w.id)/sum(count(w.id)) over(PARTITION BY to_char(w.data_utworzenia, 'YYYY' )) procent
from wnioski w
left join analizy_wnioskow a ON w.id = a.id_wniosku
group by 1, 2;


select typ_wniosku, powod_operatora, count(1),
      count(1)/sum(count(1)) over(PARTITION BY typ_wniosku)::numeric procent_z_okna
FROM  wnioski
GROUP BY 1,2
ORDER BY 1,2;


select jezyk, status, count(1),
      round(count(1)/sum(count(1)) over(PARTITION BY jezyk)::numeric,4) procent
from wnioski
JOIN analizy_wnioskow a ON wnioski.id = a.id_wniosku
group by 1,2
ORDER BY 1,2;



  select to_char(data_utworzenia, 'YYYY-MM'), count(1) liczba_wnioskow
  from wnioski
  group by 1
  union
  select 'wszystkie',  count(1) from wnioski


union
select 'wszystkie',  count(1) from wnioski

with moje_dane as (
 select to_char(data_utworzenia, 'YYYY-MM'), count(1) liczba_wnioskow
 from wnioski
 group by 1
  )
select * from moje_dane
UNION
select 'wszystkie',  count(1) from wnioski




with moje_dane as (
select w.id, w.stan_wniosku, identyfikator_podrozy, czy_zaklocony
from wnioski w
  join podroze p on w.id = p.id_wniosku
  join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
where stan_wniosku in ('nowy', 'wyplacony')
  and identyfikator_podrozy not like '%--%'
  and czy_zaklocony = true
order by 1),

lista_podobnych as (select md_nowe.id id_nowego, md_wyplacone.id id_wyplaconego
from moje_dane md_nowe
join moje_dane md_wyplacone on md_wyplacone.identyfikator_podrozy = md_nowe.identyfikator_podrozy
WHERE md_nowe.stan_wniosku = 'nowy'
and md_wyplacone.stan_wniosku = 'wyplacony')

select id_nowego, count(1)
from lista_podobnych
group by 1
order by 2 DESC;

select to_char(data_utworzenia, 'YYYY-MM'), count(1) aktualny,
  lag(count(1)) over() poprzedni,
  (count(1)- lag(count(1)) over()) /  lag(count(1)) over()::numeric mom

from wnioski
group by 1
order by 1;



/*  1. Z którego kraju mamy najwięcej wniosków? */

select kod_kraju, count(1) as liczbawnioskow
from wnioski
group by 1
order by 2 DESC;


/* 2. Z którego języka mamy najwięcej wniosków? */

select jezyk, count(1) as liczbawnioskow
from wnioski
group by 1
ORDER BY 2 DESC;

/* 3. Ile % procent klientów podróżowało w celach biznesowych a ilu w celach prywatnych? */

select typ_podrozy, count(1) as liczba,
count(1) / sum(count(1)) over() procent
from wnioski
    join klienci k ON wnioski.id = k.id_wniosku
GROUP BY 1;

/* 4. Jak procentowo rozkładają się źródła polecenia? */

select zrodlo_polecenia, count(1) as liczba,
      round(count(1) / sum(count(1)) over()::numeric,4) procent
  from wnioski
    where wnioski.zrodlo_polecenia is not NULL
GROUP BY 1
order by 2 ASC;

/* 5. Ile podróży to trasy złożone z jednego / dwóch / trzech / więcej tras? */

with trasy as (
select id_wniosku as wniosek,
       case WHEN count(identyfikator_podrozy) = 1 then 1 else 0 end::numeric jednatrasa,
       case WHEN count(identyfikator_podrozy) = 2 then 1 else 0 end::numeric dwietrasy,
       case WHEN count(identyfikator_podrozy) = 3 then 1 else 0 end::numeric trzytrasy,
       case WHEN count(identyfikator_podrozy) > 3 then 1 else 0 end::numeric wiecej
from szczegoly_podrozy
join podroze p ON szczegoly_podrozy.id_podrozy = p.id
GROUP BY 1
order by 5 DESC )

select * from trasy
UNION
select count(wniosek),
sum(jednatrasa)/count(wniosek)::NUMERIC,
sum(dwietrasy)/count(wniosek)::NUMERIC,
sum(trzytrasy)/count(wniosek)::NUMERIC,
sum(wiecej)/count(wniosek)::NUMERIC from trasy;


/* 6. Na które konto otrzymaliśmy najwięcej / najmniej rekompensaty? */

select konto, count(kwota)
from szczegoly_rekompensat
GROUP BY 1
order by 2;

/* 7.  Który dzień jest rekordowym w firmie w kwestii utworzonych wniosków? */

select to_char(data_utworzenia, 'YYYY-MM-DD') as datautworzenia, count(1)
from wnioski
GROUP BY 1
ORDER BY 2 DESC ;


/* 8. Który dzień jest rekordowym w firmie w kwestii otrzymanych rekompensat?  */

select to_char(data_otrzymania, 'YYYY-MM-DD'), count(1)
from szczegoly_rekompensat
GROUP BY 1
ORDER BY 2 DESC ;

/* 9. Jaka jest dystrubucja tygodniowa wniosków według kanałów? (liczba wniosków w danym tygodniu w każdym kanale) */

select to_char(data_utworzenia, 'WW') as tydzien, kanal, count(1)
from wnioski
group by 1,2;

/* 10. Lista wniosków przeterminowanych (przeterminowany = utworzony w naszej firmie powyżej 3 lat od daty podróży)
 */

select w.id
from wnioski w
  join podroze p on w.id = p.id_wniosku
  join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
  where w.data_utworzenia::date - data_wyjazdu::date > 1095
group by 1;


/* 11. Jaka część naszych klientów to powracające osoby? */

SELECT email,
       count(1) as iloscwnioskow,
       case WHEN count(1) > 1 then 1 else 0 end::numeric powracajacy
FROM wnioski w
join klienci k ON w.id = k.id_wniosku
group by 1
  order by 2 DESC




/* 12. Jaka część naszych współpasażerów to osoby, które już wcześniej pojawiły się na jakimś wniosku? */

SELECT email,
         count(1) as iloscwnioskow,
       case WHEN count(1) > 1 then 1 end::numeric pojawiajacy
FROM wnioski w
join wspolpasazerowie w2 ON w.id = w2.id_wniosku
group by 1
order by 2 DESC;




/* 13. Jaka część klientów pojawiła się na innych wnioskach jako współpasażer? */

Select  k.email as mailaklientow,
         case WHEN k.email = wspolpasazerowie.email then 1 end::numeric bylwspolpasazerem
from wspolpasazerowie
join wnioski w2 ON wspolpasazerowie.id_wniosku = w2.id
join klienci k ON w2.id = k.id_wniosku
group by 1,2
order by 2 ASC;


/*  14. Jaki jest czas od złożenia pierwszego do kolejnego wniosku dla klientów którzy mają min 2 wnioski? */

select email as klient, w2.data_utworzenia as datautworzenia, count(w2.data_utworzenia) over (PARTITION BY email),
  lead(min(w2.data_utworzenia)) over()::date -  min(w2.data_utworzenia)::date as czas_od_1_do_2
  from klienci k
    join wnioski w2 ON k.id_wniosku = w2.id
GROUP BY 1, 2
order by 3 DESC ;
