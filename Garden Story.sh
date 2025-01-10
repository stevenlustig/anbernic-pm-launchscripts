#!/bin/bash

#to get it working you will need to manually add to the game.apk the libs arm64-v8a: libm.so, liboboe.so, libcompiler_rt.so.
#change the extension from apk to zip, add them and return them back. 
#in addition, manually add /assets/ folder to the apk as sometimes the console gets out of memory when creating the game.apk
#with the dat files inside. You can delete /assets/ folder from the gardenstory afterwards.

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
 
SHDIR=$(dirname "$0")

source $controlfolder/control.txt
source $controlfolder/tasksetter
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="$SHDIR/gardenstory"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

# Exports
export LD_LIBRARY_PATH="/usr/lib":"/usr/lib32":"$GAMEDIR/lib":"$GAMEDIR/utils":$LD_LIBRARY_PATH

# Check if "data.win" exists and its MD5 checksum matches the specified value then apply patch
if [ -f "gamedata/data.win" ]; then
    checksum=$(md5sum "gamedata/data.win" | awk '{print $1}')
    if [ "$checksum" = "ad61dfb29cda512397bf34a4aa70db8a" ]; then
        $ESUDO $GAMEDIR/utils/xdelta3 -d -s "gamedata/data.win" -f "./patch/patch.xdelta" "gamedata/game.droid" && \
        rm "gamedata/data.win"
    fi
fi

# Check if there are .dat files in ./gamedata
if [ -n "$(ls ./gamedata/*.dat 2>/dev/null)" ]; then
    # Move all .dat files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.dat ./assets/ || exit 1

    # Zip the contents of ./game.apk including the .dat files
    zip -r -0 ./game.apk ./assets/ || exit 1
    rm -Rf "$GAMEDIR/assets/" || exit 1
fi

chmod +x ./gmloadernext

# Run the game
$GPTOKEYB "gmloadernext" &
pm_platform_helper "$GAMEDIR/gmloadernext"
./gmloadernext

# Kill processes
pm_finish

# Disable console
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0
