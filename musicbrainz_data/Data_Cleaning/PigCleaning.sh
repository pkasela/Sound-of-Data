#! /bin/bash

#The above line is needed to tell the system to use bash (not sh)

#remove the mbdump_raw/* to free up a little bit of memory before the PIG execution
rm -rf mbdump_raw/

#[WARN] Anything created and saved either staring with `pig_' or
#in the results folder will be removed when the script is executed
cd ..
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
rm -r ./demo_results/results/*.tsv

#Was able to configure also the MapReduce PIG, but it works only
#on a hdfs partition, later I will upload a script with the paths
#changed to the hdfs partition, for now we have the local version
#which actually might be better since we have low latency.
#set the SOUND_FOLDER before executing the script

#cd ../
#export SOUND_FOLDER=$(pwd)
#cd musicbrainz_data/

hadoop fs -rm -r /mbdump
hadoop fs -rm -r /demo_results
hadoop fs -rm -r /user/maria_dev/.Trash/Current/mbdump
hadoop fs -rm -r /user/maria_dev/.Trash/Current/demo_results

hadoop fs -mkdir -p /mbdump
hadoop fs -mkdir -p /demo_results

cd ./Data_Cleaning

./localToHDFS.sh

rm -rf mbdump/ #remove also the files from the filesystem to free up disk space

pig -x tez ./PigCleaningHDFS_part1.pig

pig -x tez ./PigCleaningHDFS_part2.pig

pig -x tez ./PigCleaningHDFS_part3.pig

#now it has processed the data so we remove the original data
hadoop fs -rm -r /mbdump

#Assuming you will use maria_dev in HDP
hadoop fs -rm -r /user/maria_dev/.Trash/Current/mbdump

cd ../demo_results

echo "Copying the result from HDFS to the local FS"
echo "(may take some time, so take a coffee or something)"
hadoop fs -copyToLocal -ignoreCrc /demo_results/pig_* ./

#now everything is copied so let's delete everything in hdfs to save space
hadoop fs -rm -r /demo_results/pig_*
hadoop fs -rm -r /user/maria_dev/.Trash/Current/demo_results

 # assuming it is bash:
files=("artist"
       "label"
       "recording"
       "release"
       "release_group"
       "tag")

for f in ${files[@]}
do
   cd pig_$f
   #LABEL to :LABEL
   #ID to :ID
   sed 's/LABEL/:LABEL/' .pig_header | sed 's/ID/:ID/' > .pig_header.tmp \
   && sudo mv -f .pig_header.tmp .pig_header
   cat .pig_header part* > "../results/$f.tsv"
   cd ./..
done

relation_files=("artist_label"
                "artist_recording"
                "artist_release"
                "artist_release_group"
                "label_recording"
                "release_label"
                "recording_release"
                "release_release_group"
                "artist_tag"
                "recording_tag"
                "release_tag")
                #can't find recording_release_group (it should exist)
                #release_group can be found in release table itself
for f in ${relation_files[@]}
do
  cd pig_$f
  #START_ID to :START_ID
  #END_ID to :END_ID
  #TYPE to :TYPE
  sed 's/START_ID/:START_ID/' .pig_header | sed 's/END_ID/:END_ID/' \
  | sed 's/TYPE/:TYPE/' > .pig_header.tmp && sudo mv .pig_header.tmp .pig_header
  #concatenate the files
  cat .pig_header part* > "../results/$f.tsv"
  cd ./..
done

tag_files=()

rm -rf ./pig_*
