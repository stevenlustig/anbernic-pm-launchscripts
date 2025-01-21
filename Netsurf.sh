#!/bin/bash

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

SHDIR=$(dirname "$0")

source $controlfolder/control.txt
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR="$SHDIR/netsurf"
CONFDIR="$GAMEDIR/conf/"
BINARY=nsfb

echo "--directory=$directory---,HOTKEY=$HOTKEY--"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0


cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

mkdir -p "$GAMEDIR/conf"

export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export NETSURFRES="$GAMEDIR/resources"
export NETSURF_DIR="$GAMEDIR/"
export XDG_DATA_HOME="$CONFDIR"

$GPTOKEYB "$BINARY" -c "./netsurf.gptk" &
echo $DISPLAY_WIDTH
./$BINARY -fsdl -w"$DISPLAY_WIDTH" -h"$DISPLAY_HEIGHT" https://google.com

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &

printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0