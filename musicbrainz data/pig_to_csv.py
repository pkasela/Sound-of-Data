import sys

print("id,gid,name,sort_name,begin_date_year,begin_date_month,\
begin_date_day,end_date_year,end_date_month,end_date_day,ended,\
type,gender,area,begin_area,end_area,comment,\
edits_pending,last_updated")

for line in sys.stdin:
    print(line.replace("\\N","").strip('()\n'))
        
