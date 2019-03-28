from kafka import KafkaProducer
from kafka import SimpleProducer, KafkaClient
from kafka import KafkaConsumer, TopicPartition
import json
from __future__ import absolute_import, print_function
import tweepy
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream

consumer_key=""
consumer_secret=""
access_token=""
access_token_secret=""

class StdOutListener(StreamListener):
    def on_status(self, status):
        producer.send_messages("89",status._json['text'].encode('utf-8')) #Quali altri campi oltre user.screen_name, text? 
        return True
    def on_error(self, status):
        print (status)

kafka = KafkaClient("localhost:9092")
producer = SimpleProducer(kafka)
l = StdOutListener()
auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
stream = Stream(auth, l)
stream.filter(track="trump")
