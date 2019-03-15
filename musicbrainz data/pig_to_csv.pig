-- Pig Script

artist = LOAD '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/mbdump/artist' 
USING PigStorage('\t') AS
(id:int,gid:chararray,name:chararray,sort_name:chararray,begin_date_year:chararray,
  begin_date_month:chararray,begin_date_day:chararray,end_date_year:chararray,
  end_date_month:chararray,end_date_day:chararray,ended:chararray,type:chararray,
  gender:chararray,area:chararray,begin_area:chararray,end_area:chararray,
  comment:chararray,edits_pending:chararray,last_updated:chararray);

--artist_lim = LIMIT artist 5;

artist_comma = FOREACH artist GENERATE 
(id,gid,name,REPLACE(sort_name,',',';'),begin_date_year,begin_date_month,
begin_date_day,end_date_year,end_date_month,end_date_day,ended,
type,gender,area,begin_area,end_area,comment,
edits_pending,last_updated);

DUMP artist_comma;

--STORE artist INTO '/home/pranav/Desktop/Sound-of-Data/musicbrainz data/artist_pig' USING PigStorage(',','-schema');

--STORE artist INTO '<path>' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX', 'WRITE_OUTPUT_HEADER');
--This is to get the header on each table (directly, but has a few flaws)

--to execute use it with the pig_to_csv.py file.
