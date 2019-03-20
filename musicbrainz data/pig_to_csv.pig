-- Pig Script

artist = LOAD
'/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/artist.tsv'
USING PigStorage('\t') AS
(
id,gid,name,sort_name,begin_date_year,begin_date_month,begin_date_day,
end_date_year,end_date_month,end_date_day,type,area,gender:chararray,comment,
edits_pending,last_updated,ended,begin_area,end_area
);


artist_cool = FOREACH artist GENERATE
  id, gid, name, sort_name, type,area,
  REPLACE(REPLACE(REPLACE(REPLACE(gender,'4','Not Applicable'),
  '3','Other'),'2','Female'),'1','Male') AS gender,ended;

--esempio di limit cosi ricordo la sintassi
--artist_lim = LIMIT artist 5;


--per avere uno UDF (User Defined Function) in PIG:
--DEFINE test `pig_to_csv.py` SHIP('pig_to_csv.py');


STORE artist_cool INTO
'/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/artist_pig'
USING PigStorage('\t','-schema');

--STORE artist_cool INTO '<path>'
--USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE',
--                                             'UNIX', 'WRITE_OUTPUT_HEADER');
