import re
import enchant  # pip install pyenchant
from itertools import permutations
from itertools import chain as flatten


PATH = "./"
with open(PATH + "prova.txt") as f:
    txt = f.readlines()


CONTRACTIONS = set(["", "cmq", "qls", "qlc", "asap", "fb", "wh",
                    "rt", "dvd"])
VOCAL = r"[(ai)(ei)(oi)(au)(eu)(ia)(ie)(io)(iu)(ua)(ue)(ui)(uo)" + \
         r"(AI)(EI)(OI)(AU)(EU)(IA)(IE)(IO)(IU)(UA)(UE)(UI)(UO)" + \
        r"aeiouàèéìòù" + \
        r"AEIOUÀÈÉÌÒÙ]"
CONSONANT = r"[b-df-hj-np-tv-z" + \
             r"B-DF-HJ-NP-TV-Z]"
ACCEPTED_BETWEEN = set(["a", "o'", "'n'"])

DICT = enchant.Dict("it_IT")


def check_enchant(txt):
    "Check if the word is in the italian dictionary"   
    return list(filter(lambda x: not DICT.check(x),
                       re.findall(r"\b\S+\b", txt)))


def expand_hashtag(ha):
    "Expand an hashtag to plain text"
    return re.sub(r"([A-Z][a-z]+)", r"\1 ", ha).split()


def check_syllabes(txt):
    "Check if a word does not follow Italian syllabes rule"
    # txt = re.sub("_", " ", txt)  # remove underscores
    txt = re.sub(r"\b\d+\b", "", txt)  # remove numbers
    # consider just words
    txt = " ".join(filter(lambda x: x not in CONTRACTIONS,
                          re.findall(r"\b\w{2,}\b", txt)))
    # apply Italian syllabes rule to check if a word can be an italian word
    syllabe = r"(?:" + CONSONANT + r"?){0,3}" + VOCAL + CONSONANT + r"?"
    # remove all words that match the syllabe regex
    txt = re.sub("\\b({})+\\b".format(syllabe), "", txt)
    # return words that does not match the syllabe regex
    return txt.split()


def expand_contraction(word, check=True):
    "Expand a contracted word and check it on the italian dictionary"
    # return the expanded word or a void string
    word = word.lower()
    if word in CONTRACTIONS:
        return ""
    word = re.sub(r"x", "per", word)
    word = re.sub(r"k", "ch", word)
    if check:
        return word if check_enchant(word) != "" else ""
    return word


def accept_between(str1, str2, txt):
    btw = re.search(r"\b" + re.escape(str1) + r"\b" +
                    r"\s+(\S+)\s+" +
                    r"\b" + re.escape(str2) + r"\b",
                    txt)
    if btw:
        btw = btw.groups()[0]
        return btw if btw.lower() in ACCEPTED_BETWEEN else False
    return False


def is_near(str1, str2, txt):
    "Check if two elements are near"
    return bool(re.search(r"\b" + re.escape(str1) + r"\b\s+" +
                          r"\b" + re.escape(str2) + r"\b", txt))


def concat_words(istances, txt):
    "Concatenate istances that are near in the text"
    # se c'è una sola istanza (o nessuna) lascia perdere
    if len(istances) <= 1:
        return istances
    # calcola tutte le possibilità
    for words in permutations(istances, 2):
        # se due istanze sono vicine, uniscile e riparti da capo
        if is_near(words[0], words[1], txt):
            return concat_words(set([" ".join(list(words))]) |
                                (istances - set(words)),
                                txt)
        # se c'è una sola parola in mezzo (da una lista di parole ammesse),
        # inglobala e riparti da capo
        btw = accept_between(words[0], words[1], txt)
        if btw:
            print(btw)
            return concat_words(set([" {} ".format(btw).join(list(words))]) |
                                (istances - set(words)),
                                txt)
    return istances


for t in txt:
    # rimozione link (complicano solamente l'analisi)
    t = re.sub(r"\b(https?:\/\/|www\.|pic\.)[^\b]+", "", t)
    # leggera pulizia della stringa
    t = re.sub(r"\n", " ", t)
    t = re.sub(r"_", " ", t)
    t = re.sub(r"\.(\S)", r". \1", t)
    # vediamo di che si tratta...
    print(t)
    # individua gli hashtag
    hashtag = list(map(expand_hashtag, re.findall(r"(?<=#)\w+", t)))
    t = re.sub(r"\#\S+\b", "", t)
    hashtag = list(flatten(*hashtag))
    # controlla gli hashtag
    hashtag = list(filter(lambda x: check_enchant(x), hashtag))
    # individua le istanze
    istances = list(filter(expand_contraction, check_enchant(t)))
    # aggiungi gli hashtag alle istanze
    istances += list(filter(expand_contraction, hashtag))
    # aggiungi le parole palesemente straniere
    istances += check_syllabes(t)
    # elimina gli spazi superflui
    istances = list(map(lambda x: re.sub(r"\s+", "", x), istances))
    # concatena le istanze
    istances = concat_words(set(istances), t)
    print(istances)
    print("")
