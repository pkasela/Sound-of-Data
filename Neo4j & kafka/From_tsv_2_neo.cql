CREATE INDEX ON :Track(id);
CREATE INDEX ON :Track(name);
//headers: id	gid	name	artist_credit	length
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///track_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.gid AS gid, row.name AS name, row.artist_credit AS artist_credit, row.lenght AS lenght
MERGE (track:Track {id:id})
ON CREATE SET track.name=name,
	      track.artist_credit=artist_credit,
	      track.lenght=lenght;

// (id:Track {name:name})
       
	   
CREATE INDEX ON :Release(id);
CREATE INDEX ON :Release(name);
//headers: id	gid	name	artist_credit	release_group	language
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///release_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.gid AS gid, row.name AS name, row.artist_credit AS artist_credit, row.release_group AS release_group, row.language AS language
MERGE (realease:Release { id:id})
ON CREATE SET realease.name=name,
       	      realease.artist_credit=artist_credit,
	      realease.release_group=release_group,
	      realease.language=language;
// (id:Release {name:name, language:language})



CREATE INDEX ON :Artist(id);
CREATE INDEX ON :Artist(name);
//headers: id	gid	name	sort_name	type	area	gender	ended
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///artist_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.gid AS gid, row.name AS name, row.sort_name AS sort_name, row.type AS type, row.area AS area, row.gender AS gender, row.ended AS ended
MERGE (artist:Artist {id:id})
ON CREATE SET artist.name=name,
	      artist.sort_name=sort_name,
	      artist.type=type,
	      artist.area=area,
              artist.gender=gender,
	      artist.ended=ended;

// (id:Artist {name=name, type:type, gender:gender)
// (:Area {name:area})  nodo fittizio per effettuare query geografiche (si ascoltano più musicisti americani, inglese, italiani, tedeschi...)



CREATE INDEX ON :Artist_alias(id);
CREATE INDEX ON :Artist_alias(name);
//headers: id	artist	name	sort_name	type	ended
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///artist_alias_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.artist AS artist, row.name AS name, row.sort_name AS sort_name, row.type AS type, row.ended AS ended
MERGE (artist_alias:Artist_alias {id:id})
ON CREATE SET artist_alias.artist=artist,
	      artist_alias.name=name,
	      artist_alias.sort_name=sort_name,
	      artist_alias.type=type,
	      artist_alias.ended=ended;
// (id:Artist {name:name})-[sameAs]->(artist:Artist)  in fondo, Bond == James Bond 

CREATE INDEX ON :Artist_credit(id);
CREATE INDEX ON :Artist_credit(name);
//headers: id	name	artist_count	ref_count	created	
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///artist_credit_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.name AS name, row.artist_count AS artist_count, row.ref_count AS ref_count, row.created AS created
MERGE (artist_credit:Artist_credit {id:id})
ON CREATE SET artist_credit.name=name,
	      artist_credit.artist_count=artist_count,
	      artist_credit.ref_count=ref_count,
	      artist_credit.created=created;

CREATE INDEX ON :Artist_credit_name(artist_credit);
//headers: artist_credit	position	artist	name
USING PERIODIC COMMIT 10000
LOAD CSV WITH HEADERS FROM "file:///artist_credit_name_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.artist_credit AS artist_credit, row.position AS position, row.artist AS artist, row.name AS name
MERGE (artist_credit_name:Artist_credit_name {artist_credit:artist_credit})
ON CREATE SET artist_credit_name.name=name,
	      artist_credit_name.artist=artist,
	      artist_credit_name.position=position;


CREATE INDEX ON :Label(id);
CREATE INDEX ON :Label(name);
// headers: id: id,gid:gid,name: name,type: type
LOAD CSV WITH HEADERS FROM "file:///label_wo_quotes.tsv" AS row FIELDTERMINATOR '\t'
WITH DISTINCT row.id AS id, row.gid AS gid, row.name AS name, row.type AS type 
MERGE (label:Label { id:id})
ON CREATE SET label.name=name,
              label.type=type;
// (id:Label {name:name, type:type})
    
//RELAZIONI

    
//Artist_alias->Artist
    
MATCH (a:Artist)
MATCH (b:Artist_alias)
WHERE a.id = b.artist
MERGE (b)-[:IS]->(a);
    
    
//Artist_credit_name->Artist

MATCH (a:Artist)
MATCH (b:Artist_credit_name)
WHERE a.id = b.artist
MERGE (b)-[:REFERENCE]->(a);

    
//Artist_credit_name->Artist_credit    

MATCH (a:Artist_credit)
MATCH (b:Artist_credit_name)
WHERE a.id = b.artist_credit
MERGE (b)-[:REFERENCE]->(a);


//Release->Artist_credit    
    
MATCH (a:Artist_credit)
MATCH (b:Release)
WHERE a.id = b.artist_credit
MERGE (b)-[:REFERENCE]->(a);



//Track->Artist_credit    


MATCH (a:Artist_credit)
MATCH (b:Track)
WHERE a.id = b.artist_credit
MERGE (b)-[:REFERENCE]->(a);

    
//REFERENCE nome provvisorio
