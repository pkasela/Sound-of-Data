from kafka import KafkaProducer
from kafka import SimpleProducer, KafkaClient
from kafka import KafkaConsumer, TopicPartition
import json
from __future__ import absolute_import, print_function
import tweepy
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
from bs4 import BeautifulSoup
import requests

#Scrape the list of all genres from musicbrainz to generate the list of keywords for filtering tweets
url = 'https://musicbrainz.org/genres'
data = requests.get(url)
soup = BeautifulSoup(data.text, 'html.parser')
content = soup.find_all("div",id='content')[0] 
genres = content.find_all("li")
genre_list = []
for g in genres:
	result = g.text.strip()
	genre_list.append(result)
print('Total number of genres: ' + str(len(genre_list)))

#Create a secret.json file with the twitter keys in it.
with open("secret.json", "r") as f:
    secret = json.load(f)
    consumer_key=secret["CONSUMER_KEY"]
    consumer_secret=secret["CONSUMER_SECRET"]

    access_token=secret["ACCESS_TOKEN"]
    access_token_secret=secret["ACCESS_TOKEN_SECRET"]

#Inizialize Botometer API:
mashape_key = "<X-RapidAPI-Key from https://rapidapi.com/OSoMe/api/botometer>"
twitter_app_auth = {
    'consumer_key': consumer_key,
    'consumer_secret': consumer_secret,
    'access_token': access_token,
    'access_token_secret': access_token_secret,
  }
bom = botometer.Botometer(wait_on_ratelimit=True,
                          mashape_key=mashape_key,
                          **twitter_app_auth)

#Initialize blacklist:
blacklist = []
i = 0

#Naming and initializing the Topic
KafkaTopic="Music_Tweets"            

class Listener(StreamListener):
    
    #Defining the function filtering tweets:
    def tweet_preparations(data_):
        data = {'user': {'screen_name':data_["user"]["screen_name"]},
                'text':data_['text'],
               'truncated':data_["truncated"]}
	if data["user"]["screen_name"] in blacklist:
		print("User has an elevate probability of being a BOT")
		return False
	elif bom.check_account(data["user"]["screen_name"])['scores']['universal'] > 0.9:
		blacklist[i]=data["user"]["screen_name"]
		i = i+1
		print("User has an elevate probability of being a BOT")
		return False
        else:
            if data["truncated"] == True:
                    data["text"] = data_["extended_tweet"]["full_text"]
            for i in ['truncated','extended_tweet']:
                data.pop(i)
            if (FunzioneMarco):
                return FunzioneMarco(data)
            else:
                print("Tweet does not actually talk about music")

    def on_data(self, data):
        data = json.loads(data)
        if bool(tweet_preparations(data)):
            data = tweet_preparation(data)
            producer.send_messages("KafkaTopic",data)
        else:
            tweet_preparation(data)
        return True
	
    def on_error(self, status_code): 
	print (status_code)
	attempts = 0 
        if status_code in [420,500,502,503,504]:
	    attempts = attempts + 1
	    time.sleep(1800) #Sleep for 30 minutes and re-try
	    print("Timeout in seconds: ", attempts*1800) #Print the time the process has been out
            return False 
	    #returning 'False' in on_data and disconnects the stream
	
    def on_timeout(self):
        time.sleep(1800)
        return True 
	
# 420 when exceed the number of attempts to connect to the API in a window of time
# 500 when an internal server error has occurred
# 502 when twitter is down, or being upgraded
# 503 when twitter servers are overloaded with requests
# 504 when twitter servers are up but the request couldn’t be serviced due to some failure within the internal stack
 
kafka = KafkaClient("localhost:9092") 
producer = SimpleProducer(kafka)

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

myListener = Listener() 
stream = Stream(auth, myListener)

while True:
	stream.filter(track=genre_list,languages="it") 
