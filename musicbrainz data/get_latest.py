import os
import urllib3
from bs4 import BeautifulSoup as bs

## this script downloads the latest dump from musicbrainz.org (as .tar.bz2 file)


# get the name of latest dump
http = urllib3.PoolManager()

URL = "http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/"
FILE = "mbdump.tar.bz2"
URL += bs(http.request("GET", URL + "LATEST").data, "lxml").get_text()[:-1] + "/" + FILE


# just print an awesome message
msg = "Downloading " + FILE + "... it can take a while"
print(msg, end="\r")
# download the file
os.system("wget -c " + URL)
# oh, completed I'm so happy
print("Download completed :D" + " " * len(msg))

