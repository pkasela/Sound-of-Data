-- Pig Script in local later will be changed to work on HDFS
-- Or I will create a different one

--To make the gender attribute more readable in artist.tsv
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

--FOREACH a GENERATE is kind of of a filter on columns
artist_cooler = FOREACH artist GENERATE
  id, gid, name, sort_name, type,area,
  REPLACE(REPLACE(REPLACE(REPLACE(gender,'4','Not Applicable'),
  '3','Other'),'2','Female'),'1','Male') AS gender,ended;
--Avoided use of join here since we needed only a few REPLACE which takes
--O(n) time while the join is if I remember correctly O(n^2)

--reduce the arrtibutes of artist_alias
artist_alias = LOAD
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/artist_alias.tsv'
USING PigStorage('\t') AS
 (
  id:int, artist:int, name:chararray, local:chararray, edit_pending:int,
  last_updated:chararray, type:int, sort_name:chararray,
  begin_date_year:int, begin_date_month:int, begin_date_day:int,
  end_date_year:int, end_date_month:int, end_date_day:int,
  primary_for_locale:chararray, ended:chararray
 );

artist_alias_cooler = FOREACH artist_alias GENERATE id, artist, name, sort_name,
       type, ended;


--combine release and language
release = LOAD
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/release.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, artist_credit:int,release_group:int,
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

--combine label and label_type

label = LOAD
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/label.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, begin_date_year:int,
 begin_date_month:int, begin_date_day:int, end_date_year:int,
 end_date_month:int, end_date_day:int, label_code:int, type_id:int,
 area:int, comment:chararray, edits_pending:int, last_updated:chararray,
 ended:chararray
 );

label_type = LOAD
'/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/label_type.tsv'
USING PigStorage('\t') AS
 (
 id:int, name:chararray, parent:int, child_order:int,
 description: chararray, gid:chararray
 );

label_cool = JOIN label BY type_id LEFT OUTER, label_type BY id;

label_cooler = FOREACH label_cool GENERATE label::id AS id, label::gid AS gid,
        label::name AS name, label_type::name AS type;

--reduce attribute of track and if needed can be used for JOIN
-- Because I think we decided not to consider the medium & medium_format
track = LOAD
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/track.tsv'
USING PigStorage('\t') AS
 (
  id:int, gid:chararray, recording:int, medium:int, position:int,
  number:chararray, name:chararray, artist_credit:int, lenght:int,
  edits_pending:int, last_updated:chararray, is_data_track:chararray
 );

track_cooler = FOREACH track GENERATE id, gid, name, artist_credit, lenght;
                                --(keep or not ??is_data_track??)


--------------------------------------------------------------------------------
-----------------------------STORAGE----------------------------------------
----------------------------------------------------------------------


--Save the data creating a new folder with the HEADER in the file .pig_header
STORE artist_cooler INTO
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/pig_artist'
USING PigStorage('\t','-schema');

STORE artist_alias_cooler INTO
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/pig_artist_alias'
USING PigStorage('\t','-schema');

STORE release_cooler INTO
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/pig_release'
USING PigStorage('\t','-schema');

STORE label_cooler INTO
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/pig_label'
USING PigStorage('\t','-schema');

STORE track_cooler INTO
 '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/pig_track'
USING PigStorage('\t','-schema');
--followed by cat .pig_header file_1 ... file_n > combined_file.tsv on shell
--As MoMo says it works at the speed of light

--Another nice way to store the file
--STORE artist_cool INTO '<path>'
--USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE',
--                                             'UNIX', 'WRITE_OUTPUT_HEADER');

--Just an example on how to use LIMIT in PIG
--artist_lim = LIMIT artist 5;

-- For a UDF (User Defined Function) in PIG:
--write a magic comment on the top of the python file:
-- #! /path/to/env python<ver>
--DEFINE test `test.py` SHIP('test.py');
--after defining the script to execute it on the data A use:
--B = STREAM A THROUGH test;

--Done stuff for:
-- artist, artist_alias, release <- language, label <- label_type, track
--cat remaining for artist_alias and track
