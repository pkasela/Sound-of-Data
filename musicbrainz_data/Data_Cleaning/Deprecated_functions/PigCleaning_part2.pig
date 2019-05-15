--To make the gender attribute more readable in artist.tsv

artist = LOAD
 '$SOUND_FOLDER/musicbrainz_data/Data_Cleaning/mbdump/artist.tsv'
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
  gid AS ID, id AS artist_id, gid AS gid;

--reduce attribute of recording and if needed can be used for JOIN

recording = LOAD
  '$SOUND_FOLDER/musicbrainz_data/Data_Cleaning/mbdump/recording.tsv'
USING PigStorage('\t') AS
  (
    id:int, gid:chararray, name:chararray, artist_credit:int,
    length:int, comment:chararray, edits_pending:int,
    last_updated:chararray, video:chararray --(booleano)
  );

recording_cooler = FOREACH recording GENERATE gid AS ID,
    id AS recording_id, gid AS gid, name, length, 'RECORDING' AS LABEL;


--release
release = LOAD
 '$SOUND_FOLDER/musicbrainz_data/Data_Cleaning/mbdump/release.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, artist_credit:int,release_group_id:int,
 status:int, packaging:int, language_id:int, script:int, barcode:chararray,
 comment:chararray, edit_pending:int, quality:int, last_updated:chararray
 );

 release_cooler = FOREACH release GENERATE gid AS ID,
      id AS release_id, gid AS gid;


label = LOAD
 '$SOUND_FOLDER/musicbrainz_data/Data_Cleaning/mbdump/label.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, begin_date_year:int,
 begin_date_month:int, begin_date_day:int, end_date_year:int,
 end_date_month:int, end_date_day:int, label_code:int, type_id:int,
 area:int, comment:chararray, edits_pending:int, last_updated:chararray,
 ended:chararray
 );

 label_cooler = FOREACH label GENERATE gid AS ID,
         id AS label_id, gid AS gid;
--------------------------------------------------------------------------------
-----------------------------RELATION tables----------------------------
----------------------------------------------------------------------



---------HERE LIES artist_recording_cooler

artist_recording = LOAD
  '$SOUND_FOLDER/musicbrainz_data/Data_Cleaning/mbdump/l_artist_recording.tsv'
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

artist_recording_cool = FOREACH artist_recording_art_rec GENERATE
    artist_cooler::ID AS START_ID, recording_cooler::ID AS END_ID,
    'ARTIST_RECORDED' AS TYPE;

artist_recording_cooler = DISTINCT artist_recording_cool;


---------HERE LIES label_recording_cooler

label_recording = LOAD
  '$SOUND_FOLDER/musicbrainz_data/Data_Cleaning/mbdump/l_label_recording.tsv'
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

label_recording_coole = FOREACH label_recording_cool GENERATE
    label_cooler::ID as START_ID,
    recording_cooler::ID AS END_ID, 'SPONSORED_RECORDING' AS TYPE;

label_recording_cooler = DISTINCT label_recording_coole;


---------HERE LIES recording_release_cooler

recording_release = LOAD
  '$SOUND_FOLDER/musicbrainz_data/Data_Cleaning/mbdump/l_recording_release.tsv'
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

recording_release_coole = FOREACH recording_release_cool GENERATE
    recording_cooler::ID as START_ID,
    release_cooler::ID AS END_ID, 'RECORD_IN_RELEASE' AS TYPE;

recording_release_cooler = DISTINCT recording_release_coole;


--------------------------------------------------------------------------------
-----------------------------STORAGE----------------------------------------
----------------------------------------------------------------------

STORE recording_cooler INTO
 '$SOUND_FOLDER/musicbrainz_data/demo_results/pig_recording'
USING PigStorage('\t','-schema');

STORE artist_recording_cooler INTO
 '$SOUND_FOLDER/musicbrainz_data/demo_results/pig_artist_recording'
USING PigStorage('\t','-schema');

------ relationship FILES  ----------

STORE label_recording_cooler INTO
 '$SOUND_FOLDER/musicbrainz_data/demo_results/pig_label_recording'
USING PigStorage('\t','-schema');

STORE recording_release_cooler INTO
 '$SOUND_FOLDER/musicbrainz_data/demo_results/pig_recording_release'
USING PigStorage('\t','-schema');
