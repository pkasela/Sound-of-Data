TODO LIST:

# DataSet Link
[Here is the link](https://gitlab.com/pkasela/the-data) to the cleaned dataset
ready for neo4j, You need to have a GitLab account!!

Or use [GDrive Link to the Dataset](https://drive.google.com/drive/folders/1gk8Uev2mGyi2q3FZWG2QqSAFXqZYgoY_?usp=sharing)

Use maria_dev account in VM (HDP and not HDF) to recreate the database if needed.

# Data Management
- [x] Import data
  - [x] fix .tsv with [get_data.py](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz_data/Data_Cleaning/get_data.py)
  - [x] Decide the tables and their attributes to keep
  - [x] .tsv -> PIG -> clean .tsv (con JOIN e FILTER(GENERATE for PIG)) with [PigCleaning.sh](https://github.com/pkasela/Sound-of-Data/blob/master/musicbrainz_data/Data_Cleaning/PigCleaning.sh)
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

# Data Semantics
- [x] Analisi tweet
  - [x] costruzione modello/i per filtro 
  - [x] analisi prestazioni modello/i (dai abbastanza bene la prestazione)

# Analisi
- [x] Rimozione bot
  - [x] indivuduare utenti e "bannarli" (Botometer)
  - [x] storage di whitelist e blacklist con RiakDB
- [ ] Query interessanti
  - [ ] generi
  - [ ] artisti
- [ ] Analisi
  - [ ] trovare i cluster sulle parole musicali più twittati.    #    "comunità" musicali
  - [ ] trovare cicli giornalieri

# Data Visualization
- [ ] Plot plot plot plot [link to the website](https://pkasela.github.io/Sound-of-Data/)
  - [x] Un possibile plot è work cloud (a forma di qualcosa di musica magari)[link](https://github.com/pkasela/Sound-of-Data/blob/master/docs/music_word_cloud.png)
  - [x] Barplot per la densità di distribuzione nei vari giorni (e periodo) [link](https://public.tableau.com/profile/pranav1988#!/vizhome/SoundofData/Story1)
- [ ] Convalida plot
  - [ ] noi stessi
  - [ ] tante altre persone
  
  
Per segnare come fatto una casella, aggiungere una X all'interno delle parentesi quadre [ ] -> [X]
