# SSH-Login-Brute-Force-Alert
This repository contains a Bash script that monitors SSH login attempts and brute force attacks, sending real-time notifications to a Telegram bot.

# Scupdicd0es Present
## SSH & Fail2Ban Notification Bot to Telegram

This repository contains a Bash script that monitors SSH login attempts and brute force attacks, sending real-time notifications to a Telegram bot. It integrates with *Fail2Ban* to detect brute force attempts and uses the ipinfo.io API to provide detailed information about the attacker's IP, including location and organization

## Features
- SSH Login Notifications: Sends an alert when a successful SSH login is detected, including the IP, user, location, and organization.
- Brute Force Detection: Detects brute force attacks through Fail2Ban and sends detailed alerts to Telegram.
- IP Information Lookup: Uses the ipinfo.io API to retrieve geographic and organizational details about the IP involved in the login or attack.
- Telegram Bot Integration: Sends formatted messages to a specified Telegram group or channel.

## Installation
1. Prerequisites
Before running the script, make sure you have the following installed on your server:
```sh
sudo apt update
sudo apt install fail2ban jq curl
```
2. Telegram Bot
- Create [Telegram Bot](https://t.me/BotFather)
- Use getUpdates to get chatid
```sh
https://api.telegram.org/bot7xxxxxxxxYOURAPIKEY/getUpdates
```

3. IPinfo
Create account [ipinfo](https://ipinfo.io)

4. Install
```sh
git clone https://github.com/GlgApr/SSH-Login-Brute-Force-Alert.git
cd SSH-Login-Brute-Force-Alert
```

5. Edit Script
```
sudo nano ssh-telegram-alert.sh
```

Edit this:
```
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
IPINFO_TOKEN="YOUR_IPINFO_TOKEN"
```

Execute:
```
chmod +x ssh-telegram-alert.sh
```

```
sudo nano /etc/fail2ban/action.d/telegram.conf
```
Fill with:
```
[Definition]
actionstart = /usr/local/bin/ssh-telegram-alert.sh bruteforce <ip>
actionban = /usr/local/bin/ssh-telegram-alert.sh bruteforce <ip>
actionunban = /usr/local/bin/ssh-telegram-alert.sh bruteforce <ip>
```

Create service file:
```
sudo nano /etc/systemd/system/ssh-login-monitor.service
```
Fill with:
```
[Unit]
Description=SSH Login and Brute Force Monitor

[Service]
ExecStart=/usr/local/bin/ssh-telegram-alert.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

Save, and running:
```
sudo systemctl daemon-reload
sudo systemctl enable ssh-login-monitor.service
sudo systemctl start ssh-login-monitor.service
```
```
sudo mv ssh-notify.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/ssh-telegram-alert.sh
```
Last
```
sudo systemctl status ssh-login-monitor.service
```






