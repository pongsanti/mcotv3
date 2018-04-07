#!/bin/bash
vlc/kill_vlc.sh
kill $(cat capture.pid)
kill $(cat select.pid)

rm vlc/vlc.pid
rm windowid/vlcwindow.id
