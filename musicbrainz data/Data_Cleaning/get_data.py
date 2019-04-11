import os
import urllib3
import threading
from bs4 import BeautifulSoup as bs

## this script downloads the latest dump from musicbrainz.org (as .tar.bz2 file)
## and prepare it to the import (converting it as a set of .csv files)

# for @Pranav
# change this line if an header on the top of the file is required
headers_in_file = False

headers = {
    "artist" : [
        "id",
        "gid",
        "name",
        "sort_name",
        "begin_date_year",
        "begin_date_month",
        "begin_date_day",
        "end_date_year",
        "end_date_month",
        "end_date_day",
        "type",
        "area",
        "gender",
        "comment",
        "edits_pending",
        "last_updated",
        "ended",
        "begin_area",
        "end_area",
    ],
#    "artist_alias" : [
#        "id",
#        "artist",
#        "name",
#        "locale",
#        "edits_pending",
#        "last_updated",
#        "type",
#        "sort_name",
#        "begin_date_year",
#        "begin_date_month",
#        "begin_date_day",
#        "end_date_year",
#        "end_date_month",
#        "end_date_day",
#        "primary_for_locale",
#        "ended"
#    ],
#    "artist_credit" : [
#        "id",
#        "name",
#        "artist_count",
#        "ref_count",
#        "created"
#    ],
    "artist_credit_name" : [
        "artist_credit",
        "position",
        "artist",
        "name",
        "join_phrase"
    ],
    "gender" : [
        "id",
        "name",
        "parent",
        "child_order",
        "description",
        "gid"
    ],
    "label" : [
        "id",
        "gid",
        "name",
        "begin_date_year",
        "begin_date_month",
        "begin_date_day",
        "end_date_year",
        "end_date_month",
        "end_date_day",
        "label_code",
        "type",
        "area",
        "comment",
        "edits_pending",
        "last_updated",
        "ended"
    ],
#    "label_alias" : [#va visto se tenere o meno
#        "id",        #e se va tenuto bisgona vedere
#        "label",     #se va bene lo schema
#        "locale",
#        "name",
#        "sort_name",
#        "edits_pending",
#        "last_updated",
#        "type",
#        "begin_date_year",
#        "begin_date_month",
#        "begin_date_day",
#        "end_date_year",
#        "end_date_month",
#        "end_date_day",
#        "ended",
#        "primary_for_locale"
#    ],
    "label_type" : [
        "id",
        "name",
        "parent",
        "child_order",
        "description",
        "gid"
    ],
    "language" : [
        "id",
        "iso_code_2t",
        "iso_code_2b",
        "iso_code_1",
        "name",
        "frequency",
        "iso_code_3"
    ],
#    "recording" : [
#        "id",
#        "gid",
#        "name",
#        "artist_credit",
#        "length",
#        "comment",
#        "edits_pending",
#        "last_updated"
#        "video"
#    ],
    "release" : [
        "id",
        "gid",
        "name",
        "artist_credit",
        "release_group",
        "status",
        "packaging",
        "language",
        "script",
        "barcode",
        "comment",
        "edits_pending",
        "quality",
        "last_updated"
    ],
    "release_label" : [#vedere schema e vedere se serve
        "id",
        "release",
        "label",
        "catalog_number",
        "last_updated"
    ],
    "track" : [
        "id",
        "gid",
        "recording",
        "medium",
        "position",
        "number",
        "name",
        "artist_credit",
        "lenght",
        "edits_pending",
        "last_updated"
        "is_data_track"
    ],
}



def yes_no():
    "Return true/false to an answare"
    return input("Download the file? [y/N] ").lower() == "y"

if yes_no():
    # get the name of latest dump
    http = urllib3.PoolManager()
    URL = "http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/"
    FILE = "mbdump.tar.bz2"
    URL += bs(http.request("GET", URL + "LATEST").data, "lxml").get_text()[:-1] + "/" + FILE
    #and could you @MoMo do in a way that the file is saved in the folder '../'?
    # shall we start with easy things :) - @momo
    FILE = "../" + FILE
    #what happens if the file altready exists and I download it? will it
    #overwrite or will il create a file with name "mbdump(1).tar.bz2"
    # You are right, I'll patch this - @momo
    if os.path.isfile(FILE):  # removes the file if already exists
        os.remove(FILE)
    os.system("wget -c " + URL + " -O " + FILE + " && tar xf " + FILE)
    #It works this way, but maybe there is a better way
    os.system("rm -r ../mbdump && mv mbdump ../mbdump")

def clean_tsv(x, header):
    "Convert at the speed of the light (299,792,458 m/s) using cat and sed"
    # write the header of the file
    with open(x + ".tsv", "w+") as f:
        if headers_in_file:
            f.write(header + "\n")
        else:
            # is there a need for else?? for @MoMo
            # Yes, or the file will be appened and not overwritten - @momo
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



def get_header(x):
    "Get the header of a table"
    return "\t".join(headers[x])


path = "../mbdump/"  # .tar.bz file is moved in ../
for table in list(headers.keys()):
    # clean the tsv file
    threading.Thread(target=clean_tsv,
                     args=[path + table, get_header(table)]).start()
