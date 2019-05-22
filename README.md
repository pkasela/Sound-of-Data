TODO LIST:

# DataSet Link
[Here is the link](https://drive.google.com/drive/u/1/folders/1HVVPPZLErF-mhksggt2WvuVTie1Xd9HI) to the cleaned dataset
ready for neo4j, and [Here is the link to the neo4j db](https://drive.google.com/open?id=1ld8vAAavnh2mLTNPHpFOWlDrLjbH-y5Q)

# Data Management
- [ ] Import data
  - [x] fix .tsv with [get_data.py](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz%20data/Data_Cleaning/get_data.py)
  - [x] Decide the tables and their attributes to keep
  - [x] .tsv -> PIG -> clean .tsv (con JOIN e FILTER(GENERATE for PIG)) with [PigCleaning.sh](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz%20data/Data_Cleaning/PigCleaning.sh)
  - [ ] clean .tsv -> neo4j (bash)
  - [ ] Scrape down musicBrainz artist using musicBrainz API 
- [ ] Tweet
  - [x] Kafka Producer
  - [ ] Kafka consumer -> MongoDB per analisi di test
  - [x] Kafka consumer -> Neo4j

# Data Semantics
- [ ] Analisi tweet
  - [ ] ricerca esplorativa
  - [ ] trovare fonti di dati
  - [ ] costruzione modello/i per filtro 
  - [ ] analisi prestazioni modello/i 

# Analisi
- [ ] (?) Rimozione bot
  - [ ] individuare parametri
  - [ ] indivuduare utenti e "bannarli"
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
