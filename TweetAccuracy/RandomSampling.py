import pandas as pd
import numpy as np
import random
import re

df = pd.read_csv("all_tweets.csv")
tweet_text = df.t.apply(lambda x: re.sub('text:|\s:|\}','',x.split(',')[1])).unique()
random_extract = tweet_text[random.sample(range(len(tweet_text)),100)]

pd.DataFrame(random_extract).to_csv("random_sample_tweets.csv",index=None,header=["Tweets"])
