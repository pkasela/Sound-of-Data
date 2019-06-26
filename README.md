TODO LIST:

# DataSet Link
[Here is the link](https://gitlab.com/pkasela/the-data) to the cleaned dataset
ready for neo4j, You need to have a GitLab account!!

Use maria_dev account in VM (HDP and not HDF) to recreate the database if needed.

# Data Management
- [x] Import data
  - [x] fix .tsv with [get_data.py](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz%20data/Data_Cleaning/get_data.py)
  - [x] Decide the tables and their attributes to keep
  - [x] .tsv -> PIG -> clean .tsv (con JOIN e FILTER(GENERATE for PIG)) with [PigCleaning.sh](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz%20data/Data_Cleaning/PigCleaning.sh)
  - [x] clean .tsv -> neo4j [neo4j_import.sh](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz_data/Data_Cleaning/neo4j_import.sh)
  - [x] index on the graph
  - [x] constraint on the graph for unique gid of the entities
  - [x] Scrape down musicBrainz genres using musicBrainz API
  - [x] Remove the useless genres such as: audiobook to reduce the dimesione of the list
- [x] Tweet
  - [x] Kafka Producer with [Kafka_Produce.py](https://github.com/pkasela/Sound-of-Data/blob/master/Neo4j%20%26%20kafka/Kafka_Producer.py)
  - [x] Kafka Producer -> Neo4j Consumer [Neo4j Streams Procedure](https://github.com/pkasela/Sound-of-Data/blob/master/Neo4j%20%26%20kafka/Neo4j%20Streams%20Consume%20Tutorial.txt)
  - [x] Initialize the script using tmux and sleep happily
  - [x] Check if everything is alright in the morning!
  - [ ] E' successo un casino con musicbrainz ed è crashato dalle 17:24, o lì vicino e mi sono accorto alle 12:45 e l'ho riaccesso con un nuovo try, except sulla funzione di marco non so se tenerne conto in realtà va ad influenza il ciclo settimanale ma ormai, non ci possiamo fare tanto

# Data Semantics
- [x] Analisi tweet
  - [x] costruzione modello/i per filtro 
  - [x] analisi prestazioni modello/i (dai abbastanza bene la prestazione)

# Analisi
- [x] Rimozione bot
  - [x] indivuduare utenti e "bannarli" (Botometer)
  - [x] storage di whitelist e blacklist con RiakDB
- [ ] Eliminazione della parola 'DRONE' prima di partire con le analisi giustificando per via dei due eventi
   - Tensione con tra IRAN e USA per via del drone Americano abbattuto
   - Festival a Torino con luci e droni
- [ ] Citazione degli altri casi di polisemia: club, dance (?) (per far vedere che siamo pignoli)
- [ ] Togliere tutti i tweet con #trap in cui compare anche ['#gay','#sissy','#femboy','#daddy','#femboi']  (indicano i transessuali così)
- [ ] Query interessanti
  - [ ] generi
  - [ ] artisti
- [ ] Analisi
  - [ ] trovare i cluster sulle parole musicali più twittati.    #    "comunità" musicali
  - [ ] trovare cicli giornalieri
  - [ ] trovare cicli settimanali
- [ ] Creare dump periodici ?? Lo vogliamo ancora fare o ce ne sbattiamo tanto i generi sono quelli

# Data Visualization
- [ ] Plot plot plot plot
  - [ ] Un possibile plot è work cloud (a forma di qualcosa di musica magari)
  - [ ] Barplot per la densità di distribuzione nei vari giorni (e ora)
  - [ ] Interazione fra le comunità
- [ ] Convalida plot
  - [ ] noi stessi
  - [ ] tante altre persone
  
  
Per segnare come fatto una casella, aggiungere una X all'interno delle parentesi quadre [ ] -> [X]
