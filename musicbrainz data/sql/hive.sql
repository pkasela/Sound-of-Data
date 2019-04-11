--create the metastore with:
-- schematool -initSchema -dbType derby
--AND
--remember to start the metastore with:
-- hive --service metastore
DROP DATABASE mbdump CASCADE; 
CREATE DATABASE IF NOT EXISTS mbdump;
USE mbdump;

DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS release;
DROP TABLE IF EXISTS language;
DROP TABLE IF EXISTS label;
DROP TABLE IF EXISTS label_type;
DROP TABLE IF EXISTS track;
DROP TABLE IF EXISTS artist_credit;
DROP TABLE IF EXISTS gender;
DROP TABLE IF EXISTS artist_credit_name;
DROP TABLE IF EXISTS release_label;

CREATE TABLE artist (
  id                  INTEGER,
  gid                 STRING,
  name                STRING,
  sort_name           STRING,
  begin_date_year     SMALLINT,
  begin_date_month    SMALLINT,
  begin_date_day      SMALLINT,
  end_date_year       SMALLINT,
  end_date_month      SMALLINT,
  end_date_day        SMALLINT,
  type                INTEGER, -- references artist_type.id
  area                INTEGER, -- references area.id
  gender              INTEGER, -- references gender.id
  comment             STRING,
  edits_pending       INTEGER,
  last_updated        TIMESTAMP,
  ended               BOOLEAN,
  begin_area          INTEGER, -- references area.id
  end_area            INTEGER -- references area.id
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/artist';

CREATE TABLE gender (
    id                  INTEGER,
    name                STRING,
    parent              INTEGER, -- references gender.id
    child_order         INTEGER,
    description         STRING,
    gid                 STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/gender';

CREATE TABLE release (
    id                  INTEGER,
    gid                 STRING,
    name                STRING,
    artist_credit       INTEGER, -- references artist_credit.id
    release_group       INTEGER, -- references release_group.id
    status              INTEGER, -- references release_status.id
    packaging           INTEGER, -- references release_packaging.id
    language            INTEGER, -- references language.id
    script              INTEGER, -- references script.id
    barcode             STRING,
    comment             STRING,
    edits_pending       INTEGER ,
    quality             SMALLINT,
    last_updated        TIMESTAMP
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/release';

CREATE TABLE language (
  id                    INTEGER,
  iso_code_2t           STRING,
  iso_code_2b           STRING,
  iso_code_1            STRING,
  language              STRING,
  frequency             INTEGER,
  iso_code_3            STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/language';

CREATE TABLE label (
    id                  INTEGER,
    gid                 STRING,
    name                STRING,
    begin_date_year     SMALLINT,
    begin_date_month    SMALLINT,
    begin_date_day      SMALLINT,
    end_date_year       SMALLINT,
    end_date_month      SMALLINT,
    end_date_day        SMALLINT,
    label_code          INTEGER,
    type                INTEGER, -- references label_type.id
    area                INTEGER, -- references area.id
    comment             STRING,
    edits_pending       INTEGER,
    last_updated        TIMESTAMP,
    ended               BOOLEAN
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/label';

CREATE TABLE label_type (
    id                  INTEGER,
    name                STRING,
    parent              INTEGER, -- references label_type.id
    child_order         INTEGER,
    description         STRING,
    gid                 STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/label_type';

CREATE TABLE track (
    id                  INTEGER,
    gid                 STRING,
    recording           INTEGER, -- references recording.id
    medium              INTEGER, -- references medium.id
    position            INTEGER,
    number              STRING,
    name                STRING,
    artist_credit       INTEGER, -- references artist_credit.id
    length              INTEGER,
    edits_pending       INTEGER,
    last_updated        TIMESTAMP,
    is_data_track       BOOLEAN
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/track';

CREATE TABLE artist_credit_name (
    artist_credit       INTEGER, -- PK, references artist_credit.id CASCADE
    position            SMALLINT, -- PK
    artist              INTEGER, -- references artist.id CASCADE
    name                STRING,
    join_phrase         STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/artist_credit_name';

CREATE TABLE release_label(
    id                  INTEGER,
    release             INTEGER,
    label               INTEGER,
    catalog_number      STRING,
    last_updated        STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/mbdump/release_label';

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

CREATE TABLE artist_release AS (
  SELECT ac.artist AS START_ID, r.id AS END_ID, 'RELEASED' AS TYPE
  FROM (SELECT id, artist_credit FROM release) r
    JOIN
       (SELECT artist_credit, artist FROM artist_credit_name) ac
    ON r.artist_credit = ac.artist_credit
);

CREATE TABLE release_label_final AS (
  SELECT release AS START_ID, label AS END_ID, 'SPONSORED_BY' AS TYPE
  FROM release_label
);

--This is the heavy one, very heavy

CREATE TABLE release_track AS (
  SELECT r.id AS START_ID, t.id AS END_ID, 'CONTAINS' AS TYPE
  FROM (SELECT id, artist_credit FROM release) r
    JOIN
       (SELECT id, artist_credit FROM track) t
    ON r.artist_credit=t.artist_credit
);

