#! /bin/bash

#By Default it will take the maximum amount of available processors.
#main database folder is in /var/lib/neo4j/data/databases/
cd ../demo_results/results
neo4j-import \
  --into SoundofData.db \
  --nodes artist.tsv \
  --nodes release.tsv \
  --nodes release_group.tsv \
  --nodes recording.tsv \
  --nodes label.tsv \
  --nodes tag.tsv \
  --relationships artist_label.tsv \
  --relationships artist_recording.tsv \
  --relationships artist_release.tsv \
  --relationships artist_release_group.tsv \
  --relationships artist_tag.tsv \
  --relationships label_recording.tsv \
  --relationships recording_release.tsv \
  --relationships recording_tag.tsv \
  --relationships release_label.tsv \
  --relationships release_release_group.tsv  \
  --relationships release_tag.tsv \
  --delimiter="\t" \
  --quote="\""

# Close neo4j in case it was running
sudo systemctl stop neo4j.service
# Create a backup file of the old db just in case
sudo mv /var/lib/neo4j/data/databases/graph.db /var/lib/neo4j/data/databases/graph.db.bkp
# Shift the database to the right folder
sudo mv SoundofData.db /var/lib/neo4j/data/databases/graph.db
#Give the right permissions to the new database so that neo4j can be started safely
sudo chown -R neo4j:neo4j /var/lib/neo4j/data/databases/graph.db

#start neo4j again by yourself when you feel like starting it ;)
#otherwise uncomment the following line
#sudo systemctl start neo4j.service

#then just go on any browser with unimib VPN and simply write:
# VM_IP:7474, it may ask id and pass (Defaults are neo4j - neo4j)
#and voilà you should have a working graph
