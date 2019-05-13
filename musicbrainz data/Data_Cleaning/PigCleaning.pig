-- Pig Script in local later will be changed to work on HDFS
-- Or I will create a different one

--To make the gender attribute more readable in artist.tsv

artist = LOAD
 '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/artist.tsv'
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
-- yeah, it's very cool! C:
artist_cooler = FOREACH artist GENERATE
  gid AS ID, id AS artist_id, name,
  -- very very VERY  V E R Y  cool
  REPLACE(REPLACE(REPLACE(REPLACE(gender,'4','Not Applicable'),
  '3','Other'),'2','Female'),'1','Male') AS gender,
  type, 'ARTIST' AS LABEL;
--Avoided use of join here since we needed only a few REPLACE which takes
--O(n) time while the join is if I remember correctly O(n*m)
-- where n <-nrow(table_1) and m <-nrow(table_2)

--combine release and language
release = LOAD
 '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/release.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, artist_credit:int,release_group:int,
 status:int, packaging:int, language_id:int, script:int, barcode:chararray,
 comment:chararray, edit_pending:int, quality:int, last_updated:chararray
 );

language = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/language.tsv'
USING PigStorage('\t') AS
 (
 id:int, iso_code_2t:chararray, iso_code_2b:chararray, iso_code_1:chararray,
 language:chararray, frequency:int, iso_code_3:chararray
 );
--From language We need only the id and name(called language here)
language_red = FOREACH language GENERATE id,language;--red = reduced
--Left Join the two tables release and language
release_cool = JOIN release BY language_id LEFT OUTER, language_red BY id;
release_cooler = FOREACH release_cool GENERATE gid AS ID,
     release::id AS release_id,
     name AS name, release_group AS release_group,
     language_red::language AS language, 'RELEASE' AS LABEL;

--combine label and label_type

label = LOAD
 '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/label.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, begin_date_year:int,
 begin_date_month:int, begin_date_day:int, end_date_year:int,
 end_date_month:int, end_date_day:int, label_code:int, type_id:int,
 area:int, comment:chararray, edits_pending:int, last_updated:chararray,
 ended:chararray
 );

label_type = LOAD
'$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/label_type.tsv'
USING PigStorage('\t') AS
 (
 id:int, name:chararray, parent:int, child_order:int,
 description: chararray, gid:chararray
 );

label_cool = JOIN label BY type_id LEFT OUTER, label_type BY id;

label_cooler = FOREACH label_cool GENERATE label::gid AS ID,
        label::id AS label_id, label::name AS name,
        label_type::name AS type, 'LABEL' AS LABEL;

--reduce attribute of recording and if needed can be used for JOIN

recording = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/recording.tsv'
USING PigStorage('\t') AS
  (
    id:int, gid:chararray, name:chararray,
    artist_credit:int,
    length:int,
    comment:chararray,
    edits_pending:int,
    last_updated:chararray,
    video:chararray --(booleano)
  );

recording_cooler = FOREACH recording GENERATE gid AS ID,
    id AS recording_id, name, length, 'RECORDING' AS LABEL;

--------------------------------------------------------------------------------
-----------------------------RELATION tables----------------------------
----------------------------------------------------------------------

---------HERE LIES artist_recording_cooler
artist_recording = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/l_artist_recording'
USING PigStorage('\t') AS
  (
    id:chararray, link_id:int, artist_id:int, recording_id:int,
    edits_pending:int, last_updated:chararray, link_order:int,
    artist_credit:chararray, recording_credit:chararray
  );

artist_recording_freeze = FOREACH artist_recording GENERATE
    artist_id, recording_id;

artist_recording_art = JOIN artist_recording_freeze BY artist_id,
                                artist_cooler BY artist_id;

artist_recording_art_rec = JOIN artist_recording_art BY recording_id,
                                recording_cooler BY recording_id;

artist_recording_cooler = FOREACH artist_recording_art_rec GENERATE
    artist_cooler::ID AS START_ID, recording_cooler::ID AS END_ID,
    'ARTIST_RECORDED' AS TYPE;
/*
---------HERE LIES release_artist_credit_cooler
release_artist_credit_cooler = FOREACH release GENERATE gid AS START_ID,
    artist_credit AS END_ID, 'RELEASED' AS TYPE;
*/

---------HERE LIES release_label
release_label = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/release_label.tsv'
USING PigStorage('\t') AS
 (
  id:int, release:int, label:int, catlog_number:chararray,
  last_updated:chararray
 );

release_label_red = FOREACH release_label GENERATE id, release, label;

release_label_cold = JOIN release_label BY release, release_cooler BY release_id;

release_label_colder = FOREACH release_label_cold GENERATE id,
    release_cooler::ID AS release, label;

release_label_cool = JOIN release_label_colder BY label,
                     label_cooler BY label_id;

release_label_cooler = FOREACH release_label_cool GENERATE release as START_ID,
    label_cooler::ID AS END_ID, 'SPONSORED_BY' AS TYPE;



--------------------------------------------------------------------------------
-----------------------------STORAGE----------------------------------------
----------------------------------------------------------------------


--Save the data creating a new folder with the HEADER in the file .pig_header
STORE artist_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_artist'
USING PigStorage('\t','-schema');

STORE release_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_release'
USING PigStorage('\t','-schema');

STORE label_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_label'
USING PigStorage('\t','-schema');

STORE recording_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_recording'
USING PigStorage('\t','-schema');

/*
STORE artist_credit_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_artist_credit'
USING PigStorage('\t','-schema');
*/
------ relationship FILES  ----------
/*
STORE artist_artist_credit_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_artist_artist_credit'
USING PigStorage('\t','-schema');

STORE track_artist_credit_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_track_artist_credit'
USING PigStorage('\t','-schema');

STORE release_artist_credit_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_release_artist_credit'
USING PigStorage('\t','-schema');
*/
STORE release_label_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_release_label'
USING PigStorage('\t','-schema');

STORE artist_recording_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_artist_recording'
USING PigStorage('\t','-schema');


--followed by cat .pig_header part* > combined_file.tsv on shell
--As MoMo says cat works at the speed of light

--Another nice way to store the file
--STORE artist_cool INTO '<path>'
--USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE',
--                                             'UNIX', 'WRITE_OUTPUT_HEADER');
--                        ^
-- no, it is not nice D: what the fu*k is it?
-- @MoMo It's a piggybank hahaha, it's a function of java and
-- It saves the file with HEADER at the top:
--   HEADER1, HEADER2, HEADER3,...
--   Values1, Values2, Values3,...
-- The only problem is that if we have the file partitioned in more
-- parts we will have each part with a header of it's own (might be useful)

--Just an example on how to use LIMIT in PIG
-- artist_lim = LIMIT artist 5;

--For a UDF (User Defined Function) in PIG:
-- write a magic comment on the top of the python file:
--#! /path/to/env python<ver>
--DEFINE test `test.py` SHIP('test.py');
-- after defining the script to execute it on the data A use:
--B = STREAM A THROUGH test;

--Done stuff for:
-- artist <- gender(with REPLACE) and artist_alias
-- release <- language
-- label <- label_type
-- track

-- remaining shell script for cat and sed*
-- artist_release
-- release_track
-- release_label

--*Only problem is that the columns can't start with `:' like in JAVA -.-
--thus will use sed on the .pig_header in the main script(.sh)
