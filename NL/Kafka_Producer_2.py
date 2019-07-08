from kafka import KafkaProducer, KafkaConsumer
import time
import riak
from musicbrainz_connector import get_musicbrainz_id
import botometer
import json
import re

with open("secret.json", "r") as f:
    secret = json.load(f)
    consumer_key = secret["CONSUMER_KEY"]
    consumer_secret = secret["CONSUMER_SECRET"]

    access_token = secret["ACCESS_TOKEN"]
    access_token_secret = secret["ACCESS_TOKEN_SECRET"]

    # create also this field in the secret.json
    X_RapidAPI_Key = secret["X_RapidAPI_Key"]

botometer_api_url = 'https://botometer-pro.p.mashape.com'
mashape_key = X_RapidAPI_Key
twitter_app_auth = {
    'consumer_key': consumer_key,
    'consumer_secret': consumer_secret,
    'access_token': access_token,
    'access_token_secret': access_token_secret,
  }
bom = botometer.Botometer(botometer_api_url=botometer_api_url,
                           wait_on_ratelimit=True,
                           mashape_key=mashape_key,
                           **twitter_app_auth)

# Old free botometer
#bom = botometer.Botometer(wait_on_ratelimit=True,
#                          mashape_key=mashape_key,
#                          **twitter_app_auth)

BOT_PROB = 0.9
riak_client = riak.RiakClient()
users = riak_client.bucket("users")

def store_user(user):
    value = bom.check_account(user)['scores']['universal']
    users.new(user, data=value).store()
    return value


def user_is_a_bot(user):
    value = users.get(user).data
    if not value:
        try:
           value = store_user(user)
           print("User {} has a probability of {} to be a bot".format(user,
                                                                      value))
        except:
           print("Ops! Something went wrong with Botometer")
           return False
    return value > BOT_PROB

def remove_spaces(txt):
    return re.sub('@[A-z0-9]+','',re.sub(r"[\n\t\\]", " ", txt).replace("RT",""))
    #It also removes the initial part with RT(retweet) @user_retweeted,
    # since it is recognized as an enitity but is not a musical one


def tweet_preparations(data_):
    data = {'user': data_["user"]["screen_name"],
            'text': remove_spaces(
                data_["extended_tweet"]["full_text"] if data_["truncated"]
                else data_["text"]),
            'created_at': data_['created_at'],
    }
    if user_is_a_bot(data['user']):
        return "".encode("utf-8")
    else:
        try:
            data = get_musicbrainz_id(data)
        except:
            data['genres']=[]
        if len(data['genres']) > 0:
            return json.dumps(data).encode("utf-8")
        else:
            print("Tweet '" + data_["text"] +
                  "' does not actually talk about music.")
            return "".encode("utf-8")

consumer =  KafkaConsumer(bootstrap_servers='sandbox-hdp.hortonworks.com:6667',
                          auto_offset_reset='earliest',
                          consumer_timeout_ms=1000)

consumer.subscribe(['InitialTopic'])
KafkaTopic = "KafkaTopic" #for the producer
producer = KafkaProducer(bootstrap_servers='sandbox-hdp.hortonworks.com:6667')

while True:
    try:
        for message in consumer:
            data=tweet_preparations(json.loads(message.value.decode()))
            print(data)
            producer.send(KafkaTopic, data)
        time.sleep(5)
    except:
        print("Ops! Something went wrong")
        time.sleep(5)
        continue
