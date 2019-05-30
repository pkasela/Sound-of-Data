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

artist_cooler = FOREACH artist GENERATE id AS artist_id, gid AS gid;


release = LOAD
 '/mbdump/release.tsv'
USING PigStorage('\t') AS
 (
 id:int, gid:chararray, name:chararray, artist_credit:int,release_group_id:int,
 status:int, packaging:int, language_id:int, script:int, barcode:chararray,
 comment:chararray, edit_pending:int, quality:int, last_updated:chararray
 );

release_cooler = FOREACH release GENERATE id AS release_id, gid AS gid;

recording = LOAD
   '/mbdump/recording.tsv'
USING PigStorage('\t') AS
   (
     id:int, gid:chararray, name:chararray, artist_credit:int,
     length:int, comment:chararray, edits_pending:int,
     last_updated:chararray, video:chararray --(booleano)
   );

recording_cooler = FOREACH recording GENERATE id AS recording_id, gid AS gid;

tag = LOAD '/mbdump/tag.tsv' USING PigStorage('\t') AS (tag_id:int,tag:int);

tag_cooler = FOREACH tag GENERATE tag_id AS ID, tag as GENRE, 'GENRE' AS LABEL;

-------------- Main Loading is Done ---------

--artist_tag

artist_tag = LOAD
  '/mbdump/artist_tag.tsv'
USING PigStorage('\t') AS
  (
    artist_id:int, tag_id:int, count:int, last_updated:chararray
  );

artist_tag_cold   = FOREACH artist_tag GENERATE artist_id, tag_id;
artist_tag_colder = JOIN  artist_cooler BY artist_id,
                          artist_tag_cold BY artist_id;

artist_tag_cool   = JOIN artist_tag_colder BY tag_id, tag BY tag_id;
artist_tag_cooler = FOREACH artist_tag_cool GENERATE gid AS START_ID,
    tag::tag_id AS END_ID, 'GENRE' AS TYPE;




--recording_tag

recording_tag = LOAD
  '/mbdump/recording_tag.tsv'
USING PigStorage('\t') AS
  (
    recording_id:int, tag_id:int, count:int, last_updated:chararray
  );

recording_tag_cold   = FOREACH recording_tag GENERATE recording_id, tag_id;
recording_tag_colder = JOIN  recording_cooler BY recording_id,
                          recording_tag_cold BY recording_id;

recording_tag_cool   = JOIN recording_tag_colder BY tag_id, tag BY tag_id;

recording_tag_cooler = FOREACH recording_tag_cool GENERATE gid AS START_ID,
    tag::tag_id AS END_ID, 'GENRE' AS TYPE;

--release_Tag

release_tag = LOAD
  '/mbdump/release_tag.tsv'
USING PigStorage('\t') AS
  (
    release_id:int, tag_id:int, count:int, last_updated:chararray
  );

release_tag_cold   = FOREACH release_tag GENERATE release_id, tag_id;
release_tag_colder = JOIN  release_cooler BY release_id,
                          release_tag_cold BY release_id;
release_tag_cool   = JOIN release_tag_colder BY tag_id, tag BY tag_id;
release_tag_cooler = FOREACH release_tag_cool GENERATE gid AS START_ID,
    tag::tag_id AS END_ID, 'GENRE' AS TYPE;


---------STORE the files
STORE tag_cooler INTO
 '/demo_results/pig_tag'
USING PigStorage('\t','-schema');

STORE artist_tag_cooler INTO
 '/demo_results/pig_artist_tag'
USING PigStorage('\t','-schema');

STORE recording_tag_cooler INTO
 '/demo_results/pig_recording_tag'
USING PigStorage('\t','-schema');

STORE release_tag_cooler INTO
 '/demo_results/pig_release_tag'
USING PigStorage('\t','-schema');
