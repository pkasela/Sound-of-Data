import pandas as pd
import numpy as np

natural_language_understanding = NaturalLanguageUnderstandingV1(
    version='2018-11-16',
    iam_apikey='9YVeMo_Bs9SvxX3Lp-vGKG0veMqMPQj3K7d_tsMNkVU-',
    url='https://gateway-fra.watsonplatform.net/natural-language-understanding/api'
)

import json
from ibm_watson import NaturalLanguageUnderstandingV1
from ibm_watson.natural_language_understanding_v1 import Features, KeywordsOptions

from Entity_Finder import get_istances

df = pd.read_csv("random_sample_tweets.csv")
def entity_find_momo(x):
    temp = get_istances(x)
    return(list(temp[0]) + list(temp[1]) + list(temp[2]) + list(temp[3]))

df["Our Enitity"]=df.Tweets.apply(entity_find_momo)


def IBM_entity(x):
    res = natural_language_understanding.analyze(
          text=x, language='it',
          features=Features(keywords=KeywordsOptions())).get_result()['keywords']
    important=[]
    for r in res:
        important.append(r['text'])
    return important

df['IBM entities'] = df.Tweets.apply(IBM_entity)
df.to_csv('random_with_entities.csv',index=None,header=['Tweets','Our Entities','IBM Entities'])
