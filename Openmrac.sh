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

get_controls

GAMEDIR="$SHDIR/openmrac"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

CONFDIR="$GAMEDIR/conf/"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

cd $GAMEDIR

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:/usr/lib":$LD_LIBRARY_PATH

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "openmrac-es2" -c "./openmrac.gptk" &
./openmrac-es2 ./openmrac.dat --skip-settings 2>&1 | tee -a ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
