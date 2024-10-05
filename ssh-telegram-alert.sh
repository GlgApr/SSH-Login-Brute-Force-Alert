#!/bin/bash

# Token bot Telegram dan ID chat
BOT_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
CHAT_ID="xxxxxxxxx"

# ipinfo.io token
IPINFO_TOKEN="xxxxxxxxxxx"

# Fungsi untuk mengirim notifikasi ke Telegram
send_telegram_message() {
    local message=$(echo -e "$1" | sed 's/\n/%0A/g')  # Ganti \n dengan %0A
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id=$CHAT_ID \
    -d text="$message"
}

# Fungsi untuk mendapatkan informasi IP dari ipinfo
get_ip_info() {
    local ip=$1
    curl -s "https://ipinfo.io/$ip?token=$IPINFO_TOKEN"
}

# Fungsi untuk menangani notifikasi brute force dari Fail2Ban
notify_brute_force() {
    IP="$1"
    IP_INFO=$(get_ip_info "$IP")
    LOCATION=$(echo "$IP_INFO" | jq -r '.city, .region, .country' | paste -s -d ', ')
    ORG=$(echo "$IP_INFO" | jq -r '.org')

    # Fungsi untuk mengirim notif ke Bot Telegram
    MESSAGE="Peringatan: Upaya brute force terdeteksi dari IP $IP!%0A"\
"Lokasi: $LOCATION%0A"\
"Organisasi: $ORG"
    
    send_telegram_message "$MESSAGE"
}

# Fungsi untuk memantau login SSH yang berhasil
monitor_successful_ssh_logins() {
    LOG_FILE="/var/log/auth.log"

    # Pantau log untuk login SSH yang berhasil
    tail -fn0 "$LOG_FILE" | while read -r line; do
        if echo "$line" | grep "Accepted password" ; then
            IP=$(echo "$line" | grep -oP '(?<=from )[^ ]+')
            USER=$(echo "$line" | grep -oP '(?<=for )[^ ]+')
            
            # Dapatkan informasi IP dari ipinfo
            IP_INFO=$(get_ip_info "$IP")
            LOCATION=$(echo "$IP_INFO" | jq -r '.city, .region, .country' | paste -s -d ', ')
            ORG=$(echo "$IP_INFO" | jq -r '.org')

            # Fungsi untuk mengirim notif ke Bot Telegram
            MESSAGE="Peringatan: Login SSH berhasil dari IP $IP dengan user $USER!%0A"\
"Lokasi: $LOCATION%0A"\
"Organisasi: $ORG"
            
            send_telegram_message "$MESSAGE"
        fi
    done
}

# Periksa apakah dipanggil oleh Fail2Ban atau memantau login
if [ "$1" == "bruteforce" ]; then
    IP="$2"
    notify_brute_force "$IP"
else
    monitor_successful_ssh_logins
fi
