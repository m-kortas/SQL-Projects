create table rynek2 (
  Id_rynek serial primary key,
  kraj text,
  region text,
  jezyk text,
  wartosc INTEGER);

create table release3 (
  id_release serial PRIMARY KEY,
  opis text,
  datarel date,
  funcjonalnosc text);

create table rynki4_release (
  id_rynek_release serial PRIMARY KEY,
  data date,
  id_rynek INTEGER,
  id_release INTEGER,
  FOREIGN KEY (id_rynek) REFERENCES rynek2,
  FOREIGN KEY (id_release) REFERENCES release3);

insert into rynek2 (kraj, region, jezyk, wartosc) values ('Bhutan', 'Asia', 'Bhutanese', 5000);
insert into rynek2 (kraj, region, jezyk, wartosc) values ('Costa Rica', 'Americas', 'Spanish', 3000);

insert into release3 (opis, datarel, funcjonalnosc) values ('blabla1', '2017/09/09', 'flying');
insert into release3 (opis, datarel, funcjonalnosc) values ('blabla2', '2017/09/09', 'swimming');

insert into rynki4_release (data, id_rynek, id_release) values ('2011/06/06', 1, 2);
insert into rynki4_release (data, id_rynek, id_release) values ('2012/05/06', 2, 1);
insert into rynki4_release (data, id_rynek, id_release) values ('2017/08/09', 1, 2);
insert into rynki4_release (data, id_rynek, id_release) values ('2017/09/09', 2, 1);
insert into rynki4_release (data, id_rynek, id_release) values ('2017/07/31', 1, 2);
insert into rynki4_release (data, id_rynek, id_release) values ('2017/08/20', 2, 1);



/* liczba releasów w danym reginie */

SELECT region, count(r3.id_release) as iloscreleasow
FROM rynki4_release
JOIN rynek2 r ON rynki4_release.id_rynek = r.Id_rynek
JOIN release3 r3 ON rynki4_release.id_release = r3.id_release
GROUP BY region;

/* średni czas od pierwszego do kolejnego release w danym rynku */

select
b.*,
((release2::date - release1::date) + (release3::date - release2::date) + (release4::date - release3::date) + (release5::date - release4::date)) / 4 as averagetime
from (select
        kraj,
        max(case when rn = 1 then data end) as release1,
        max(case when rn = 2 then data end) as release2,
        max(case when rn = 3 then data end) as release3,
        max(case when rn = 4 then data end) as release4,
        max(case when rn = 5 then data end) as release5
        from (SELECT kraj, data,
                row_number() over (partition by kraj order by data) as rn                FROM rynki4_release
                JOIN rynek2 r ON rynki4_release.id_rynek = r.Id_rynek
                JOIN release3 r3 ON rynki4_release.id_release = r3.id_release
                Order by kraj, data
                ) a
        group by kraj
) b;

/* lista release z trzeciego kwartału 2017 */

SELECT r3.id_release, data
FROM rynki4_release
JOIN rynek2 r ON rynki4_release.id_rynek = r.Id_rynek
JOIN release3 r3 ON rynki4_release.id_release = r3.id_release
WHERE data > '2017/07/01' and data < '2017/09/30';

/* lista rynków azjatyckich posiadających więcej niż 4 release */

SELECT kraj, region, COUNT(r3.id_release) as iloscreleasow
FROM rynki4_release
JOIN rynek2 r ON rynki4_release.id_rynek = r.Id_rynek
JOIN release3 r3 ON rynki4_release.id_release = r3.id_release
WHERE region = 'Asia'
GROUP BY kraj, region
Having COUNT(r3.id_release) > 4;
