import os

tables = ["artist","release","language","label","label_type",
          "recording","l_artist_recording","l_artist_release",
          "l_artist_label","l_label_release","l_label_recording",
          "l_recording_release"]

os.system("mkdir -p ./mbdump")
for table in tables:
    print("Now shifting the File " + table + ".tsv")
    os.system("mv ./mbdump_raw/" + table +".tsv ./mbdump")


#os.system("rm -rf ./mbdump_raw")
