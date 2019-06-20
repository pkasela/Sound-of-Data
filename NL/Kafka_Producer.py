#from kafka import SimpleProducer, KafkaClient
from kafka import KafkaProducer
import json
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
import botometer
import re
import time
import riak
from musicbrainz_prova import get_musicbrainz_id as FunzioneMarco
from generi import get_genres
#import ipdb; #needed for debugging

# Scrape the list of all genres from musicbrainz to generate the list of
# keywords for filtering tweets
genre_list = get_genres()
print('Total number of genres: ' + str(len(genre_list)))

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
        value = store_user(user)
        print("User {} has a probability of {} to be a bot".format(user,
                                                                   value))
    return value > BOT_PROB


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
bom = botometer.Botometer(wait_on_ratelimit=True,
                          mashape_key=mashape_key,
                          **twitter_app_auth)

# Initialize blacklist:
# blacklist = ['starreldred14', 'chelseacusack8']
# Already detected 67 "white" italian users from previous attempts
# whitelist = ['SENBreakfast', 'TequilaSh0tz', 'sivadredips', 'TaeTaeMyDrug_',
#            '_chiarawho', 'francy2270', 'carla_milf', 'scar15385',
#              'lamattinaste', 'samjdbozn', 'JuanitoSal8', 'evviva_il_re',
#              'ElisabettaMacha', 'paradisoa1', 'CASTALDIAc', 'Alexia_1223',
#              'ROSARIOSIDOTI', 'rpGianluca', 'barbiere_enzo', 'jsscamrno',
#              'DottOlivieri', 'WBOM_Radio', 'dearsnowbarry', 'angelo72518525',
#              'marco_marsella', 'Opiccio0320', 'martinahot88', 'SinC_Italia',
#              'leo_the_teacher', 'biagioamalfi', '__Enrica__',
#              'truemetalonline', 'Percivalgull4', 'cerco_lavoro', 'InfoAmb',
#              'Nico_Cart', 'natysettantuno', 'FedericoBetton3', 'mikashands',
#              'AgCultNews', 'GiusPecoraro', 'marta_ron4', 'antoniodigi',
#              'radioitaliaint', 'cougaritaliane', 'tattooevhoney', 'wandamvu',
#              'Infinitejest19', 'Erica91638389', 'UnTemaAlGiorno',
#              'roberto01012023', 'CurvaStone', 'DavidCelisq', 'VickyDream_CAM',
#              'NamidaNoAki2', 'sportparma', 'soIskjaers', 'CryPaolo',
#              'ianshappjness', 'puresoultae', 'eniiolucherini',
#              'tropicalisimany', 'MarcoSforzato', 'xhyunjinie',
#              'LaJambeNoir7', 'Lalocanda6', 'noitsirene']

# Naming and initializing the Topic
KafkaTopic = "Music_Tweets"


def remove_spaces(txt):
    return re.sub('@[A-z0-9]+','',re.sub(r"[\n\t\\]", " ", txt).replace("RT",""))
    #It also removes the initial part with RT(retweet) @user_retweeted,
    # since it is recognized as an enitity but is not a musical one


class Listener(StreamListener):
    # Defining the function filtering tweets:
    def tweet_preparations(self, data_):
        data_ = data_._json
        data = {'user': data_["user"]["screen_name"],
                'text': remove_spaces(
                    data_["extended_tweet"]["full_text"] if data_["truncated"]
                    else data_["text"]),
                'created_at': data_['created_at'],
        }
        if user_is_a_bot(data["user"]["screen_name"]):
            return ""
        else:
            data = FunzioneMarco(data)
            if (len(data['relation']) > 0:
                return str(data).encode("utf-8")
            else:
                print("Tweet '" + data_["text"] +
                      "' does not actually talk about music.")
                return ""

    def on_status(self, data):
        data = self.tweet_preparations(data)
        if len(data.decode()) > 0:
            print(data)
            #ipdb.set_trace()
            producer.send("Prova", data)
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


#kafka = KafkaClient("localhost:6667")
#producer = SimpleProducer(kafka)
producer = KafkaProducer(bootstrap_servers='sandbox-hdp.hortonworks.com:6667')

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

myListener = Listener()
stream = Stream(auth, myListener)

while True:
    stream.filter(track=[genre_list[i] for i in range(400)],
                  languages=["it"])
####Need to tell him not to remove the last 19 genres, but the one we want to remove
