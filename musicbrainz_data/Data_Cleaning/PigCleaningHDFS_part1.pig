-- Pig Script in local later will be changed to work on HDFS
-- Or I will create a different one or will use the local one

--------------------------------------------------------------------------------
-----------------------------TABLES----------------------------------------
----------------------------------------------------------------------

--To make the gender attribute more readable in artist.tsv

artist = LOAD
 '/mbdump/artist.tsv'
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
  gid AS ID, id AS artist_id, gid AS gid, name,
  -- very very VERY  V E R Y  cool
  REPLACE(REPLACE(REPLACE(REPLACE(gender,'4','Not Applicable'),
  '3','Other'),'2','Female'),'1','Male') AS gender,
  type, 'ARTIST' AS LABEL;
--Avoided use of join here since we needed only a few REPLACE which takes
--O(n) time while the join is if I remember correctly O(n*m)
-- where n <-nrow(table_1) and m <-nrow(table_2)

--combine label and label_type

label = LOAD
 '/mbdump/label.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, begin_date_year:int,
 begin_date_month:int, begin_date_day:int, end_date_year:int,
 end_date_month:int, end_date_day:int, label_code:int, type_id:int,
 area:int, comment:chararray, edits_pending:int, last_updated:chararray,
 ended:chararray
 );

label_type = LOAD
'/mbdump/label_type.tsv'
USING PigStorage('\t') AS
 (
 id:int, name:chararray, parent:int, child_order:int,
 description: chararray, gid:chararray
 );

label_cool = JOIN label BY type_id LEFT OUTER, label_type BY id;

label_cooler = FOREACH label_cool GENERATE label::gid AS ID,
        label::id AS label_id, label::gid AS gid, label::name AS name,
        label_type::name AS type, 'LABEL' AS LABEL;

--combine release and language
release = LOAD
 '/mbdump/release.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, artist_credit:int,release_group_id:int,
 status:int, packaging:int, language_id:int, script:int, barcode:chararray,
 comment:chararray, edit_pending:int, quality:int, last_updated:chararray
 );

language = LOAD
  '/mbdump/language.tsv'
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
     release::id AS release_id, gid AS gid,
     name AS name, release_group_id AS release_group_id,
     language_red::language AS language, 'RELEASE' AS LABEL;

-- Release Group is cleaned here
release_group = LOAD
  '/mbdump/release_group.tsv'
USING PigStorage('\t') AS
  (
   id:int, gid:chararray, name:chararray, artist_credit:int,
   type:int, comment:chararray, edits_pending:int, last_updated:chararray
  );

release_group_cooler = FOREACH release_group GENERATE gid AS ID,
    id AS release_group_id, gid AS gid, name;
--------------------------------------------------------------------------------
-----------------------------RELATION tables----------------------------
----------------------------------------------------------------------

---------HERE LIES artist_label_cooler

artist_label = LOAD
  '/mbdump/l_artist_label.tsv'
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

artist_label_cool = FOREACH artist_label_art_lab GENERATE
      artist_cooler::ID AS START_ID, label_cooler::ID AS END_ID,
      'ARTIST_LABEL' AS TYPE;

artist_label_cooler = DISTINCT artist_label_cool;

---------HERE LIES artist_release_cooler

artist_release = LOAD
  '/mbdump/l_artist_release.tsv'
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

artist_release_cool = FOREACH artist_release_art_rel GENERATE
    artist_cooler::ID AS START_ID, release_cooler::ID AS END_ID,
    'ARTIST_RELEASED' AS TYPE;

artist_release_cooler = DISTINCT artist_release_cool;

---------HERE LIES artist_release_group_cooler

artist_release_group = LOAD
  '/mbdump/l_artist_release_group.tsv'
USING PigStorage('\t') AS
  (
    id:chararray, link_id:int, artist_id:int, release_group_id:int,
    edits_pending:int, last_updated:chararray, link_order:int,
    artist_credit:chararray, release_credit:chararray
  );

artist_release_group_red = FOREACH artist_release_group GENERATE
    artist_id, release_group_id;

artist_release_group_art = JOIN artist_release_group_red BY artist_id,
                                artist_cooler BY artist_id;

artist_release_group_art_rel = JOIN artist_release_group_art BY release_group_id,
                                release_group_cooler BY release_group_id;

artist_release_group_cool = FOREACH artist_release_group_art_rel GENERATE
    artist_cooler::ID AS START_ID, release_group_cooler::ID AS END_ID,
    'ARTIST_RELEASED_GROUP' AS TYPE;

artist_release_group_cooler = DISTINCT artist_release_group_cool;

---------HERE LIES label_release_cooler (actually release_label)

label_release = LOAD
  '/mbdump/release_label.tsv'
USING PigStorage('\t') AS
(
 id:int, release_id:int, label_id:int, catlog_number:chararray,
 last_updated:chararray
);

label_release_red = FOREACH label_release GENERATE label_id, release_id;

label_release_cold = JOIN label_release_red BY release_id,
                      release_cooler BY release_id;

label_release_cool = JOIN label_release_cold BY label_id,
                     label_cooler BY label_id;

label_release_coole = FOREACH label_release_cool GENERATE
    label_cooler::ID as START_ID,
    release_cooler::ID AS END_ID, 'SPONSORED_RELEASE' AS TYPE;

label_release_cooler = DISTINCT label_release_coole;

---------HERE LIES release_release_group_cooler
release_release_group = JOIN release_cooler by release_group_id,
                        release_group_cooler by release_group_id;

release_release_group_cool = FOREACH release_release_group GENERATE
    release_cooler::gid AS START_ID, release_group_cooler::gid AS END_ID,
    'RELEASE_IN_GROUP' AS TYPE;

release_release_group_cooler = DISTINCT release_release_group_cool;

--------------------------------------------------------------------------------
-----------------------------STORAGE----------------------------------------
----------------------------------------------------------------------


--Save the data creating a new folder with the HEADER in the file .pig_header

STORE artist_cooler INTO
 '/demo_results/pig_artist'
USING PigStorage('\t','-schema');

STORE label_cooler INTO
 '/demo_results/pig_label'
USING PigStorage('\t','-schema');

STORE release_cooler INTO
 '/demo_results/pig_release'
USING PigStorage('\t','-schema');

STORE release_group_cooler INTO
 '/demo_results/pig_release_group'
USING PigStorage('\t','-schema');

------ relationship FILES  ----------

STORE artist_label_cooler INTO
 '/demo_results/pig_artist_label'
USING PigStorage('\t','-schema');

STORE artist_release_cooler INTO
 '/demo_results/pig_artist_release'
USING PigStorage('\t','-schema');

STORE artist_release_group_cooler INTO
 '/demo_results/pig_artist_release_group'
USING PigStorage('\t','-schema');

STORE label_release_cooler INTO
 '/demo_results/pig_release_label'
USING PigStorage('\t','-schema');

STORE release_release_group_cooler INTO
 '/demo_results/pig_release_release_group'
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

--To count the rows of a `table' do
-- Total_Rows = FOREACH (GROUP table ALL) GENERATE COUNT(table);


--*Only problem in PIG is that the columns can't start with `:' like in JAVA :(
--thus will use sed on the .pig_header in the main script(.sh)
