#!/bin/sh

HOSTNAME=$(cat /etc/hostname)

previous_block_height_rec="previous_block_height.info"
count_errors_rec="count_errors.info"

count_errors=0

STATUS_CHAIN=$({{ home_folder }}/go/bin/commercionetworkd status 2>&1)
if [ $? -gt 0 ]; then
   latest_block_height=
else
   latest_block_height=$(echo $STATUS_CHAIN | jq -r '.SyncInfo["latest_block_height"]')
fi

if [ -f $count_errors_rec ]; then
    count_errors=$(cat $count_errors_rec)
fi

if [ -z $latest_block_height ]; then
    if [ $count_errors -gt 3 ]; then
    echo "[ERROR] Warning, something is not working on the node: the service seems to be turned off"
    curl -s -S -X POST -H 'Content-type: application/json' --data '{"text":"*'$HOSTNAME'* Warning, something is not working on the node: the service seems to be turned off!"}' "{{ slack_hook }}"
    else
        count_errors=$(($count_errors+1))
        printf $count_errors > $count_errors_rec
    fi
    exit
else
    printf 0 > $count_errors_rec
fi

if [ -f $previous_block_height_rec ]; then
    previous_block_height=$(cat $previous_block_height_rec)
else
    printf $latest_block_height >$previous_block_height_rec
    echo "[OK] Everything is Ok for the moment"
    exit
fi

if [ ! $latest_block_height -gt $previous_block_height ]; then
    echo "[ERROR] Warning, something is not working on the node: $latest_block_height vs $previous_block_height"
    printf $latest_block_height >$previous_block_height_rec
    curl -s -S -X POST -H 'Content-type: application/json' --data '{"text":"*'$HOSTNAME'* Warning, something is not working on the node: '$latest_block_height' vs '$previous_block_height'!"}' "{{ slack_hook }}"
    exit
fi
    printf $latest_block_height >$previous_block_height_rec

echo "[OK] Everything seems to be working well for the moment $latest_block_height vs $previous_block_height"