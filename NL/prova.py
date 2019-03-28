from spacy import load

# to install the library
# pip install spacy

# to install italian dictionary
# python -m spacy download it_core_news_sm

nlp = load("it_core_news_sm")
with open("prova.txt", "r") as f:
    # this file contains a citation from Duglas Adams (first line) and
    # a series of real-world tweet about music.
    # The basic idea is that we can select just a set of key-words
    # from each tweet and query for that
    text = f.readlines()

for t in text:
    doc = nlp(t.replace("\n", ""))
    print(t)
    for e in doc.ents:
        # e.label_ = PER means that we are speaking about a person: so
        # we can query the graph to look for it (it is obviously a
        # component of a band, eventually self-named)
        # but we can query also for e.label_ = MISC to find albums or
        # songs
        print(e.text, e.label_)
        # this part is to improove: e.g. "New @offbloom single"
        # returns "New @offbloom", but we are just looking for
        # @offbloom (and eventually search on the tweeter page)
        # So, we can make a language detection (it vs en) and look for
        # a specific dictionary to split words (if it is not too
        # time-consuming) or find out new strategies (regex?)

# The main idea is the following.
# If we find a specific reference to a person, just look for it to
# check if (s)he is a musician;
# in other case just query for all words in doc.ents, so that if we
# find a direct link between them we are speaking about music.
# 
# It is not such a good algorithm, I know, but it is quite easy to
# implement (I hope) and is also simple and fast :) we need real time,
# we cannot have both speed and accuracy
