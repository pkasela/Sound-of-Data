-- Pig Script in local later will be changed to work on HDFS
-- Or I will create a different one or will use the local one

--------------------------------------------------------------------------------
-----------------------------TABLES----------------------------------------
----------------------------------------------------------------------

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

---------HERE LIES artist_label_cooler

artist_label = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/l_artist_label.tsv'
USING PigStorage('\t') AS
  (
    id:chararray, link_id:int, artist_id:int, label_id:int,
    edits_pending:int, last_updated:chararray, link_order:int,
    artist_credit:chararray, label_credit:chararray
  );

  artist_label_red = FOREACH artist_label GENERATE artist_id, label_id;

  artist_label_art = JOIN artist_label_red BY artist_id,
                          artist_cooler BY artist_id;

  artist_label_art_lab = JOIN artist_label_art BY label_id,
                                  label_cooler BY label_id;

  artist_label_cooler = FOREACH artist_label_art_lab GENERATE
      artist_cooler::ID AS START_ID, label_cooler::ID AS END_ID,
      'ARTIST_LABEL' AS TYPE;

---------HERE LIES artist_recording_cooler

artist_recording = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/l_artist_recording.tsv'
USING PigStorage('\t') AS
  (
    id:chararray, link_id:int, artist_id:int, recording_id:int,
    edits_pending:int, last_updated:chararray, link_order:int,
    artist_credit:chararray, recording_credit:chararray
  );

artist_recording_red = FOREACH artist_recording GENERATE
    artist_id, recording_id;

artist_recording_art = JOIN artist_recording_red BY artist_id,
                                artist_cooler BY artist_id;

artist_recording_art_rec = JOIN artist_recording_art BY recording_id,
                                recording_cooler BY recording_id;

artist_recording_cooler = FOREACH artist_recording_art_rec GENERATE
    artist_cooler::ID AS START_ID, recording_cooler::ID AS END_ID,
    'ARTIST_RECORDED' AS TYPE;

---------HERE LIES artist_release_cooler

artist_release = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/l_artist_release.tsv'
USING PigStorage('\t') AS
  (
    id:chararray, link_id:int, artist_id:int, release_id:int,
    edits_pending:int, last_updated:chararray, link_order:int,
    artist_credit:chararray, release_credit:chararray
  );

  artist_release_red = FOREACH artist_release GENERATE
      artist_id, release_id;

  artist_release_art = JOIN artist_release_red BY artist_id,
                                  artist_cooler BY artist_id;

  artist_release_art_rel = JOIN artist_release_art BY release_id,
                                  release_cooler BY release_id;

  artist_release_cooler = FOREACH artist_release_art_rel GENERATE
      artist_cooler::ID AS START_ID, release_cooler::ID AS END_ID,
      'ARTIST_RELEASED' AS TYPE;

---------HERE LIES label_recording_cooler

label_recording = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/l_label_recording.tsv'
USING PigStorage('\t') AS
  (
    id:chararray, link_id:int, label_id:int, recording_id:int,
    edits_pending:int, last_updated:chararray, link_order:int,
    label_credit:chararray, release_credit:chararray
  );

label_recording_red = FOREACH label_recording GENERATE label_id, recording_id;

label_recording_cold = JOIN label_recording_red BY recording_id,
                      recording_cooler BY recording_id;

label_recording_cool = JOIN label_recording_cold BY label_id,
                     label_cooler BY label_id;

label_recording_cooler = FOREACH label_recording_cool GENERATE
    label_cooler::ID as START_ID,
    recording_cooler::ID AS END_ID, 'SPONSORED_RECORDING' AS TYPE;

---------HERE LIES label_release_cooler

label_release = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/l_label_release.tsv'
USING PigStorage('\t') AS
  (
    id:chararray, link_id:int, label_id:int, release_id:int,
    edits_pending:int, last_updated:chararray, link_order:int,
    label_credit:chararray, release_credit:chararray
  );

label_release_red = FOREACH label_release GENERATE label_id, release_id;

label_release_cold = JOIN label_release_red BY release_id,
                      release_cooler BY release_id;

label_release_cool = JOIN label_release_cold BY label_id,
                     label_cooler BY label_id;

label_release_cooler = FOREACH label_release_cool GENERATE
    label_cooler::ID as START_ID,
    release_cooler::ID AS END_ID, 'SPONSORED_RELEASE' AS TYPE;

---------HERE LIES recording_release

recording_release = LOAD
  '$SOUND_FOLDER/musicbrainz data/Data_Cleaning/mbdump/l_recording_release.tsv'
USING PigStorage('\t') AS
  (
    id:chararray, link_id:int, recording_id:int, release_id:int,
    edits_pending:int, last_updated:chararray, link_order:int,
    label_credit:chararray, release_credit:chararray
  );

recording_release_red = FOREACH recording_release GENERATE
    recording_id, release_id;

recording_release_cold = JOIN recording_release_red BY release_id,
                      release_cooler BY release_id;

recording_release_cool = JOIN recording_release_cold BY recording_id,
                     recording_cooler BY recording_id;

recording_release_cooler = FOREACH recording_release_cool GENERATE
    recording_cooler::ID as START_ID,
    release_cooler::ID AS END_ID, 'RECORD_IN_RELEASE' AS TYPE;

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

------ relationship FILES  ----------

STORE artist_label_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_artist_label'
USING PigStorage('\t','-schema');

STORE artist_recording_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_artist_recording'
USING PigStorage('\t','-schema');

STORE artist_release_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_artist_release'
USING PigStorage('\t','-schema');

STORE label_recording_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_label_recording'
USING PigStorage('\t','-schema');

STORE label_release_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_label_release'
USING PigStorage('\t','-schema');

STORE recording_release_cooler INTO
 '$SOUND_FOLDER/musicbrainz data/demo_results/pig_recording_release'
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
-- recording

-- remaining shell script for cat and sed*

--*Only problem is that the columns can't start with `:' like in JAVA -.-
--thus will use sed on the .pig_header in the main script(.sh)
