TODO LIST:

# DataSet Link
[Here is the link](??) to the cleaned dataset
ready for neo4j, and [Here is the link to the neo4j db](??)

Links are broken for now, use maria_dev account in VM (HDP and not HDF) to recreate the database if needed.

# Data Management
- [x] Import data
  - [x] fix .tsv with [get_data.py](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz%20data/Data_Cleaning/get_data.py)
  - [x] Decide the tables and their attributes to keep
  - [x] .tsv -> PIG -> clean .tsv (con JOIN e FILTER(GENERATE for PIG)) with [PigCleaning.sh](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz%20data/Data_Cleaning/PigCleaning.sh)
  - [x] clean .tsv -> [neo4j](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz_data/Data_Cleaning/neo4j_import.sh)
  - [ ] index on the graph
  - [x] Scrape down musicBrainz artist using musicBrainz API 
- [x] Tweet
  - [x] Kafka Producer with [Kafka_Produce.py](https://github.com/pkasela/Sound-of-Data/blob/master/Neo4j%20%26%20kafka/Kafka_Producer.py)
  - [x] Kafka Producer -> Neo4j Consumer [Neo4j Streams Procedure](https://github.com/pkasela/Sound-of-Data/blob/master/Neo4j%20%26%20kafka/Neo4j%20Streams%20Consume%20Tutorial.txt)

# Data Semantics
- [ ] Analisi tweet
  - [x] costruzione modello/i per filtro 
  - [ ] analisi prestazioni modello/i 

# Analisi
- [x] Rimozione bot
  - [x] indivuduare utenti e "bannarli" (Botometer)
- [ ] Query interessanti
  - [ ] generi
  - [ ] artisti
- [ ] Analisi
  - [ ] trovare "comunità" musicali
  - [ ] trovare cicli giornalieri
  - [ ] trovare cicli settimanali
- [ ] Creare dump periodici

# Data Visualization
- [ ] Plot plot plot plot
- [ ] Convalida plot
  - [ ] noi stessi
  - [ ] tante altre persone
  
  
Per segnare come fatto una casella, aggiungere una X all'interno delle parentesi quadre [ ] -> [X]
