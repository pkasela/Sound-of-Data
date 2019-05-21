#! /bin/bash
#Assuming to be in the Data Cleaning folder
cd mbdump

all_files=("artist"
           "label"
           "label_type"
           "language"
           "recording"
           "release"
           "release_group"
           "l_artist_label"
           "l_artist_recording"
           "l_artist_release"
           "l_artist_release_group"
           "l_label_recording"
           "l_recording_release"
           "release_label")

for f in ${all_files[@]}
do
  echo "Copying file:///$f.tsv --> hdfs:///mbdump/$f"
  hadoop fs -copyFromLocal $f.tsv /mbdump/
done
