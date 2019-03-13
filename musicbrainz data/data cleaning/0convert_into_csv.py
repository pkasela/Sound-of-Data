import sys

for line in sys.stdin:
    print(line.replace("\t", ",")
              .replace("\\N", ""), end="")
