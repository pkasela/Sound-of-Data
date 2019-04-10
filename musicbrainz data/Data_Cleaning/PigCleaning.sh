#! /bin/bash

#The above line is needed to tell the system to use bash (not sh)

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
#                 ^            ^
# @pranav, for curiosity: what editor do you use to have such quotes?
# @MoMo I use either Atom or Basic Text Editor of Ubuntu (Though not a
# 					great fan of it, I prefer Atom)
mkdir -p ./demo_results/results
rm -r ./demo_results/results/*

#Was able to configure also the MapReduce PIG, but it works only
#on a hdfs partition, later I will upload a script with the paths
#changed to the hdfs partition, for now we have the local version
#which actually might be better since we have low latency.
pig -x local ./Data_Cleaning/PigCleaning.pig


 # for @pranav: wouldn't it be easier to read using a for loop?
 # Guess you're right and elegant :D
 # assuming it is bash:
files=("artist"
       "artist_alias"
       "release"
       "label"
       "track")

cd ./demo_results
for f in ${files[@]}
do
   cd pig_$f
   cat .pig_header part* > "../results/$f.tsv"
   cd ./..
done


#go to artist result folder and concatenate the files
#cd ./demo_results/pig_artist
#cat .pig_header part* > ../results/artist.tsv

#go to artist_alias_folder
#cd ../pig_artist_alias
#cat .pig_header part* > ../results/artist_alias.tsv

#go to release folder
#cd ../pig_release
#why only one partition?! I don't understant anymore how this
#partitioning for PIG works!!
#cat .pig_header part* > ../results/release.tsv

#go to label folder
#cd ../pig_label
#cat .pig_header part* > ../results/label.tsv

#go to track_folder
#cd ../pig_track
#cat .pig_header part* > ../results/track.tsv
