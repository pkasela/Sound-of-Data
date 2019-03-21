#Delete the old result files, because PIG does not want to overwrite
#It brings up immediately an exception
rm -rf ./demo_results/pig_*
rm -rf ./demo_results/results
mkdir ./demo_results/results
#Was able to configure also the MapReduce PIG, but it works only
#on a hdfs partition, later I will upload a script with the paths
#changed to the hdfs partition, for now we have the local version
#which actually might be better since we have low latency.
pig -x local pig_to_csv.pig
#go to artist result folder and concatenate the files
cd ./demo_results/pig_artist
cat .pig_header part-m-00000 part-m-00001 part-m-00002 part-m-00004 part-m-00005 > ../results/artist.tsv
#go to release folder
cd ../pig_release
#why only one partition?! I don't understant anymore how this
#partitioning for PIG works!!
cat .pig_header part-r-00000 > ../results/release.tsv
#go to label folder
cd ../pig_label
cat .pig_header part-r-00000 > ../results/label.tsv
