#!/bin/bash

if [ "$EUID" -ne 0 ] 2> /dev/null > /dev/null
    then echo "It is need run as a root."
    exit
fi

if ! [[ $(lsb_release -rs) == "18.04" || "18.10" || "19.04" || "19.10" || "20.04" || "20.10" || "22.04" ]] 2> /dev/null > /dev/null
    then echo "Unsupported version."
    exit
fi

if ! [[ $(lsb_release -i | cut -f2) == "Ubuntu" || "ubuntu" ]] 2> /dev/null > /dev/null
    then echo "Unsupported OS."
    exit
fi


Menu() {
    echo "Setting News Clipping Bot"
    echo 
    echo "--Options--"
    echo 
    echo "1. Install News Clipping Bot and all necessary dependencies"
    echo "2. Uninstall News Clipping Bot and dependencies"
    echo "3. Exit"
    echo
    echo -n "Select an option ? "
    read op
    case $op in
        1) Install ;;
        2) Uninstall ;;
        3) exit ;;
        *) "Sorry, invalid option." ; echo ; Menu ;;
      esac
}
 

Install() {
    clear
    echo "Before installing do:"
    echo "    1) Put your telegram token and telegram bot name, respectively one on each line of the 'token.txt' file, located at './core/settings'"
    echo "    2) To use your own sources, go to './core/settings' directory and add the twitter usernames that are your news sources."
    read -n 1 -r -s -p $'Click any key to continue...\n'
    echo "Installing dependencies, average time 2 min..."
    apt-get update 2> /dev/null > /dev/null && apt-get install python3 python3-venv -y 2> /dev/null > /dev/null
    cp -r core/ /opt 
    mv /opt/core/ /opt/news-clipping-bot/
    chmod +x /opt/news-clipping-bot/newsClippingBot.py
    chmod +x /opt/news-clipping-bot/collector.py
    python3 -m venv /opt/news-clipping-bot/settings/venv
    /opt/news-clipping-bot/settings/venv/bin/python /opt/news-clipping-bot/settings/venv/bin/pip3 install -r requirements.txt
    sudo /bin/bash -c 'echo "59 */6 * * * $(whoami) /opt/news-clipping-bot/settings/venv/bin/python /opt/news-clipping-bot/collector.py >/dev/null 2>&1" >> /etc/crontab'
    crontab /etc/crontab
    tee -a /etc/systemd/system/clippingbot.service <<EOF
[Unit]
Description=News Clipping Bot
After=multi-user.target
[Service]
Type=simple
Restart=always
ExecStart=/opt/news-clipping-bot/settings/venv/bin/python /opt/news-clipping-bot/newsClippingBot.py
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable clippingbot.service
    systemctl start clippingbot.service
    #timedatectl set-timezone Europe/Lisbon
    echo "Don't forget to keep the timezone right. by default is selected: Europe/Lisbon."
    sleep 1
    echo "Bot installation completed."
    sleep 1
    echo "Running first harvest..."
    /opt/news-clipping-bot/settings/venv/bin/python /opt/news-clipping-bot/collector.py
    exit
}
 

Uninstall() {
    clear
    if ! [ -d "/opt/news-clipping-bot/" ]; then
        echo "The News Clipping Bot is not installed...."
        exit
    fi
    systemctl stop clippingbot.service
    systemctl disable clippingbot.service
    rm /etc/systemd/system/clippingbot.service 2> /dev/null > /dev/null
    rm /etc/systemd/system/clippingbot.service 2> /dev/null > /dev/null
    rm /usr/lib/systemd/system/clippingbot.service 2> /dev/null > /dev/null
    rm /usr/lib/systemd/system/clippingbot.service 2> /dev/null > /dev/null
    systemctl daemon-reload
    systemctl reset-failed 2> /dev/null > /dev/null
    sleep 1
    rm -rf /opt/news-clipping-bot/
    crontab -u root -l | grep -v '/opt/news-clipping-bot/collector.py' | crontab -u root -
    cat /etc/crontab | grep -v "/opt/news-clipping-bot/collector.py" > tmpfile && mv tmpfile /etc/crontab 2> /dev/null > /dev/null
    echo "Uninstall completed."
    exit
}

Menu
