#perdonate il codice di scarso livello

#devo aggiungere il riconoscimento generi e la gestione input dal prova2.py



import musicbrainzngs

musicbrainzngs.set_useragent("Sound of Data", "0.1")

#presupponendo che il tipo di ogni entità sia conosciuto 

artisti = ["francesco gabbani","pooh","porcupine tree","vasco Rossi"]
album = ["in absentia"]
recording = ["the sound of muzak"]



def find_artist(artisti):
  #trovo gli id degli artisti presenti 
  listartist = []
  for i in artisti:
  	result = musicbrainzngs.search_artists(i,limit=1)
	if len(result["artist-list"]) > 0:
      		listartist.append(result["artist-list"][0]["id"])

	return(listartist)
 
    

def find_artist_album(album): 
  #trovo gli id degli artisti per l'album
	listartistalbum = []
	for j in album:
		result = musicbrainzngs.search_release_groups(j)
		for release in result['release-group-list']:
			ir=release
			for artistc in ir['artist-credit']:
				if 'artist' in artistc:
					listartistalbum.append(artistc['artist'].get("id"))
   
	return(listartistalbum)

  
#controllo se ci sono corrispondenze tra gli artisti dell'album e quelli già trovati 
common_elements = (list(set(find_artist_album(album)).intersection(find_artist(artisti))))


def find_album(album):
  #trovo gli id degli album presenti
	listalbum = []
	for h in album:
		result = musicbrainzngs.search_release_groups(h)
		if len(common_elements)==0:   
			listalbum.append(result['release-group-list'][0]["id"])
      #se non ci sono corrispondenze ritorno il primo risultato
		else:
			for release in result['release-group-list']:
				ir=release
				for artistc in ir['artist-credit']:
					if 'artist' in artistc:
						if (artistc['artist'].get("id")) in common_elements:
							listalbum.append(release.get("id"))
							
	return(listalbum[0])						
							
							



def find_artist_record(recording):
  #trovo gli id degli artisti per la traccia cercata
	listartistrecord = []
	for j in recording:
		result = musicbrainzngs.search_recordings(j)
		for record in result['recording-list']:
			ir=record
			for artistc in ir['artist-credit']:
				if 'artist' in artistc:
					listartistrecord.append(artistc['artist'].get("id"))
   
	return(listartistrecord)


#controllo se ci sono corrispondenze tra gli artisti della traccia e quelli già trovati 
common_elements = (list(set(find_artist_record(recording)).intersection(find_artist(artisti))))


def find_record(recording):
  #trovo gli id delle tracks
	listarecord = []
	for h in recording:
		result = musicbrainzngs.search_recordings(h,limit = 75)
		if len(common_elements)==0:
			listarecord.append(result['recording-list'][0]["id"])
		else:
			for record in result['recording-list']:
				ir=record
				for artistc in ir['artist-credit']:
					if 'artist' in artistc:
						if (artistc['artist'].get("id")) in common_elements:
							if 'disambiguation' not in record:
								listarecord.append(record.get("id"))
							
	return (listarecord[0])
 


id_trovati = find_artist(artisti)
id_trovati.append(find_album(album))
id_trovati.append(find_record(recording))
print(id_trovati)
