#!/bin/bash
#create the apk with the ogg in assets and change the data.win as game.droid in gamedata. 

export HOME=/root

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
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Declare variables
PORTDIR=$(dirname "$0")
GAMEDIR="$PORTDIR/savant"

# Exports
export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/$GAMEDIR/libs:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

# Change dir & add config
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

printf "\033c" > /dev/tty0

# Setup controls
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "gmloader" & 
echo "Loading, please wait... " > /dev/tty0

# Run the game
./gmloader savant.apk

# Kill proccesses & restart services
$ESUDO kill -9 "$(pidof gptokeyb)"
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0