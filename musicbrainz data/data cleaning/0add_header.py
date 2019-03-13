import os
import sys
import re


def ncol(x):
    "return the number of columns of a table .tsv"
    return len(re.findall("\\t", x)) + 1

def generate_header(max_length, length=0, header=[]):
    "return an header"
    if len(header) == max_length:
        return ",".join(header)
    header.append(input("colonna " + str(len(header) + 1) + "> "))
    return generate_header(max_length, header)


with open(sys.argv[1], "r") as f:
    n = ncol(next(f))
print(n)

with open(sys.argv[1] + ".csv", "w") as f:
    f.write(generate_header(n) + "\n")

os.system("cat " + sys.argv[1] + " | python 0convert_into_csv.py >> " + sys.argv[1] + ".csv")
