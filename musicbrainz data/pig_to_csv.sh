#elimina i risultati, serve perché pig non sovrascrive i file
#solleva subito un eccezione e chiude l'esecuzione
rm -rf ./demo_results/pig_*
#ho configurato in relatà anche mapreduce, ma lui funziona solo su
#partizione hdfs quindi caricherò dopo un altro script per mapred con
#i percorsi cambiati per ora va bene anche local
pig -x local pig_to_csv.pig
#go to artist result folder and concatenate the files
cd ./demo_results/pig_artist
cat .pig_header part-m-00000 part-m-00001 part-m-00002 part-m-00004 part-m-00005 > ../results/artist.tsv
#go to release folder
cd ../pig_release
#why only one partition?! I don't understant anymore how this
#partitioning for PIG works!!
cat .pig_header part-r-00000 > ../results/release.tsv
