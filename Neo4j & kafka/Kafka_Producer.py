from kafka import KafkaProducer
from kafka import SimpleProducer, KafkaClient
from kafka import KafkaConsumer, TopicPartition
import json
from __future__ import absolute_import, print_function
import tweepy
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream

#Create a secret.json file with the twitter keys in it.
with open("secret.json", "r") as f:
    secret = json.load(f)
    consumer_key=secret["CONSUMER_KEY"]
    consumer_secret=secret["CONSUMER_SECRET"]

    access_token=secret["ACCESS_TOKEN"]
    access_token_secret=secret["ACCESS_TOKEN_SECRET"]

KafkaTopic="Music_Tweets"

class Listener(StreamListener):
    def on_status(self, status):
	#Here we'll insert NLP function
        producer.send_messages(KafkaTopic,status._json['text'].encode('utf-8'))  
        return True

    def on_error(self, status): 
        print (status)
        if status_code in [420,500,502,503,504]: 
            return False 
	    #returning 'False' in on_data and disconnects the stream
	
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
	stream.filter(track="vaxination") #In track we'll insert the list of key words
