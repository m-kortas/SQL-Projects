-- wpływ linii lotniczej na opóźnienia

with stat as(select identyfikator_operatora as id, count(1) as liczba,
round(count(case WHEN ao.status_odp != 'zaakceptowany' then ao.id end)::numeric,3) odrz,
round(count(case WHEN ao.status_odp = 'zaakceptowany' then ao.id end)::numeric,3) zaa
from wnioski w
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
join analiza_operatora ao on ao.id_wniosku = w.id
GROUP BY 1),

liczenie as (select id, liczba, odrz, zaa,
round(odrz/ sum(odrz) over()::numeric,3) as DB,
round( zaa/ sum(zaa) over()::numeric,3) as DG,
round(ln((zaa/ sum(zaa) over()) / (odrz/ sum(odrz) over()))::numeric,3) as WOE,
round(zaa/ sum(zaa) over() - odrz/ sum(odrz) over()  ::numeric,3) as roznicaDGDB,
round( (ln((zaa/ sum(zaa) over()) / (odrz/ sum(odrz) over())))*(zaa/ sum(zaa) over() - odrz/ sum(odrz) over())  ::numeric,3) as IV
from stat
GROUP BY 1,2,3,4)

SELECT id, liczba, odrz, zaa, DB, DG, WOE, roznicaDGDB, IV, sum(IV) over ()
from liczenie
group by 1,2,3,4,5,6,7,8,9;


...

with kwart1 as(select coalesce( identyfikator_operator_operujacego, identyfikator_operatora) as id,
count(case WHEN ao.status_odp = 'zaakceptowany' and ao.data_odpowiedzi between '2017-10-01' and '2017-12-31' then ao.id end)/
nullif(count(case WHEN ao.data_odpowiedzi between '2017-10-01' and '2017-12-31' then ao.id end)::numeric,0) acceptance_rate_IV_kwart
from wnioski w
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
join analiza_operatora ao on ao.id_wniosku = w.id
  where czy_zaklocony = TRUE
GROUP BY 1),

kwart4 as (select coalesce( identyfikator_operator_operujacego, identyfikator_operatora)  as id,
count(case WHEN ao.status_odp = 'zaakceptowany' and to_char(ao.data_odpowiedzi, 'YYYYQ') = '20171' then ao.id end)/
nullif(count(case WHEN to_char(ao.data_odpowiedzi, 'YYYYQ') = '20171' then ao.id end)::numeric, 0) acceptance_rate_I_kwart
from wnioski w
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
join analiza_operatora ao on ao.id_wniosku = w.id
 -- where ao.data_odpowiedzi between '2017-01-01' and '2017-03-31'
  where  czy_zaklocony = TRUE
GROUP BY 1)

SELECT kwart1.id, acceptance_rate_I_kwart, acceptance_rate_IV_kwart
  from kwart1
 JOIN kwart4 on kwart1.id = kwart4.id
order by 2 DESC

