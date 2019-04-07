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

KafkaTopic="89" #Random name, to be decided later, prbably will be tweets :D

class StdOutListener(StreamListener):
    def on_status(self, status):
	#Quali altri campi oltre user.screen_name, text?
        producer.send_messages(KafkaTopic,status._json['text'].encode('utf-8'))  
        return True
    def on_error(self, status):
        print (status)

kafka = KafkaClient("localhost:9092")
producer = SimpleProducer(kafka)

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

myListener = StdOutListener() 
#Why to use StdOutListner instead of Listner (Are there some benefits?)
stream = Stream(auth, myListener)
stream.filter(track="vaxination")
