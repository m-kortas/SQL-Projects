with moje_daty as (select --- daty
  generate_series(
      date_trunc('day', '2018-01-01'::date),
      date_trunc('month', now())+interval '1 month'-interval '1 day',
      interval '1 day')::date as wygenerowana_data
  ),
  historia_opoznien as ( --- liczenie tras opóźnionych 3h i anulowanych
    select to_char(plan_odjazd_dataczas, 'YYYY-MM-DD')::date data_wniosku,
    count(case when czas_opoznienia > 180 OR przylot_status ='CX' then 1 end) liczba_wnioskow
from o_trasy
group by 1
ORDER BY 1 ),

lista_opoznionych as (select md.wygenerowana_data, --- daty i liczba opóźnionych+anulowanych
  coalesce(aw.liczba_wnioskow,0) liczbaopoznionych
  from moje_daty md
left join historia_opoznien aw on aw.data_wniosku = md.wygenerowana_data
order by 1),

predykcja as (select to_char (wygenerowana_data, 'Day') dzien, round(avg(liczbaopoznionych)) przewidywane  --- predykcja
  from lista_opoznionych
where wygenerowana_data <= '2018-02-02'
  group by 1
order by 1)

select lw.wygenerowana_data as data, liczbaopoznionych as danehistoryczne, ---- select: predykcja do końca marca
  case when wygenerowana_data <= '2018-02-02' then  NULL
   else przewidywane end as predykcja
from lista_opoznionych lw
join predykcja sd on sd.dzien = to_char (lw.wygenerowana_data, 'Day');




