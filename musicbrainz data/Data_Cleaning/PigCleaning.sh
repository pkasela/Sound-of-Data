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


cd ./demo_results

 # assuming it is bash:
files=("artist"
       "release"
       "label"
       "track")

for f in ${files[@]}
do
   cd pig_$f
   #LABEL to :LABEL
   sed 's/LABEL/:LABEL/' .pig_header > .pig_header.tmp \
   && mv .pig_header.tmp .pig_header
   cat .pig_header part* > "../results/$f.tsv"
   cd ./..
done

relation_files=("artist_artist_credit"
       "release_artist_credit"
       "release_label"
       "track_artist_credit")

for f in ${relation_files[@]}
do
  cd pig_$f
  #START_ID to :START_ID
  #END_ID to :END_ID
  #TYPE to :TYPE
  sed 's/START_ID/:START_ID/' .pig_header | sed 's/END_ID/:END_ID/' \
  | sed 's/TYPE/:TYPE/' > .pig_header.tmp && mv .pig_header.tmp .pig_header
  #concatenate the files
  cat .pig_header part* > "../results/$f.tsv"
  cd ./..
done
