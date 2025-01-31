#!/bin/bash

#you can get Game Cube and Wii games working on your Stock OS but you need some workarounds for now.  
# Get the MuOS' final V8 dolphin core (Dolphin for MuOS V8-hasjoys in the case of 40XX-V and H). 
# place the folder "dolphin" located in that zip under mnt\mmc\MUOS\emulator to PORTS so you have
# PORTS/dolphin. In "Config" you need to modify GCPadNew.ini (removing the this text...) to use
# Device = ANBERNIC-keys instead of Deeplay. Same with WiimoteNew.ini. 
# In Dolphin.ini change all the MUOS references (e.g: /mnt/sdcard/Roms/PORTS/dolphin/Saves/)
# to PORTS/dolphin/ (e.g: /mnt/sdcard/Roms/PORTS/dolphin/Saves/Gamecube/MemcardA/).
# Create a folder called "Games" and place the game you want to play with the name "game.iso" (or change the name below in ROM=)
# launch it through port master ;)

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

GAMEDIR="$SHDIR/dolphin"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/lib:/usr/lib:$LD_LIBRARY_PATH"

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

NAME="ext-dolphin"
CORE="$GAMEDIR/dolphin"

export EMUDIR="$GAMEDIR"
export ROM="$GAMEDIR/Games/game.iso"

$ESUDO $GPTOKEYB -k "$EMUDIR/dolphin" -c "./dolphin.gptk" & ./dolphin -e "$ROM" -u "$EMUDIR"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
