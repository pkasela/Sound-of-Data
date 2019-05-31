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

KafkaTopic="Music_Tweets"

#Defining the the function filtering tweets:
def tweet_preparations(data):
        data = {'user': {'screen_name':data["user"]["screen_name"]},
                'text':data['text'],
               'truncated':data["truncated"],
               'retweet_count':data["retweet_count"],
               'extended_tweet': {'full_text':data["extended_tweet"]["full_text"]}}
        if data["retweet_count"] >= 10:
                print("Tweet has been eliminated since could have been tweeted by a bot")
                return False
        else:
            if data["truncated"] == True:
                    data["text"] = data["extended_tweet"]["full_text"]
            for i in ['truncated','retweet_count','extended_tweet']:
                data.pop(i)
                #if (FunzioneMarco==True):
                    #data = data.apply(FunzioneMarco)
                #else:
                    #print("Tweet has been eliminated since it actually does not talk about music")
            return data
            return True
#IT GIVES ME A STRANGE ERROR: "extended_tweets"

class Listener(StreamListener):
    def on_data(self, data):
        data = json.loads(data)
        if(tweet_preparations(data)!=False):
            data = tweet_preparation(data)
            producer.send_messages(KafkaTopic,data)
        return True
	
    def on_error(self, status): 
	print (status)
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
 
kafka = KafkaClient("localhost:9092") #I am using the Docker, thus I'll use the port of the containe "19092"
producer = SimpleProducer(kafka)

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

myListener = Listener() 
stream = Stream(auth, myListener)

while True:
	stream.filter(track=genre_list,languages="en") 
