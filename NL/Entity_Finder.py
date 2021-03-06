import re
import enchant  # pip install pyenchant
from treetagger import TreeTagger
from itertools import permutations
from itertools import chain as flatten
from generi import get_genres


CONTRACTIONS = set(["", "cmq", "qls", "qlc", "asap", "fb", "wh",
                    "rt", "dvd"])
VOCAL = r"[(ai)(ei)(oi)(au)(eu)(ia)(ie)(io)(iu)(ua)(ue)(ui)(uo)" + \
         r"(AI)(EI)(OI)(AU)(EU)(IA)(IE)(IO)(IU)(UA)(UE)(UI)(UO)" + \
         r"aeiouàèéìòù" + \
         r"AEIOUÀÈÉÌÒÙ]"
CONSONANT = r"[b-df-hj-np-tv-z" + \
             r"B-DF-HJ-NP-TV-Z]"
ACCEPTED_BETWEEN = set(["a", "o'", "'n'", "in"])
ARTIST_ALBUM = r"\s?\b(de?i|dell[ae]|by|[Aa]|[Cc]on|[Gg]li|[Ii]|[Ll][ea])\s"

DICT = enchant.Dict("it_IT")

TAGGER = TreeTagger(path_to_treetagger="./TreeTagger/",
                    language="italian")


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


def resplit_istances(istances, txt):
    "Split the beginning of a sentence by the rest of the istance"
    istances_new = set()
    for i in istances:
        istances_new |= set([i])
        if len(re.findall(r"\s+", i)) == 0:
            continue
        if bool(re.search(r"^" + re.escape(i), txt)) or \
           bool(re.search(r"[\.\:\;\?\!]" + re.escape(i), txt)):
            i_splitted = i.split()
            istances_new |= set([i_splitted[0]] + [" ".join(i_splitted[1:])])
    return istances_new

def get_genere(txt):
    generes = get_genres()
    generes = map(lambda t: re.sub(r"\s+", r"[ |-||]", t),
                  generes)
    generes = map(lambda t: r"\b" + t + r"\b", generes)
    return re.findall(r"|".join(generes), txt.lower())


def try_identify(istances, songs, txt):
    "Try to identify if it is a person or a song"
    names = set()
    miscellanea = set()
    for i in istances:
        if bool(re.search(ARTIST_ALBUM + re.escape(i), txt)) or \
           bool(re.search(r"[@#]" + re.escape(i), txt)):
            names |= set([i])
        elif bool(re.search(re.escape(i) + ARTIST_ALBUM, txt)):
            songs |= set([i])
        else:
            miscellanea |= set([i])
    return names, songs, miscellanea


def get_istances(t):
    "Get all istances of a text"
    # rimozione link (complicano solamente l'analisi)
    t = re.sub(r"\b(https?:\/\/|www\.|pic\.)[^\b]+", "", t)
    # leggera pulizia della stringa
    t = re.sub(r"\n", " ", t)
    t = re.sub(r"_", " ", t)
    t = re.sub(r"\.(\S)", r". \1", t)
    # vediamo di che si tratta...
    print(t)
    # ritorna nullo in caso di stringa vuota
    if re.match(r"^\s*$", t):
        return set(), set(), set(), set()
    gen = get_genere(t)
    # individua gli hashtag
    hashtag = list(map(expand_hashtag, re.findall(r"(?<=[#|@])\w+", t)))
    t = re.sub(r"\#[a-zàèéìòù]+\b", "", t)
    hashtag = list(flatten(*hashtag))
    # controlla gli hashtag
    hashtag = list(filter(lambda x: check_enchant(x), hashtag))
    # individua le istanze
    istances = list(filter(expand_contraction, check_enchant(t)))
    # aggiungi gli hashtag alle istanze
    istances += list(filter(expand_contraction, hashtag))
    # aggiungi le parole palesemente straniere
    istances += check_syllabes(t)
    # aggiungi i presunti nomi propri
    istances += re.findall(r"(?<=\w\s)\b[A-Z][a-zàèéìòù]+\b", t)
    # aggiungi tutti i sostantivi maiuscoli
    istances += [re.sub(r"\W", "", x[0])
                 for x in filter(
                         lambda x: re.match(r"^[A-Z]", x[0]) and
                         re.match("^N", x[1]),
                         TAGGER.tag(t))]
    # elimina gli spazi superflui
    istances = list(map(lambda x: re.sub(r"\s+", "", x), istances))
    # aggiungi le parole tra virgolette
    songs = set(map(lambda e: re.sub("\"", "", e), re.findall(r"\".+?\"", t)))
    # concatena le istanze
    istances = concat_words(set(istances), t)
    # istances = resplit_istances(istances, t)
    names, songs, miscellanea = try_identify(istances, songs, t)
    print("People: ", end="")
    print(names)
    print("Songs: ", end="")
    print(songs)
    print("Not sure: ", end="")
    print(miscellanea)
    print("")
    return names - set(gen), \
           songs - set(gen), \
           miscellanea - set(gen), \
           gen


if __name__ == "__main__":
    PATH = "./"
    with open(PATH + "prova.txt") as f:
        txt = f.readlines()
    for t in txt:
        get_istances(t)
