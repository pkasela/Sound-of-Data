#[WARN] Anything created and saved either staring with `pig_' or
#in the results folder will be removed when the script is executed
cd ../
#creates a folder (if it doesn't exist [-p]) to store the results
#note that anything you do in this folder will not be uploaded to git
#since we included it in the .gitignore file
mkdir -p ./demo_results
#Delete the old result files, because PIG does not want to overwrite
#It brings up immediately an exception
rm -rf ./demo_results/pig_*
#Here we save the ``bella copia'' of the files
mkdir -p ./demo_results/results
rm -r ./demo_results/results/*

#Was able to configure also the MapReduce PIG, but it works only
#on a hdfs partition, later I will upload a script with the paths
#changed to the hdfs partition, for now we have the local version
#which actually might be better since we have low latency.
pig -x local ./Data_Cleaning/PigCleaning.pig

#go to artist result folder and concatenate the files
cd ./demo_results/pig_artist
cat .pig_header part* > ../results/artist.tsv
#go to artist_alias_folder
cd ../pig_artist_alias
cat .pig_header part* > ../results/artist_alias.tsv
#go to release folder
cd ../pig_release
#why only one partition?! I don't understant anymore how this
#partitioning for PIG works!!
cat .pig_header part* > ../results/release.tsv
#go to label folder
cd ../pig_label
cat .pig_header part* > ../results/label.tsv
#go to track_folder
cd ../pig_track
cat .pig_header part* > ../results/track.tsv
