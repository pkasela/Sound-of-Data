CREATE INDEX ON :Track(id);
CREATE INDEX ON :Track(name);
//headers: id	gid	name	artist_credit	length
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///track_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.gid AS gid, row.name AS name, row.artist_credit AS artist_credit, row.lenght AS lenght
create (track:Track {id: id, gid:gid, name:name, artist_credit:artist_credit, lenght:lenght});
       
	   
CREATE INDEX ON :Release(id);
CREATE INDEX ON :Release(name);
//headers: id	gid	name	artist_credit	release_group	language
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///release_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.gid AS gid, row.name AS name, row.artist_credit AS artist_credit, row.release_group AS release_group, row.language AS language
create (realease:Release {id: id, gid:gid, name:name, artist_credit:artist_credit, release_group:release_group, language:language});



CREATE INDEX ON :Artist(id);
CREATE INDEX ON :Artist(name);
//headers: id	gid	name	sort_name	type	area	gender	ended
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///artist_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.gid AS gid, row.name AS name, row.sort_name AS sort_name, row.type AS type, row.area AS area, row.gender AS gender, row.ended AS ended
create (artist:Artist {id: id, gid:gid, name:name, sort_name:sort_name, type:type, area:area, gender:gender, ended:ended});



CREATE INDEX ON :Artist_alias(id);
CREATE INDEX ON :Artist_alias(name);
//headers: id	artist	name	sort_name	type	ended
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///artist_alias_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.artist AS artist, row.name AS name, row.sort_name AS sort_name, row.type AS type, row.ended AS ended
create (artist_alias:Artist_alias {id: id, artist:artist, name:name, sort_name:sort_name, type:type, ended:ended});



CREATE INDEX ON :Label(id);
CREATE INDEX ON :Label(name);
// headers: id: id,gid:gid,name: name,type: type}
LOAD CSV WITH HEADERS FROM "file:///label_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.gid AS gid, row.name AS name, row.type AS type 
create (label:Label {id: id,gid:gid,name: name,type: type});
