import pandas as pd
import numpy as np
import re

df = pd.read_csv('random_with_entities.csv',sep=",",
            names=["Tweet","entities_OUR","entities_IBM","Our_Accuracy",
                    "IBM_Accuracy","talks_abt_music","entities_from_us"])

df.talks_abt_music.value_counts()
#result
# sì: 60
# no: 40

df_yes = df[df["talks_abt_music"]=="sì"]

def fraction_to_float(x):
    num = re.findall('(\d+)\/(\d+)',x)
    return float(num[0][0])/float(num[0][1])

df_yes.IBM_Accuracy = df_yes.IBM_Accuracy.apply(fraction_to_float)
df_yes.Our_Accuracy = df_yes.Our_Accuracy.apply(fraction_to_float)

df_yes.loc[:,['Tweet','Our_Accuracy',
        'IBM_Accuracy']].to_csv("tweet_accuracy.csv",index=None)
