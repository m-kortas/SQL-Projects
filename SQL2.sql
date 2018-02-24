
1) Jaka data była 8 dni temu? - now - 8 days

select now() - interval '8 days'

2) Jaki dzień tygodnia był 3 miesiące temu?     now -  3 months, DAY

select to_char ( now() - interval '3 months' , 'Day')

3) W którym tygodniu roku jest 01 stycznia 2017?      01.01.2017 week

select to_char ( '01.01.2017'::date , 'Week')


4) Podaj listę wniosków z właściwym operatorem (który rzeczywiście przeprowadził trasę) identyfikator_operatora (szczegoly_podrozy), id (wniosek)

select wnioski.id, identyfikator_operatora
 from wnioski
 join podroze p ON wnioski.id = p.id_wniosku
 join szczegoly_podrozy s2 ON p.id = s2.id_podrozy


5) Przygotuj listę klientów z datą utworzenia ich pierwszego i drugiego wniosku. 3 kolumny: email, data 1wszego wniosku, data 2giego wniosku
email, data utworzenia (1st result), data utworzenia (2nd result)

select email, first_value(w.data_utworzenia) over(PARTITION BY k.email order by w.data_utworzenia asc) as First_result,  nth_value(w.data_utworzenia, 2) over(PARTITION BY k.email order by w.data_utworzenia asc) as Second_result
 from klienci k
 join wnioski w ON w.id = k.id_wniosku
 order by 1



KAMPANIE:

6)  kampanię marketingową, która odbędzie się 26 lutego - przewidywana liczba wniosków z niej to 1000

with moje_daty as (select -- to jest odpowiedzialne za wygenerowanie dat z przyszlosci
  generate_series(
      date_trunc('day', '2018-01-20'::date), -- jaki jest pierwszy dzien generowania
      date_trunc('month', now())+interval '1 month'-interval '1 day', -- koncowy dzien generowania
      '1 day')::date as wygenerowana_data --interwał, co ile dni/miesiecy/tygodni dodawac kolejne rekordy
  ),
  aktualne_wnioski as ( -- to jest kawalek odpowiedzialny za aktualna liczba wnioskow
    select to_char(data_utworzenia, 'YYYY-MM-DD')::date data_wniosku, count(1) liczba_wnioskow
    from wnioski
    group by 1
  ),

lista_z_wnioskami as (select md.wygenerowana_data, -- dla danej daty
  coalesce(aw.liczba_wnioskow,0) liczbawnioskow , -- powiedz ile bylo wnioskow w danym dniu
  sum(aw.liczba_wnioskow) over(order by md.wygenerowana_data) skumulowana_liczba_wnioskow -- laczna liczba wnioskow dzien po dniu
from moje_daty md
left join aktualne_wnioski aw on aw.data_wniosku = md.wygenerowana_data --left join dlatego, ze niektore dni nie maja jeszcze wnioskow. wlasnie dla nich bede robil predykcje
order by 1),

statystyki_dnia as (select to_char (wygenerowana_data, 'Day') dzien, round(avg(liczbawnioskow)) przew
  from lista_z_wnioskami
where wygenerowana_data <= '2018-02-09'
  group by 1
order by 1)

select lw.wygenerowana_data, liczbawnioskow, przew,
  case when wygenerowana_data <= '2018-02-09' then liczbawnioskow
  when wygenerowana_data = '2018-02-26' then 1000
   else przew end,

  sum(case when wygenerowana_data <= '2018-02-09' then liczbawnioskow
  when wygenerowana_data = '2018-02-26' then 1000
  else przew end) over (order by wygenerowana_data) skum_wyg

from lista_z_wnioskami lw
join statystyki_dnia sd on sd.dzien = to_char (lw.wygenerowana_data, 'Day');


7)  przymusową przerwę serwisową, w sobotę 24 lutego nie będzie można utworzyć żadnych wniosków

with moje_daty as (select -- to jest odpowiedzialne za wygenerowanie dat z przyszlosci
  generate_series(
      date_trunc('day', '2018-01-20'::date), -- jaki jest pierwszy dzien generowania
      date_trunc('month', now())+interval '1 month'-interval '1 day', -- koncowy dzien generowania
      '1 day')::date as wygenerowana_data --interwał, co ile dni/miesiecy/tygodni dodawac kolejne rekordy
  ),
  aktualne_wnioski as ( -- to jest kawalek odpowiedzialny za aktualna liczba wnioskow
    select to_char(data_utworzenia, 'YYYY-MM-DD')::date data_wniosku, count(1) liczba_wnioskow
    from wnioski
    group by 1
  ),

lista_z_wnioskami as (select md.wygenerowana_data, -- dla danej daty
  coalesce(aw.liczba_wnioskow,0) liczbawnioskow , -- powiedz ile bylo wnioskow w danym dniu
  sum(aw.liczba_wnioskow) over(order by md.wygenerowana_data) skumulowana_liczba_wnioskow -- laczna liczba wnioskow dzien po dniu
from moje_daty md
left join aktualne_wnioski aw on aw.data_wniosku = md.wygenerowana_data --left join dlatego, ze niektore dni nie maja jeszcze wnioskow. wlasnie dla nich bede robil predykcje
order by 1),

statystyki_dnia as (select to_char (wygenerowana_data, 'Day') dzien, round(avg(liczbawnioskow)) przew
  from lista_z_wnioskami
where wygenerowana_data <= '2018-02-09'
  group by 1
order by 1)

  select lw.wygenerowana_data, liczbawnioskow, przew,

  case when wygenerowana_data <= '2018-02-09' then liczbawnioskow
  when wygenerowana_data = '2018-02-24' then 0
   else przew end,

  sum(case when wygenerowana_data <= '2018-02-09' then liczbawnioskow
  when wygenerowana_data = '2018-02-24' then 0
  else przew end) over (order by wygenerowana_data) skum_wyg

from lista_z_wnioskami lw
join statystyki_dnia sd on sd.dzien = to_char (lw.wygenerowana_data, 'Day');



8) Ile (liczbowo) wniosków zostało utworzonych poniżej mediany liczonej z czasu między lotem i wnioskiem?

with wnioski2 as (select wnioski.id as id, wnioski.data_utworzenia::date - data_wyjazdu::date as roznica
 from wnioski
 join podroze p ON wnioski.id = p.id_wniosku
 join szczegoly_podrozy s2 ON p.id = s2.id_podrozy)

 select percentile_cont(0.5) within group(order by roznica asc) as mediana,
  count(distinct case when roznica < 20 then id end) as licznawnioskowponizej20
  from wnioski2

9) Mając czas od utworzenia wniosku do jego analizy przygotuj statystyke:

with czas as (select wnioski.id as wniosek, wnioski.data_utworzenia as data1, a.data_zakonczenia as data2, a.data_zakonczenia - wnioski.data_utworzenia,
extract(hours from a.data_zakonczenia - wnioski.data_utworzenia) as roznica
 from wnioski
 join analizy_wnioskow a ON wnioski.id = a.id_wniosku
order by roznica ASC )

select percentile_cont(0.5) within group(order by roznica asc) as mediana,
extract(hours from avg(data2 - data1)) as average,
 percentile_cont(0.75) within group(order by roznica asc) as P75,
 percentile_cont(0.25) within group(order by roznica asc) as P25,
  count(distinct case when roznica < 5 then wniosek end) as mniejnizP75,
  count(distinct case when roznica > -2 then wniosek end) as wiecejnizP25,
 count(distinct case when roznica != 0 then wniosek end) as rozne_od_mediany
 from czas




 --

with czas as (select wnioski.id as wniosek, wnioski.data_utworzenia as data1, a.data_zakonczenia as data2, a.data_zakonczenia - wnioski.data_utworzenia, extract(hours from a.data_zakonczenia -
wnioski.data_utworzenia) as roznica
 from wnioski
 join analizy_wnioskow a ON wnioski.id = a.id_wniosku
   WHERE stan_wniosku = 'wyplacony')


select percentile_cont(0.5) within group(order by roznica asc) as mediana,
extract(hours from avg(data2 - data1)) as average,
 percentile_cont(0.75) within group(order by roznica asc) as P75,
 percentile_cont(0.25) within group(order by roznica asc) as P25,
  count(distinct case when roznica < 0 then wniosek end) as mniejnizP75,
  count(distinct case when roznica > -4 then wniosek end) as wiecejnizP25,
 count(distinct case when roznica != -1 then wniosek end) as rozne_od_mediany

 from czas

 ---


with czas as (select wnioski.id as wniosek, wnioski.data_utworzenia as data1, a.data_zakonczenia as data2, a.data_zakonczenia - wnioski.data_utworzenia, extract(hours from a.data_zakonczenia -
wnioski.data_utworzenia) as roznica
 from wnioski
 join analizy_wnioskow a ON wnioski.id = a.id_wniosku
   WHERE stan_wniosku = 'odrzucony po analizie')


select percentile_cont(0.5) within group(order by roznica asc) as mediana,
extract(hours from avg(data2 - data1)) as average,
 percentile_cont(0.75) within group(order by roznica asc) as P75,
 percentile_cont(0.25) within group(order by roznica asc) as P25,
  count(distinct case when roznica < 17 then wniosek end) as mniejnizP75,
  count(distinct case when roznica > 1 then wniosek end) as wiecejnizP25,
  count(distinct case when roznica != 8 then wniosek end) as rozne_od_mediany

 from czas




10) Jakich języków używają klienci? (kolumny: jezyk, liczba klientow, % klientow)
Jak często klient zmienia język (przeglądarki)? (kolumny: email, liczba zmian, czy ostatni jezyk wniosku zgadza sie z pierwszym jezykiem wniosku)


select w.jezyk, count(1),
  round(count(1) / sum(count(1)) over()::numeric, 4) procent
 from wnioski w
join klienci k  ON w.id = k.id_wniosku
group by 1


 select email, count(jezyk) over(partition by email) - 1 as ilezmianjezykow,
     first_value(jezyk) over(partition by email order by w.data_utworzenia asc) pierwszyjezyk,
    first_value(jezyk) over(partition by email order by w.data_utworzenia desc) ostatnijezyk
  from klienci k
   join wnioski w ON w.id = k.id_wniosku


