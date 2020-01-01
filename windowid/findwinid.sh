#!/bin/bash
is_vlc_window_ready() {
  xwininfo -name "OBS 0.0.1 (linux) - Profile: Untitled - Scenes: Untitled" | grep "Window id: 0x"
 # xwininfo -name "VLC media player" | grep "Window id: 0x"
  return $?
}

is_vlc_window_ready
while [ $? -ne 0 ]
do
  echo "Waiting OBS init..."
  sleep 2
  is_vlc_window_ready
done
echo "OBS initialized."

#xwininfo -name "VLC media player" | grep "Window id: 0x" | sed 's/ /\n/g' | grep 0x > windowid/vlcwindow.id
xwininfo -name "OBS 0.0.1 (linux) - Profile: Untitled - Scenes: Untitled" | grep "Window id: 0x" | sed 's/ /\n/g' | grep 0x > windowid/vlcwindow.id
echo "WIN ID = $(cat windowid/vlcwindow.id)"
