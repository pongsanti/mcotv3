#!/bin/bash
vlc/run_vlc.sh
windowid/findwinid.sh
ruby capture.rb &
echo $! > capture.pid
ruby select.rb &
echo $! > select.pid
