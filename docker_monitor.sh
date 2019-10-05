#!/bin/bash

# Telegram alarm for dead Docker container

# Geschrieben von
# Matthias Pröll <matthias.proell@staudigl-druck.de>
# Staudigl-Druck GmbH & Co. KG
# Letzte Anpassung: 2019/08/23


#Variables
USER1=CHAT ID
USER2=CHAT IT

telegram_id=("$USER1 $USER2")
hostname="$(cat /etc/hostname)"
check_time="120" #seconds between checks
bottoken="BOTTOKEN"


#MAIN
while true; do
    deadcontainer="$(docker service ls --format {{.Name}}:{{.Replicas}} | grep '0/1' | cut -d' ' -f1)"
    if [ "$deadcontainer" == "" ]; then
        echo "All container are running!"
        sleep "$check_time"
    else
        echo "At least one container is dead!"
        telegram_msg=""
        for i in $deadcontainer; do
            echo $i
            telegram_msg="$telegram_msg %0A $(echo $i | cut -d':' -f1)"
            echo ACHTUNG "$telegram_msg"
        done
        for f in "${telegram_id[@]}"; do
            curl -s -X POST "https://api.telegram.org/bot$bottoken/sendMessage" \
                -d chat_id=$f --data-binary "text=At least one container is dead on $hostname: %0A $telegram_msg"
            echo "Telegram was sent to $f!"
        done
        sleep "$check_time"
    fi
done
exit 0
