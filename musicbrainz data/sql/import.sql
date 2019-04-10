DROP TABLE IF EXISTS track;
DROP TABLE IF EXISTS release_t;

CREATE TABLE track (
    id                  TEXT NOT NULL,
    number              TEXT NOT NULL,
    artist_credit       INTEGER NOT NULL -- references artist_credit.id
);

LOAD DATA LOCAL INFILE '/home/pranav/Desktop/result_track'
INTO TABLE track
FIELDS TERMINATED BY '\t'
ENCLOSED BY '\"'
LINES TERMINATED BY '\n';

CREATE INDEX index_track_ac ON track (artist_credit) USING HASH;

CREATE TABLE release_t (
    id                  TEXT NOT NULL,
    artist_credit       INTEGER NOT NULL -- references artist_credit.id
);

LOAD DATA LOCAL INFILE '/home/pranav/Desktop/result_release'
INTO TABLE release_t
FIELDS TERMINATED BY '\t'
ENCLOSED BY '\"'
LINES TERMINATED BY '\n';

CREATE INDEX index_release_ac ON release_t(artist_credit) USING HASH;
