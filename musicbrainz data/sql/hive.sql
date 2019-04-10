CREATE DATABASE IF NOT EXISTS mbdump;
USE mbdump;

DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS release;
DROP TABLE IF EXISTS language;
DROP TABLE IF EXISTS label;
DROP TABLE IF EXISTS label_type;
DROP TABLE IF EXISTS track;
DROP TABLE IF EXISTS artist_credit;

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
