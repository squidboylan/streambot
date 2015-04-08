#! /bin/bash

key=`cat key`
server=`cat server`

function send {
    echo "-> $1"
    echo "$1" >> .botfile
}

rm .botfile
mkfifo .botfile
tail -f .botfile | openssl s_client -connect $server:6697 | while true; do
    if [[ -z $started ]] ; then
        send "USER streambot streambot streambot :streambot"
        send "NICK streambot"
        send "JOIN #squidtest"
        #send "JOIN #starcraft"
        #send "JOIN #robots $key"
        started="yes"
    fi
    read irc
    echo "<- $irc"
    if `echo $irc | cut -d ' ' -f 1 | grep PING > /dev/null`; then
        send "PONG"
    fi
    if `echo $irc | grep PRIVMSG > /dev/null`; then
        chan=`echo $irc | cut -d ' ' -f3`
        message=`echo $irc | cut -d ' ' -f4- | tr -d '\r'`

        if `echo $message | egrep "^:!stream " > /dev/null` ; then
            streamer=`echo $message | cut -d ' ' -f2`
            `curl https://api.twitch.tv/kraken/streams/$streamer > temp`
            if ! `cat temp | jq '.stream' | egrep '^null$' > /dev/null`; then
                title=`cat temp | jq '.stream.channel.status'`
                send "PRIVMSG $chan :www.twitch.tv/$streamer is live with $title!"
            else
                send "PRIVMSG $chan :$streamer is not live"
            fi

        elif `echo $message | tr -d '\r' | egrep '^:streambot: help$' > /dev/null`; then
            send "PRIVMSG $chan :I am a bot that helps you figure out if your favorite streamers are online \"!stream \$stream\" to figure out if \$stream is online"

        elif `echo $message | egrep '^:streambot: source$' > /dev/null`; then
            send "PRIVMSG $chan :My source is available at https://github.com/squidboylan/streambot"

        fi
    fi
done
