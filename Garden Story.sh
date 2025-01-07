#!/bin/bash

export HOME=/root

#manually create the game.apk by modifying the portmaster one and add lib/armeabi-v7a libs (libyoyo, libopenal and libc++_shared.so)

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

source $controlfolder/control.txt
source $controlfolder/device_info.txt


[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
PORTDIR=$(dirname "$0")
GAMEDIR="$PORTDIR/gardenstory"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Exports
export LD_LIBRARY_PATH="/usr/lib":"/usr/lib32":"$GAMEDIR/lib":"$GAMEDIR/utils/libs":"$GAMEDIR/lib/armeabi-v7a":$LD_LIBRARY_PATH
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

$ESUDO chmod +x gmloader

# Run the game
$GPTOKEYB "gmloader" &

#pm_platform_helper "$GAMEDIR/gmloadernext"
#./gmloadernext

./gmloader game.apk

# Kill processes
#pm_finish

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1