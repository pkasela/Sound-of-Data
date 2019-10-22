#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import networkx as nx


# In[2]:


generi = pd.read_csv("generi.csv").dropna()
generi.head()


# In[3]:


count = pd.read_csv("genere_graph_clean.csv")
count.head()


# In[4]:


db = generi.set_index("Genere").join(count.set_index("g")).dropna()
db.head()


# In[5]:


db.isnull().values.any()


# In[6]:


generi_graph = nx.Graph()
generi_graph.add_nodes_from(db.index)
colours = {
    "ambient" : "#ccff33",
    "classical" : "#ccff99",
    "pop" : "#00ffff",
    "rock" : "#0066ff",
    "metal" : "#0000cc",
    "punk" : "#9900ff",
    "folk" : "#996633",
    "country" : "#ff9933",
    "latin" : "#ff0000",
    "dance" : "#ff0066",
    "electronic" : "#ffff00",
    "hip hop" : "#00cc99",
    "blues" : "#9966ff",
    "jazz" : "#ff66cc",
}
db["colour"] = db.MainGenere.map(lambda x: colours[x] if colours[x] else "#ffffff")
generi_graph.add_nodes_from(list(colours.keys()))
db.head()


# In[7]:


# connect the genere with its MainGenere
for index, row in db.iterrows():
    for g in row["collect(g1)"].split(","):
        generi_graph.add_edge(index, g)


# In[8]:


db.isnull().values.any()


# In[9]:


plt.figure(figsize=(20, 10))
plt.axis('off')
pos = nx.spring_layout(generi_graph)
nx.draw_networkx_nodes(generi_graph, pos,
                       # node_color=db.colour,
                       node_size=db.popu)  # change with community size
# text of the genere
# nx.draw_networkx_labels(generi_graph, pos)
nx.draw_networkx_edges(generi_graph, pos,
                       arrows=True)
plt.show()


# In[10]:


main_generi = pd.DataFrame([
    {"Genere" : k, "colour" : v} for k, v in colours.items()
])

main_generi_graph = nx.Graph()
main_generi_graph.add_nodes_from(main_generi.Genere)


# In[11]:


plt.figure(figsize=(20, 10))
plt.axis('off')
pos = nx.spring_layout(main_generi_graph)
nx.draw_networkx_nodes(main_generi_graph, pos,
                       node_color=main_generi.colour,
                       node_size=5000)  # change with community size
# text of the genere
nx.draw_networkx_labels(main_generi_graph, pos)
nx.draw_networkx_edges(main_generi_graph, pos,
                       arrows=True)
plt.show()


# In[15]:


db2 = pd.DataFrame()
db2["genere"] = list(set(db["MainGenere"]))
db2.set_index("genere", inplace=True)
db2["count"] = db.groupby(["MainGenere"])["popu"].sum()
db2["links_genere"] = db.groupby(["MainGenere"])["collect(g1)"].apply(list)
db2["links"] = [[] for n in range(len(db2))]
for index, row in db2.iterrows():
    for genere_txt in row.links_genere:
        for genere in genere_txt.split(","):
            main_genere = list(generi.loc[generi.Genere == genere, "MainGenere"].values)
            if len(main_genere) > 0:
                row.links.append(main_genere[0])
db2 = db2.drop(["links_genere"], axis=1)
db2["links"] = db2["links"].map(lambda x: x)
db2["len_links"] = db2.links.map(len)
db2["colour"] = db2.index.map(lambda x: colours[x])
db2


# In[27]:


SOGLIA = 7
generi_graph = nx.Graph()
generi_graph.add_nodes_from(db2.index)
for index, row in db2.iterrows():
    for g in set(row["links"]):
        if row["links"].count(g) > SOGLIA:
            generi_graph.add_edge(index, g)


# In[29]:


plt.figure(figsize=(20, 10))
plt.axis('off')
pos = nx.spring_layout(generi_graph, scale=100, k=3)
nx.draw_networkx_nodes(generi_graph, pos,
                       node_color=db2.colour,
                       alpha=0.7,
                       node_size=db2["count"] * 10)  # change with community size
# text of the genere
nx.draw_networkx_labels(generi_graph, pos)
nx.draw_networkx_edges(generi_graph, pos,
                       arrows=True)
plt.savefig('Grafo_comunita.png')
plt.show()

