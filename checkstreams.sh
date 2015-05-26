#! /bin/bash

while true;
do
    for streamer in `cat list`; do
        if `curl https://api.twitch.tv/kraken/streams/$streamer > .temp2`; then
            if ! `cat .temp2 | jq '.stream.channel.status' | egrep "^null$" > /dev/null` ;then
                if !  `cat streamers/$streamer | grep live > /dev/null`; then
                    if `cat temp2 | jq '.stream.channel.game' | grep -i 'starcraft' > /dev/null`; then
                        title=`cat .temp2 | jq '.stream.channel.status'`
                        `echo "PRIVMSG #starcraft :www.twitch.tv/$streamer is live with $title!" >> .botfile`
                        `echo "live" > streamers/$streamer`
                    fi
                fi
            else
                `echo "dead" > streamers/$streamer`
            fi
        fi
    done

    sleep 300
done
