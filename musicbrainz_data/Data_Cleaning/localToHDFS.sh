#! /bin/bash
#Assuming to be in the Data Cleaning folder
cd mbdump

echo "Copying artist.tsv --> hdfs:///mbdump/artist"
hadoop fs -copyFromLocal artist.tsv /mbdump/
echo "Copying l_artist_label.tsv --> hdfs:///mbdump/l_artist_label"
hadoop fs -copyFromLocal l_artist_label.tsv /mbdump/
echo "Copying l_artist_recording.tsv --> hdfs:///mbdump/l_artist_recording"
hadoop fs -copyFromLocal l_artist_recording.tsv /mbdump/
echo "Copying l_artist_release.tsv --> hdfs:///mbdump/l_artist_release"
hadoop fs -copyFromLocal l_artist_release.tsv /mbdump/
echo "Copying l_artist_release_group.tsv --> hdfs:///mbdump/l_artist_release_group"
hadoop fs -copyFromLocal l_artist_release_group.tsv /mbdump/
echo "Copying l_label_recording.tsv --> hdfs:///mbdump/l_label_recording"
hadoop fs -copyFromLocal l_label_recording.tsv /mbdump/
echo "Copying l_label_release.tsv --> hdfs:///mbdump/l_label_release"
hadoop fs -copyFromLocal l_label_release.tsv /mbdump/
echo "Copying l_recording_release.tsv --> hdfs:///mbdump/l_recording_release"
hadoop fs -copyFromLocal l_recording_release.tsv /mbdump/
echo "Copying label.tsv --> hdfs:///mbdump/label"
hadoop fs -copyFromLocal label.tsv /mbdump/
echo "Copying label_type.tsv --> hdfs:///mbdump/label_type"
hadoop fs -copyFromLocal label_type.tsv /mbdump/
echo "Copying language.tsv --> hdfs:///mbdump/language"
hadoop fs -copyFromLocal language.tsv /mbdump/
echo "Copying recording.tsv --> hdfs:///mbdump/recording"
hadoop fs -copyFromLocal recording.tsv /mbdump/
echo "Copying release.tsv --> hdfs:///mbdump/release"
hadoop fs -copyFromLocal release.tsv /mbdump/
echo "Copying release_group.tsv --> hdfs:///mbdump/release_group"
hadoop fs -copyFromLocal release_group.tsv /mbdump/
echo "Copying release_label.tsv --> hdfs:///mbdump/release_label"
hadoop fs -copyFromLocal release_label.tsv /mbdump/
