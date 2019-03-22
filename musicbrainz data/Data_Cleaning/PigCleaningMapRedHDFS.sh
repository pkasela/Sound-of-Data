#[WARN] Anything created and saved either staring with `pig_' or
#in the results folder will be removed when the script is executed

#creates a folder (if it doesn't exist [-p]) to store the results
#note that anything you do in this folder will not be uploaded to git
#since we included it in the .gitignore file
hadoop fs -mkdir -p /demo_results
#Delete the old result files, because PIG does not want to overwrite
#It brings up immediately an exception
hadoop fs -rm -r /demo_results/pig_*
#Here we save the ``bella copia'' of the files
hadoop fs -mkdir -p /demo_results/results
hadoop fs -rm -r /demo_results/results/*

#Was able to configure also the MapReduce PIG, but it works only
#on a hdfs partition, later I will upload a script with the paths
#changed to the hdfs partition, for now we have the local version
#which actually might be better since we have low latency.
pig -x MapReduce PigCleaningMapRedHDFS.pig

#go to artist result folder and concatenate the files
hadoop fs -cat /demo_results/pig_artist/.pig_header /demo_results/pig_artist/part* > /demo_results/results/artist.tsv
#go to artist_alias_folder
hadoop fs -cat /demo_results/pig_artist_alias/.pig_header part* > /demo_results/results/artist_alias.tsv
#go to release folder
hadoop fs -cat /demo_results/pig_artist/.pig_header part* > /demo_results/results/release.tsv
#go to label folder
hadoop fs -cat /demo_results/pig_label/.pig_header part* > /demo_results/label.tsv
#go to track_folder
#hadoop fs -cat /demo_results/pig_track/.pig_header part* > /demo_results/results/track.tsv
