TODO LIST:

# DataSet Link
[Here is the link](https://drive.google.com/drive/u/1/folders/1HVVPPZLErF-mhksggt2WvuVTie1Xd9HI) to the cleaned dataset
ready hopefully for neo4j

# Data Management
- [ ] Import data
  - [x] fix .tsv
  - [x] .tsv -> PIG
  - [x] PIG -> .tsv denormalizzato (con JOIN)
  - [ ] Decide the tables and their attributes to keep
  - [ ] .tsv denormalizzato -> neo4j (bash)
- [ ] Tweet
  - [x] Kafka Producer
  - [ ] Kafka consumer ->  mongodb per analisi di test
  - [ ] Kafka consumer -> Neo4j

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
