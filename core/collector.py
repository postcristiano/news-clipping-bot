#!/opt/news-clipping-bot/settings/venv/bin/python

import os
from datetime import date, datetime, timedelta


SETTINGS_PATH = "/opt/news-clipping-bot/settings/"

today = date.today()
end_date = today
now = datetime.now()
date_time = now.strftime("%m/%d/%Y, %H:%M:%S")

search_term = "" 
from_date = today - timedelta(days=1)
max_results = 10


def collect_with_sources():
    source_path = ""
    os.system(f"echo '' > {SETTINGS_PATH}news.txt")
    with open(f"{SETTINGS_PATH}sources.txt", "r") as source_file:
        for p in source_file:
            profiles = p.strip()
            read_source = open(f"{SETTINGS_PATH}news.txt", "a")
            read_source.write("📰📰📰 " + p.replace("\n", " ") + " 📰📰📰" +"\n-Harvest atcrons: " + date_time + " -\n")
            read_source.close()
            extracted_tweets = "/opt/news-clipping-bot/settings/venv/bin/snscrape --format '{content!r}'"+ f" --max-results {max_results} --since {from_date} twitter-user '{profiles}' >> {SETTINGS_PATH}news.txt"
            os.system(extracted_tweets)


collect_with_sources()