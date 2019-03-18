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
        "ended",
        "type",
        "gender",
        "area",
        "begin_area",
        "end_area",
        "cocmment",
        "edits_pending",
        "last_updated"
    ],
    "artist_alias" : [
        "id",
        "artist",
        "name",
        "sort_name",
        "locale",
        "edits_pending",
        "last_updated",
        "type",
        "begin_date_year",
        "begin_date_month",
        "begin_date_day",
        "end_date_year",
        "end_date_month",
        "end_date_day",
        "ended",
        "primary_for_locale"
    ],
    "artist_credit" : [
        "id",
        "name",
        "artist_count",
        "ref_count",
        "created"
    ],    
    "artist_credit_name" : [
        "artist_credit",
        "position",
        "artist",
        "name",
        "join_phrase"
    ],
    "gender" : [
        "id",
        "name"
    ],
    "label" : [
        "id",
        "gid",
        "name",
        "sort_name",
        "type",
        "label_code",
        "area",
        "begin_date_year",
        "begin_date_month",
        "begin_date_day",
        "end_date_year",
        "end_date_month",
        "end_date_day",
        "ended",
        "comment",
        "edits_pending",
        "last_updated"
    ],
    "label_alias" : [
        "id",
        "label",
        "locale",
        "name",
        "sort_name",
        "edits_pending",
        "last_updated",
        "type",
        "begin_date_year",
        "begin_date_month",
        "begin_date_day",
        "end_date_year",
        "end_date_month",
        "end_date_day",
        "ended",
        "primary_for_locale"
    ],
    "recording" : [
        "id",
        "gid",
        "artist_credit",
        "name",
        "length",
        "comment",
        "edits_pending",
        "last_updated"
    ],
    "release" : [
        "id",
        "gid",
        "release_group",
        "artist_credit",
        "name",
        "barcode",
        "status",
        "packaging",
        "language",
        "script",
        "comment",
        "edits_pending",
        "quality",
        "last_updated"
    ],
    "release_label" : [
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
    ],
}



# download and decompress the file
def yes_no():
    "Return true/false to an answare"
    return input("Download the file? (y/N)").lower() == "y"

if yes_no():
    # get the name of latest dump
    http = urllib3.PoolManager()
    URL = "http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/"
    FILE = "mbdump.tar.bz2"
    URL += bs(http.request("GET", URL + "LATEST").data, "lxml").get_text()[:-1] + "/" + FILE
    os.system("wget -c " + URL + " && tar xvf " + FILE)


def clean_tsv(x, header):
    "Convert at the speed of the light using cat and sed"
    # write the header of the file
    with open(x + ".tsv", "w+") as f:
        if headers_in_file:
            f.write(header + "\n")
        else:
            f.write("")
    # clean the file
    os.system("cat " + x + \
              # find commas and quote the text
              # bug? if a string contains two commas, it does not match
              #r' | sed -r "s/([^,\t]+),\s?([^,\t]+)/\"\1, \2\"/g"' + \
              # convert in csv
              #r' | sed "s/\t/,/g"' + \
              # remove null value (\N) \\\N
              r' | sed "s/\\\N//g"' + \
              " >> " + x + ".tsv")
    # log the success
    print(x + " -> .tsv")



def get_header(x):
    "Get the header of a table"
    return "\t".join(headers[x])


path = "./mbdump/"
for table in list(headers.keys()):
    # clean the tsv file
    threading.Thread(target=clean_tsv,
                     args=[path + table, get_header(table)]).start()
