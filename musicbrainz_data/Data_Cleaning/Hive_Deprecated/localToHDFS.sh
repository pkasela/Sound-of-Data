#! /bin/bash
#Assuming to be in the Data Cleaning folder
cd ../../mbdump/
hadoop fs -mkdir -p /mbdump
hadoop fs -rm -r /mbdump/*

echo "Creating the necessary folders"
hadoop fs -mkdir -p /mbdump/artist
hadoop fs -mkdir -p /mbdump/gender
hadoop fs -mkdir -p /mbdump/release
hadoop fs -mkdir -p /mbdump/language
hadoop fs -mkdir -p /mbdump/label
hadoop fs -mkdir -p /mbdump/label_type
hadoop fs -mkdir -p /mbdump/track
hadoop fs -mkdir -p /mbdump/artist_credit_name
hadoop fs -mkdir -p /mbdump/release_label
echo "Done creating the folders"

echo "-------------------------------------"

echo "Copying artist.tsv --> hdfs:///mbdump/artist"
hadoop fs -copyFromLocal artist.tsv /mbdump/artist
echo "Copying gender.tsv --> hdfs:///mbdump/gender"
hadoop fs -copyFromLocal gender.tsv /mbdump/gender
echo "Copying release.tsv --> hdfs:///mbdump/release"
hadoop fs -copyFromLocal release.tsv /mbdump/release
echo "Copying language.tsv --> hdfs:///mbdump/language"
hadoop fs -copyFromLocal language.tsv /mbdump/language
echo "Copying label.tsv --> hdfs:///mbdump/label"
hadoop fs -copyFromLocal label.tsv /mbdump/label
echo "Copying label_type.tsv --> hdfs:///mbdump/label_type"
hadoop fs -copyFromLocal label_type.tsv /mbdump/label_type
echo "Copying track.tsv --> hdfs:///mbdump/track"
hadoop fs -copyFromLocal track.tsv /mbdump/track
echo "Copying artist_credit_name.tsv --> hdfs:///mbdump/artist_credit_name"
hadoop fs -copyFromLocal artist_credit_name.tsv /mbdump/artist_credit_name
echo "Copying release_label.tsv --> hdfs:///mbdump/release_label"
hadoop fs -copyFromLocal release_label.tsv /mbdump/release_label
