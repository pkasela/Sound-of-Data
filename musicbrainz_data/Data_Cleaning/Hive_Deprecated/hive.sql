--create the metastore with (Only for the first time):
-- schematool -initSchema -dbType derby
--AND
--start the metastore with: (not needed if using the embedded metastore)
-- hive --service metastore
DROP DATABASE IF EXISTS mbdump CASCADE;
CREATE DATABASE IF NOT EXISTS mbdump;
USE mbdump;


CREATE TABLE artist (
  id                  INT,
  gid                 STRING,
  name                STRING,
  sort_name           STRING,
  begin_date_year     SMALLINT,
  begin_date_month    SMALLINT,
  begin_date_day      SMALLINT,
  end_date_year       SMALLINT,
  end_date_month      SMALLINT,
  end_date_day        SMALLINT,
  type                INT, -- references artist_type.id
  area                INT, -- references area.id
  gender              INT, -- references gender.id
  comment             STRING,
  edits_pending       INT,
  last_updated        TIMESTAMP,
  ended               BOOLEAN,
  begin_area          INT, -- references area.id
  end_area            INT -- references area.id
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/artist/artist.tsv' INTO TABLE artist;

CREATE TABLE gender (
    id                  INT,
    name                STRING,
    parent              INT, -- references gender.id
    child_order         INT,
    description         STRING,
    gid                 STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/gender/gender.tsv' INTO TABLE gender;

CREATE TABLE release (
    id                  INT,
    gid                 STRING,
    name                STRING,
    artist_credit       INT, -- references artist_credit.id
    release_group       INT, -- references release_group.id
    status              INT, -- references release_status.id
    packaging           INT, -- references release_packaging.id
    language            INT, -- references language.id
    script              INT, -- references script.id
    barcode             STRING,
    comment             STRING,
    edits_pending       INT ,
    quality             SMALLINT,
    last_updated        TIMESTAMP
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/release/release.tsv' INTO TABLE release;

CREATE TABLE language (
  id                    INT,
  iso_code_2t           STRING,
  iso_code_2b           STRING,
  iso_code_1            STRING,
  language              STRING,
  frequency             INT,
  iso_code_3            STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/language/language.tsv' INTO TABLE language;

CREATE TABLE label (
    id                  INT,
    gid                 STRING,
    name                STRING,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    label_code          INT,
    type                INT, -- references label_type.id
    area                INT, -- references area.id
    comment             STRING,
    edits_pending       INT,
    last_updated        TIMESTAMP,
    ended               BOOLEAN
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/label/label.tsv' INTO TABLE label;

CREATE TABLE label_type (
    id                  INT,
    name                STRING,
    parent              INT, -- references label_type.id
    child_order         INT,
    description         STRING,
    gid                 STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/label_type/label_type.tsv' INTO TABLE label_type;

CREATE TABLE track (
    id                  INT,
    gid                 STRING,
    recording           INT, -- references recording.id
    medium              INT, -- references medium.id
    position            INT,
    number              STRING,
    name                STRING,
    artist_credit       INT, -- references artist_credit.id
    length              INT,
    edits_pending       INT,
    last_updated        TIMESTAMP,
    is_data_track       BOOLEAN
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/track/track.tsv' INTO TABLE track;

CREATE TABLE artist_credit_name (
    artist_credit       INT, -- PK, references artist_credit.id CASCADE
    position            SMALLINT, -- PK
    artist              INT, -- references artist.id CASCADE
    name                STRING,
    join_phrase         STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/artist_credit_name/artist_credit_name.tsv' INTO TABLE artist_credit_name;

CREATE TABLE release_label(
    id                  INT,
    release             INT,
    label               INT,
    catalog_number      STRING,
    last_updated        STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/mbdump/release_label/release_label.tsv' INTO TABLE release_label;

--Done with the loading stuff, now we create the node tables.

CREATE TABLE artist_final AS (
  SELECT a.id AS id,a.gid AS gid,a.name AS name, g.name AS gender,
    a.type AS type, 'ARTIST' AS LABEL
  FROM artist a JOIN gender g
    ON a.gender = g.id
);

CREATE TABLE release_final AS (
  SELECT r.id AS id, gid, name, release_group,
    l.language AS language, 'RELEASE' AS LABEL
  FROM release r JOIN language l
    ON r.language = l.id
);

CREATE TABLE label_final AS (
  SELECT l.id AS id,l.gid AS gid,l.name AS name,
      lt.name AS type, 'LABEL' AS LABEL
  FROM label l JOIN label_type lt
    ON l.type = lt.id
);

CREATE TABLE track_final AS (
  SELECT id, gid, name, length, 'TRACK' AS LABEL
  FROM track
);

--Done with the node tables, now we create the relationship nodes

CREATE TABLE release_label_final AS (
  SELECT release AS START_ID, label AS END_ID, 'SPONSORED_BY' AS TYPE
  FROM release_label
);

CREATE TABLE release_artist_credit_final AS (
  SELECT id AS START_ID, artist_credit AS END_ID, 'RELEASED' AS TYPE
  FROM release
);

CREATE TABLE track_artist_credit_final AS (
  SELECT id AS START_ID, artist_credit AS END_ID, 'TRACK_OF' AS TYPE
  FROM track
);

CREATE TABLE artist_artist_credit_final AS (
  SELECT artist AS START_ID, artist_credit AS END_ID, 'ARTIST_CREDIT' AS TYPE
  FROM artist_credit_name
);

--Export the final files

-- For the header of the table
--hive -e 'use mbdump; set hive.cli.print.header=true;
--         set hive.resultset.use.unique.column.names=false;
--         select * from artist_final limit 0;'
--         > /home/pranav/Desktop/temp/Header

INSERT OVERWRITE LOCAL DIRECTORY '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/artist'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
select * from artist_final;

INSERT OVERWRITE LOCAL DIRECTORY '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/release'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
select * from release_final;

INSERT OVERWRITE LOCAL DIRECTORY '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/label'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
select * from label_final;

INSERT OVERWRITE LOCAL DIRECTORY '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/track'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
select * from track_final;

--artist_final ok
--release_final ok
--label_final ok
--track_final ok

INSERT OVERWRITE LOCAL DIRECTORY '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/release_label'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
select * from release_label_final;

INSERT OVERWRITE LOCAL DIRECTORY '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/release_artist_credit'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
select * from release_artist_credit_final;

INSERT OVERWRITE LOCAL DIRECTORY '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/track_artist_credit'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
select * from track_artist_credit_final;

INSERT OVERWRITE LOCAL DIRECTORY '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/demo_results/artist_artist_credit'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
select * from artist_artist_credit_final;
--release_label_final ok
--release_artist_credit_final ok
--track_artist_credit_final ok
--artist_artist_credit_final ok
