#! /usr/bin/python3

import os
import urllib3
import threading
from bs4 import BeautifulSoup as bs
import requests
from pandas import read_csv, DataFrame

## this script downloads the latest dump from musicbrainz.org (as .tar.bz2 file)
## and prepare it to the import (converting it as a set of .tsv files)

mbtables = ["artist","label","label_type","language",
          "recording","release","release_group",
          "release_label","l_artist_label",
          "l_artist_recording","l_artist_release",
          "l_artist_release_group","l_label_recording",
          "l_recording_release"]

#Will check if there are other interesting *_tag to keep
mbdtables = ["artist_tag","recording_tag","release_tag","tag"]


def yes_no():
    "Return true/false to a question"
    return input("Download the file? [y/N] ").lower() == "y"



if yes_no():
    # get the name of latest dump
    http = urllib3.PoolManager()
    URL = "http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/"
    FILE = "mbdump.tar.bz2"
    BS =  bs(http.request("GET", URL + "LATEST").data, "lxml").get_text()[:-1]
    URL1 = URL + BS + "/" + FILE
    FILE2 = "mbdump-derived.tar.bz2"
    URL2 = URL + BS + "/" + FILE2
    FILE  = "../" + FILE
    FILE2 = "../" + FILE2
    if os.path.isfile(FILE):  # removes the file if already exists
        os.remove(FILE)
        os.system("rm -r ./mbdump_raw")
    if os.path.isfile(FILE2):  # removes the file if already exists
        os.remove(FILE2)
    os.system("wget -c " + URL2 + " -O " + FILE2)

    f = open("mbdtables.txt","w")
    for mbdtable in mbdtables:
        f.write("mbdump/" + mbdtable + "\n")
    f.close()
    os.system("tar xvf " + FILE2 + " --files-from mbdtables.txt"+ " --checkpoint=.10000")
    os.remove(FILE2) #remove the tar file since it has been extracted
    os.remove("mbdtables.txt")
    os.system("wget -c " + URL1 + " -O " + FILE)

    f = open("mbtables.txt","w")
    for mbtable in mbtables:
        f.write("mbdump/" + mbtable + "\n")
    f.close()
    os.system("tar xvf " + FILE  + " --files-from mbtables.txt" + " --checkpoint=.10000")
    os.remove(FILE) #remove the tar file since it has been extracted
    os.remove("mbtables.txt")
    #shift the folder where it is needed
    print("\nThe folder containing raw data has been renamed mbdump_raw")
    os.system("mv mbdump mbdump_raw")

def clean_tsv(x):
    "Convert at the speed of the light (299,792,458 m/s) using cat and sed"
    # Start writing on the file
    with open(x + ".tsv", "w+") as f:
        f.write("")
    # clean the file
    os.system("cat " + x + \
              # find commas and quote the text
              #r' | sed -r "s/([^,\t]*,[^\t]*)/\"\1\"/g"' + \
              # convert in csv
              #r' | sed "s/\t/,/g"' + \
              # remove null value (\N) \\\N
              r' | sed "s/\\\N//g"' + \
              # escape quotes ( " -> \" ) so that Neo4J can import without problems
              r' | sed -r "s/\"/\\\\\"/g"' + \
              " >> " + x + ".tsv")
    # log the success
    print(x + " -> .tsv")
    # shift the file to the right folder mbdump
    os.system("mv " + x +".tsv ./mbdump")


path = "./mbdump_raw/"
os.system("mkdir -p ./mbdump")
threads = []
for table in mbtables + mbdtables:
    # clean the tsv file
    threads.append(threading.Thread(target=clean_tsv,
                     args=[path + table]))

for t in threads:
    t.start()

for t in threads:
    t.join()

######## Adjust the tag table
from generi import get_genres()

tag = read_csv("./mbdump/tag.tsv",sep="\t",header=None)

genre_list = get_genres()

#keep only the necessary tags
tag[3]=tag[1].apply(lambda x: x in genre_list)
tag[tag[3]==True][[0,1]].to_csv("./mbdump/tag_new.tsv", sep="\t",
                                index=False, header=False)
os.system("mv ./mbdump/tag_new.tsv ./mbdump/tag.tsv")
