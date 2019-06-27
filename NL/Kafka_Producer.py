from kafka import KafkaProducer
import json
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
import re
import time
from generi import get_genres
from urllib3.exceptions import ProtocolError
#import ipdb; #needed for debugging

# genres to follow on twiiter
genre_list = get_genres()
print('Total number of genres: ' + str(len(genre_list)))


# Create a secret.json file with the twitter keys in it.
with open("secret.json", "r") as f:
    secret = json.load(f)
    consumer_key = secret["CONSUMER_KEY"]
    consumer_secret = secret["CONSUMER_SECRET"]

    access_token = secret["ACCESS_TOKEN"]
    access_token_secret = secret["ACCESS_TOKEN_SECRET"]

    # create also this field in the secret.json
    X_RapidAPI_Key = secret["X_RapidAPI_Key"]
    # Get Your X-RapidAPI-Key from https://rapidapi.com/OSoMe/api/botometer

# Inizialize Botometer API:
mashape_key = X_RapidAPI_Key
twitter_app_auth = {
    'consumer_key': consumer_key,
    'consumer_secret': consumer_secret,
    'access_token': access_token,
    'access_token_secret': access_token_secret,
  }

# Naming and initializing the Topic
KafkaTopic = "InitialTopic"


class Listener(StreamListener):

    def on_status(self, data):
        print(data._json)
        producer.send(KafkaTopic, json.dumps(data._json).encode("utf-8"))
        #else:
        #    self.tweet_preparations(data)
        return True

    def on_error(self, status_code):
        print(status_code)
        attempts = 0
        if status_code in [420, 500, 502, 503, 504]:
            attempts = attempts + 1
            time.sleep(1800)  # Sleep for 30 minutes and re-try
            # Print the time the process has been out
            print("Timeout in seconds: ", attempts * 1800)
            # returning 'False' in on_data and disconnects the stream
            return False

    def on_timeout(self):
        time.sleep(1800)
        return True

# 420 when exceed the number of attempts to connect to the
#     API in a window of time
# 500 when an internal server error has occurred
# 502 when twitter is down, or being upgraded
# 503 when twitter servers are overloaded with requests
# 504 when twitter servers are up but the request couldn’t
#     be serviced due to some failure within the internal stack

producer = KafkaProducer(bootstrap_servers='sandbox-hdp.hortonworks.com:6667')

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

myListener = Listener()
stream = Stream(auth, myListener)

while True:
    try:
       stream.filter(track=['#' + genre for genre in genre_list],
                     languages=["it"], is_async=True)
    except (ProtocolError, AttributeError):
       print("Ops! Something went wrong")
       continue
