#!/bin/bash
vlc/kill_vlc.sh
kill $(cat capture.pid)
kill $(cat select.pid)
kill $(cat duplicate_watch.pid)

rm vlc/vlc.pid
rm windowid/vlcwindow.id

