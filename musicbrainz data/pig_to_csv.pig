-- Pig Script in local later will be changed to work on HDFS

--To make the gender attribute more readable
artist = LOAD
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/artist.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, sort_name:chararray,
 begin_date_year:int, begin_date_month:int, begin_date_day:int,
 end_date_year:int, end_date_month:int, end_date_day:int,
 type:int, area:int, gender:chararray, comment:chararray,
 edits_pending:int, last_updated:chararray, ended:chararray,
 begin_area:int, end_area:int
 );

artist_cooler = FOREACH artist GENERATE
  id, gid, name, sort_name, type,area,
  REPLACE(REPLACE(REPLACE(REPLACE(gender,'4','Not Applicable'),
  '3','Other'),'2','Female'),'1','Male') AS gender,ended;
--Avoided use of join here since we needed only a few REPLACE which takes
--O(n) time while the join is if I remember correctly O(n^2)

--combine release and language
release = LOAD
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/release.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:int, name:chararray, artist_credit:int,release_group:int,
 status:int, packaging:int, language_id:int, script:int, barcode:chararray,
 comment:chararray, edit_pending:int, quality:int, last_updated:chararray
 );

language = LOAD
  '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/language.tsv'
USING PigStorage('\t') AS
 (
 id:int, iso_code_2t:chararray, iso_code_2b:chararray, iso_code_1:chararray,
 language:chararray, frequency:int, iso_code_3:chararray
 );
--From language We need only the id and name(called language here)
language_red = FOREACH language GENERATE id,language;
--Left Join the two tables release and language
release_cool = JOIN release BY language_id LEFT OUTER, language_red BY id;
release_cooler = FOREACH release_cool GENERATE release::id AS id, gid AS gid,
     name AS name,artist_credit AS artist_credit,
     release_group AS release_group, language_red::language AS language;

STORE artist_cooler INTO
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/artist_pig'
USING PigStorage('\t','-schema');

STORE release_cooler INTO
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/release_pig'
USING PigStorage('\t','-schema');

DESCRIBE artist_cooler;
DESCRIBE release_cooler;

--followed by cat -pig_HEADER file_1 ... file_n > combined_file.tsv on shell
--As MoMo says it works at the speed of light

--un modo carino di salvare i dati
--STORE artist_cool INTO '<path>'
--USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE',
--                                             'UNIX', 'WRITE_OUTPUT_HEADER');

--esempio di limit cosi ricordo la sintassi
--artist_lim = LIMIT artist 5;


--per avere uno UDF (User Defined Function) in PIG:
--mettere all'inizio del file python il commento magico:
-- #! /path/to/env python<ver>
--DEFINE test `test.py` SHIP('test.py');
--poi avremmo un comando simile a
--B = STREAM A THROUGH test;
