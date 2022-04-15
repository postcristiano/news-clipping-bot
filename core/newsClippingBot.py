#!/opt/news-clipping-bot/settings/venv/bin/python

import json
import requests
import urllib


token_file = open('/opt/news-clipping-bot/settings/token.txt')
content = token_file.readlines()

TOKEN=(content[0]).replace("\n", "")
URL = "https://api.telegram.org/bot{}/".format(TOKEN)
USERNAME_BOT=(content[1]).replace("\n", "")
token_file.close


def get_url(url):
    response = requests.get(url)
    content = response.content.decode("utf8")
    return content


def get_json_from_url(url):
    content = get_url(url)
    js = json.loads(content)
    return js


def get_updates(offset=None):
    url = URL + "getUpdates?timeout=100"
    if offset:
        url += "&offset={}".format(offset)
    js = get_json_from_url(url)
    return js


def get_last_update_id(updates):
    update_ids = []
    for update in updates["result"]:
        update_ids.append(int(update["update_id"]))
    return max(update_ids)


def echo_all(updates):
    for update in updates["result"]:
        if update.get("message") != None:
            if update.get("message", {}).get("text") != None:
                text = update["message"]["text"]
                chat = update["message"]["chat"]["id"]
                print(text)

                if text == "/start" or text == "/start@" + USERNAME_BOT:
                    text = "👋 Welcome ! \n 📌 Want to know the latest news ?  \n 📌 Send \"news\" to receive the daily clipping.\n"
                    send_message(text, chat)
                    continue
                if text == "news":
                    send_message("Stay up to date with the latest news now:\n", chat)
                    with open("/opt/news-clipping-bot/settings/news.txt", "r") as news_file:
                        for n in news_file:
                            print_news = n.strip()
                            send_message(print_news, chat)
                    send_message("\n enjoy it ! \n ✅✅ \n", chat)
                    continue
                else:
                    send_message("📌 Send \"news\" to receive the daily clipping ! \n", chat)
                    send_message("🤬🤬🤬 !!! \n", chat)


def send_message(text, chat_id):
    tot = urllib.parse.quote_plus(text)
    url = URL + "sendMessage?text={}&chat_id={}".format(tot, chat_id)
    get_url(url)


def main():
    last_update_id = None
    while True:
        updates = get_updates(last_update_id)
        if updates is not None:
            if len(updates["result"]) > 0:
                last_update_id = get_last_update_id(updates) + 1
                echo_all(updates)

if __name__ == '__main__':
    main()