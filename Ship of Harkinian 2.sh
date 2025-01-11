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

# Source Device Info
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

# Set variables
GAMEDIR="$SHDIR/soh2"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

CUR_TTY=/dev/tty0
# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# Exports
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:/usr/lib":$LD_LIBRARY_PATH
export SDL_GAMECONTROLLERCONFIG=$sdl_controllerconfig
export PATCHER_FILE="$GAMEDIR/assets/extractor/otrgen"
export PATCHER_GAME="$(basename "${0%.*}")" # This gets the current script filename without the extension
export PATCHER_TIME="5 to 10 minutes"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Check if we need to generate any o2r files
if [ ! -f "mm.o2r" ]; then
    # Ensure we have a rom file before attempting to generate o2r
    if ls *.*64 1> /dev/null 2>&1; then
        if [ -f "$controlfolder/utils/patcher.txt" ]; then
            source "$controlfolder/utils/patcher.txt"
            $ESUDO kill -9 $(pidof gptokeyb)
        else
            echo "This port requires the latest version of PortMaster." > $CUR_TTY
        fi
    else
        echo "Missing ROM files! Can't generate o2r!"
    fi
fi

# Check if OTR files were generated
if [ ! -f "mm.o2r" ]; then
    echo "No o2r found, can't run the game!"
    exit 1
fi

# Run the game
echo "Loading, please wait... (might take a while!)" > $CUR_TTY
$GPTOKEYB "2s2h.elf" -c "soh2.gptk" & 
./2s2h.elf

# Cleanup
rm -rf "$GAMEDIR/logs/"
$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
