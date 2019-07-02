import pandas as pd
import numpy as np
# for the Viz
import matplotlib.pyplot as plt
from wordcloud import WordCloud
from PIL import Image

df_with_genre = pd.read_csv("Genres.csv")

genre_frequency = df_with_genre.groupby('Genere').count().to_dict()['Data']

#mask = np.array(Image.open("brain_music.jpg"))
#mask = np.array(Image.open("cuffie.png"))
mask = np.array(Image.open("note.png"))

wordcloud = WordCloud(background_color='white',mask=mask,margin=5,random_state=1)
wordcloud.generate_from_frequencies(frequencies=genre_frequency)

plt.figure(figsize=(15,15))
plt.imshow(wordcloud,interpolation="bilinear")
plt.axis("off")
plt.show()

wordcloud.to_file("music_word_cloud.png")
