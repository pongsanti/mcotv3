#!/bin/bash
#cvlc --file-logging --logfile=vlc.txt -f --meta-title mcot http://localhost:9981/stream/channelid/726202268?ticket=622972F40EB2C347636E5EE984D40B3F894094F7&profile=pass &
obs Untitled &
echo $! > vlc/vlc.pid

