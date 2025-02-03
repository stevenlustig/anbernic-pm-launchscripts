#!/bin/bash

# Download YtMuos from https://github.com/nvcuong1312/YtMuos/archive/refs/heads/master.zip and place it in PORTS/CTube
# Get libmodplug.so.1 from internet or To The Moon libs and place it in PORTS/CTupe/bin/libs.aarch64
# Profit ;)

export HOME=/root
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports" ]; then
  controlfolder="/roms/ports/PortMaster"
elif [ -d "/roms2/ports" ]; then
  controlfolder="/roms2/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

SHDIR="$(dirname "$0")"

source "$controlfolder/control.txt"
source "$controlfolder/device_info.txt"

get_controls

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="$SHDIR/CTupe"
BINDIR="$GAMEDIR/bin"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$BINDIR/libs.aarch64:/usr/lib:$LD_LIBRARY_PATH"

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

YT_DLP=/usr/bin/yt-dlp

if [ ! -f "$YT_DLP" ]; then
	cp "$BINDIR/yt-dlp" "$YT_DLP"
fi 

chmod a+rx $YT_DLP
ln -fs "$YT_DLP" /usr/bin/youtube-dl

$GPTOKEYB "love" &
./bin/love "$GAMEDIR"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
