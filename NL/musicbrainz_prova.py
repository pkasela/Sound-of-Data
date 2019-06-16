
#perdonate il codice di scarso livello

import musicbrainzngs
import prova2 as momo


musicbrainzngs.set_useragent("Sound of Data", "0.1")


def get_musicbrainz_id(dizionario):
    input = dizionario.get("text")
    frase_input = momo.get_istances(input)
    artisti = list(frase_input[0])
    recording = list(frase_input[1])
    NS = list(frase_input[2]) # lo si prova per album,artisti e recording
    generi = frase_input[3]
    
    #controllo se ci sono corrispondenze tra gli artisti dell'album e quelli già trovati
    common_elements_11 = (list(set(find_artist_album(NS)).intersection(find_artist(artisti))))
    common_elements_12 = (list(set(find_artist_album(NS)).intersection(find_artist_NS(NS))))
    common_elements_1 = common_elements_11 + common_elements_12
    
    #controllo se ci sono corrispondenze tra gli artisti della traccia e quelli già trovati 
    common_elements_21 = (list(set(find_artist_record(recording)).intersection(find_artist(artisti))))
    common_elements_22 = (list(set(find_artist_record(recording)).intersection(find_artist_NS(NS))))
    common_elements_2 = common_elements_21 + common_elements_22
    
    dizionario['artist'] = find_artist(artisti) + find_artist_NS(NS)
    dizionario['album'] = find_album(NS,common_elements_1)
    dizionario['recording'] = find_record(recording,common_elements_2) + find_record_NS(NS,artisti)

    return(dizionario)



def find_artist(artisti):
    #trovo gli id degli artisti presenti
    listartist = []
    for i in artisti:
        result = musicbrainzngs.search_artists(i + "~0.9",limit=1)
        if len(result["artist-list"]) > 0:
            listartist.append(result["artist-list"][0]["id"])

    return(listartist)




def find_artist_NS(NS):
    #trovo gli id degli artisti presenti,essendo l'input il set con i not sure
    #aggiunto un ulteriore controllo per diminuire le possibilità che ritorni id errati
    listartistNS = []
    for i in NS:
        result = musicbrainzngs.search_artists(i + "~0.9")
        if len(result["artist-list"]) > 0:
            for artists in result['artist-list']:
                ir=artists
                if ir.get("name").lower()==i.lower():
                    listartistNS.append(artists.get("id"))

    return(listartistNS)




def find_artist_album(album): 
    #trovo gli id degli artisti per l'album
    listartistalbum = []
    for j in album:
        result = musicbrainzngs.search_release_groups(j + "~0.9")
        for release in result['release-group-list']:
            ir=release
            for artistc in ir['artist-credit']:
                if 'artist' in artistc:
                    listartistalbum.append(artistc['artist'].get("id"))
   
    return(listartistalbum)


def find_album(album,common_elements_1):
    #trovo gli id degli album presenti
    listalbum = []
    for h in album:
        result = musicbrainzngs.search_release_groups(h + "~0.9")
        if len(result["release-group-list"]) > 0:
            if len(common_elements_1)==0:
                if result['release-group-list'][0]["primary-type"] != "Single":
                    listalbum.append(result['release-group-list'][0]["id"])
                #se non ci sono corrispondenze ritorno il primo risultato
            else:
                for release in result['release-group-list']:
                    ir=release
                    for artistc in ir['artist-credit']:
                        if 'artist' in artistc:
                            if (artistc['artist'].get("id")) in common_elements_1:
                                if ir.get("title").lower()==h.lower():
                                    if result.get('primary-type') != "Single":
                                        #anche qua aggiunto ulteriore controllo per diminuire possibili errori
                                        listalbum.append(release.get("id"))
    return(listalbum)



def find_artist_record(recording):
    #trovo gli id degli artisti per la traccia cercata
    listartistrecord = []
    for j in recording:
        result = musicbrainzngs.search_recordings(j + "~0.9")
        for record in result['recording-list']:
            ir=record
            for artistc in ir['artist-credit']:
                if 'artist' in artistc:
                    listartistrecord.append(artistc['artist'].get("id"))
   
    return(listartistrecord)



def find_record(recording,common_elements_2):
    #trovo gli id delle tracks
    listarecord = []
    for h in recording:
        result = musicbrainzngs.search_recordings(h + "~0.9",limit = 75)
        if len(result["recording-list"]) > 0:
            if len(common_elements_2)==0:
                for record in result['recording-list']:
                    if record.get("title").lower()==h.lower():
                        if 'disambiguation' not in record:
                            if int(record.get("ext:score")) > 90:
                                if 'length' in record:
                                    listarecord.append(record.get("id"))
                                    break
                #aggiunti controlli per evitare di restituire troppi id
            else:
                for record in result['recording-list']:
                    ir=record
                    for artistc in ir['artist-credit']:
                        if 'artist' in artistc:
                            if (artistc['artist'].get("id")) in common_elements_2:
                                if 'disambiguation' not in record:
                                    #elimina una parte delle eventuali versioni alternative delle tracks,come ad esempio le live
                                    if int(record.get("ext:score")) > 90:
                                        if 'length' in record:
                                            listarecord.append(record.get("id"))

    return (listarecord)
 

    
def find_record_NS(recording,artisti):
    #trovo gli id delle tracks
    listarecordNS = []
    for h in recording:
        if len(artisti) > 0:
            for a in artisti:
                result = musicbrainzngs.search_recordings(h + "~0.9" + " AND " + "artist:" + a + "~0.9")
                if len(result["recording-list"]) > 0:
                    for record in result['recording-list']:
                        if record.get("title").lower()==h.lower():
                            if 'disambiguation' not in record:
                                #tutti controlli ulteriori per evitare di restituire troppi id
                                listarecordNS.append(record.get("id"))
                                break
        else:
            result = musicbrainzngs.search_recordings(h + "~0.9")
            if len(result["recording-list"]) > 0:
                for record in result['recording-list']:
                    if record.get("title").lower()==h.lower():
                        if 'disambiguation' not in record:
                            if int(record.get("ext:score")) > 90:
                                if 'length' in record:
                                    #tutti controlli ulteriori per evitare di restituire troppi id
                                    listarecordNS.append(record.get("id"))
                                    break
                

    return(listarecordNS)
 


