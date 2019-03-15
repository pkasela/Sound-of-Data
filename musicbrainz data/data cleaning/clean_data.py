import time
start_time=time.time()

import pandas as pd

df = pd.read_csv('../mbdump/mbdump/artist',sep='\t',header=None)
df.replace('\\N','',inplace=True)

df.columns=['id','gid','name','sort_name','begin_date_year','begin_date_month','begin_date_day',
            'end_date_year','end_date_month','end_date_day','ended','type','gender','area','begin_area',
           'end_area','comment','edits_pending','last_updated']

df.to_csv('artist.csv',index=None)

print("Program executed in %s seconds" % (time.time()-start_time))
