


with operatorzy as (
    select
  case when kod_polaczenia like 'EX%' then 'EX'
   when kod_polaczenia  like 'IN%' then 'IN'
   when kod_polaczenia  like 'KO%' then 'KO'
   when kod_polaczenia  like 'TL%' then 'TL' end as OPERATOR,
  kod_polaczenia,
  liczba_miejsce, /* ilośc pasażerów */
  rekompensata,
  plan_odjazd_dataczas, /* Wymagana możliwość filtrowania po czasie trasy */
  count(case when czy_uprawniony IS not NULL then 1 end)*o_trasy.liczba_miejsce as suma_uprawnionych, /* suma pasażerów uprawnionych do rekompensaty */
  rekompensata*count(case when czy_uprawniony IS not NULL then 1 end)*o_trasy.liczba_miejsce as calkowitarekomensata, /* całkowita wartość rekompensaty */
  count(case when o_trasy.czas_opoznienia = 0 then 1 end) naczas,
  count(case when o_trasy.wylot_status = 'CX' then 1 end) anulowany,
  count(case when o_trasy.czas_opoznienia > 180 then 1 end) opozniony,
  count(case when czy_uprawniony IS not NULL then 1 end) uprawniony
  from o_trasy
  GROUP BY 1,2,3,4,5
)


select OPERATOR,
  count(kod_polaczenia) as ilosc_wyk_tras, /* ilość wykonanych tras */
  sum(liczba_miejsce) ilosc_pas,  /* ilośc pasażerów */
  sum(suma_uprawnionych) suma_pasaz_uprawn, /* suma pasażerów uprawnionych do rekompensaty */
  sum(calkowitarekomensata) calkowit_rekompen, /* całkowita wartość rekompensaty */
  round(sum(naczas)/count(kod_polaczenia)::NUMERIC, 2) procent_na_czas  /* % tras na czas (w miejscu docelowym) */ ,
  round(sum(anulowany)/count(kod_polaczenia)::NUMERIC, 2) procent_anulowanych/* % tras anulowanych */ ,
  round(sum(opozniony)/count(kod_polaczenia)::NUMERIC, 2) procent_opoznionych /* % tras opóźnionych >3h */ ,
  round(sum(uprawniony)/count(kod_polaczenia)::NUMERIC, 2)  procent_uprawnionych /* % tras uprawnionych do rekompensaty */
  from operatorzy
  GROUP BY  1



