
#perdonate il codice di scarso livello

import musicbrainzngs
import Entity_Finder


musicbrainzngs.set_useragent("Sound of Data", "0.1")


def get_musicbrainz_id(dizionario):
    input = dizionario.get("text")
    frase_input = Entity_Finder.get_istances(input)
    artisti = list(frase_input[0])
    recording = list(frase_input[1])
    NS = list(frase_input[2]) # lo si prova per album,artisti e recording
    generi = frase_input[3]


    artist_found = find_artist(artisti)
    artist_found_NS = find_artist_NS(NS)
    if len(artist_found_NS['found'])>0:
        NS = set(NS) - set(artist_found_NS['found'])
    #controllo se ci sono corrispondenze tra gli artisti dell'album e quelli già trovati
    #common_elements_11 = (list(set(find_artist_album(NS)).intersection(artist_found)))
    #common_elements_12 = (list(set(find_artist_album(NS)).intersection(artist_found_NS)))
    #common_elements_1  = common_elements_11 + common_elements_12

    #controllo se ci sono corrispondenze tra gli artisti della traccia e quelli già trovati
    #common_elements_21 = (list(set(find_artist_record(recording)).intersection(artist_found)))
    #common_elements_22 = (list(set(find_artist_record(recording)).intersection(artist_found_NS)))
    #common_elements_2  = common_elements_21 + common_elements_22

    dizionario['artists']    = artist_found + artist_found_NS['gids']
    album_found    = find_album(NS)
    if len(album_found['found'])>0:
        NS = set(NS) - set(album_found['found'])
    dizionario['release'] = album_found['gids']
    dizionario['recordings'] = find_record(recording) + find_record_NS(NS,artisti)
    dizionario['genres']     = generi

    #dizionario['gids'] = artists + albums + recordings + generi

    return(dizionario)



def find_artist(artisti):
    #trovo gli id degli artisti presenti
    listartist = []
    for i in artisti:
        result = musicbrainzngs.search_artists(i + "~0.95",limit=1)
        if len(result["artist-list"]) > 0:
            listartist.append(result["artist-list"][0]["id"])

    return(listartist)




def find_artist_NS(NS):
    #trovo gli id degli artisti presenti,essendo l'input il set con i not sure
    #aggiunto un ulteriore controllo per diminuire le possibilità che ritorni id errati
    listartistNS = []
    found = []
    for i in NS:
        result = musicbrainzngs.search_artists(i + "~0.95")
        if len(result["artist-list"]) > 0:
            for artists in result['artist-list']:
                if artists.get("name").lower()==i.lower():
                    listartistNS.append(artists.get("id"))
                    found.append(i)
                    break

    return({'gids':listartistNS,'found':found})




def find_artist_album(album):
    #trovo gli id degli artisti per l'album
    listartistalbum = []
    for j in album:
        result = musicbrainzngs.search_release_groups(j + "~0.95")
        for release in result['release-group-list']:
            ir=release
            for artistc in ir['artist-credit']:
                if 'artist' in artistc:
                    listartistalbum.append(artistc['artist'].get("id"))

    return(listartistalbum)


def find_album(album):
    #trovo gli id degli album presenti
    listalbum = []
    found = []
    for h in album:
        result = musicbrainzngs.search_release_groups(h + "~0.95")
        if len(result["release-group-list"]) > 0:
            listalbum.append(result['release-group-list'][0]['id'])
            found.append(h)
        #if len(result["release-group-list"]) > 0:
          #  if len(common_elements_1)==0:
               # if 'primary-type' in result['release-group-list'][0]:
               #     if result['release-group-list'][0]["primary-type"] != "Single":
               #         listalbum.append(result['release-group-list'][0]["id"])
                        #se non ci sono corrispondenze ritorno il primo risultato
           # else:
            #    for release in result['release-group-list']:
            #        ir=release
            #        for artistc in ir['artist-credit']:
            #            if 'artist' in artistc:
            #                if (artistc['artist'].get("id")) in common_elements_1:
            #                    if ir.get("title").lower()==h.lower():
            #                        if 'primary-type' in ir:
            #                            if ir.get('primary-type') != "Single":
            #                                #anche qua aggiunto ulteriore controllo per diminuire possibili errori
            #                                listalbum.append(release.get("id"))
    return({'gids':listalbum,'found':found})



def find_artist_record(recording):
    #trovo gli id degli artisti per la traccia cercata
    listartistrecord = []
    for j in recording:
        result = musicbrainzngs.search_recordings(j + "~0.95")
        for record in result['recording-list']:
            ir=record
            for artistc in ir['artist-credit']:
                if 'artist' in artistc:
                    listartistrecord.append(artistc['artist'].get("id"))

    return(listartistrecord)



def find_record(recording):
    #trovo gli id delle tracks
    listarecord = []
    for h in recording:
        result = musicbrainzngs.search_recordings(h + "~0.95",limit = 75)
        if len(result["recording-list"]) > 0:
            listarecord.append(result['recording-list'][0]['id'])
        #if len(result["recording-list"]) > 0:
        #    if len(common_elements_2)==0:
        #        for record in result['recording-list']:
        #            if record.get("title").lower()==h.lower():
        #                if 'disambiguation' not in record:
        #                    if int(record.get("ext:score")) > 90:
        #                        if 'length' in record:
        #                            listarecord.append(record.get("id"))
        #                            break
                #aggiunti controlli per evitare di restituire troppi id
        #    else:
        #        for record in result['recording-list']:
        #            ir=record
        #            for artistc in ir['artist-credit']:
        #                if 'artist' in artistc:
        #                    if (artistc['artist'].get("id")) in common_elements_2:
        #                        if 'disambiguation' not in record:
                                    #elimina una parte delle eventuali versioni alternative delle tracks,come ad esempio le live
        #                            if int(record.get("ext:score")) > 90:
        #                                if 'length' in record:
        #                                    listarecord.append(record.get("id"))

    return (listarecord)



def find_record_NS(recording,artisti):
    #trovo gli id delle tracks
    listarecordNS = []
    for h in recording:
        if len(artisti) > 0:
            for a in artisti:
                result = musicbrainzngs.search_recordings(h + "~0.95" + " AND " + "artist:" + a + "~0.95")
                if len(result["recording-list"]) > 0:
                    for record in result['recording-list']:
                        #if record.get("title").lower()==h.lower(): forse qua è meglio non mettere questo controllo
                            if 'disambiguation' not in record:
                                #tutti controlli ulteriori per evitare di restituire troppi id
                                listarecordNS.append(record.get("id"))
                                break
        else:
            result = musicbrainzngs.search_recordings(h + "~0.95")
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
