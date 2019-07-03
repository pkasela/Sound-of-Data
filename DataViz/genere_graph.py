import pandas as pd
import re


def get_name(txt):
    out = re.findall(r"\{name\:([^\,]+)", txt)
    if len(out) == 1:
        return out[0]
    return ",".join(list(set(out))) if out else ""


db = pd.read_csv("genere_graph.csv")
print(db.head())
db["g"] = db["g"].map(get_name)
db["collect(g1)"] = db["collect(g1)"].map(get_name)

print(db.head())

db.to_csv("genere_graph_clean.csv")
