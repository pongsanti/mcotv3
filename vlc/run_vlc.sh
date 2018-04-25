#!/bin/bash
cvlc --file-logging --logfile=vlc.txt -f --meta-title mcot http://localhost:9981/play/stream/service/d41a6687b297b1427ea81eaf2754d9ea?title=MCOT%20HD%20%2F%20MCOT &
echo $! > vlc/vlc.pid
