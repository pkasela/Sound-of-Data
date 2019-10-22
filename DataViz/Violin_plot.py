#!/usr/bin/env python
# coding: utf-8

# In[11]:


import seaborn as sns
import matplotlib.pyplot as plt

get_ipython().run_line_magic('matplotlib', 'inline')


# In[12]:


import pandas as pd


# In[13]:


data = pd.read_excel('qu.xlsx')


# In[14]:


sns.set(style="whitegrid")


# In[15]:


data['Domanda'] = data['Domanda'].astype('category')
data['Genere'] = data['Genere'].astype('category')
diz = {'fontsize': 20,
 'fontweight' :10,
 'verticalalignment': 'baseline',
 'horizontalalignment': 'center'}


# In[16]:


plt.figure(figsize=(20, 8)) 
plt.title("Risultati questionario psicometrico", fontdict=diz, loc='center', pad=None)
ax = sns.violinplot(x="Domanda", y="Valore", data=data)


# In[17]:


plt.figure(figsize=(20, 8)) 
plt.title("Risultati questionario psicometrico", fontdict=diz, loc='center', pad=None) 
ax = sns.swarmplot(x="Domanda",y="Valore",data=data,hue="Genere",dodge=True,
                   size=3, palette=["magenta", "blue"])
ax.legend_.remove()
ax = sns.violinplot(x="Domanda", y="Valore",data=data, hue="Genere",#cut=0,
                    palette=["pink", "lightblue"])

ax.legend(loc = 'lower left')


# In[28]:


plt.figure(figsize=(20, 8)) 
plt.title("Risultati questionario psicometrico", fontdict=diz, loc='center', pad=None) 
ax = sns.swarmplot(x="Domanda",y="Valore",data=data,hue="Genere",dodge=True,
                   size=4, palette=["magenta", "blue"])
#ax.legend_.remove()
sns.violinplot(x="Domanda", y="Valore",data=data, hue="Genere",#cut=0,
                    palette=["pink", "lightblue"],split=True)

ax.legend(loc = 'lower left')


# In[ ]:




