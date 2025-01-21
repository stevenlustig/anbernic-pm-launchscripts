#!/bin/bash

#you will need to install dos2unix and unzip, you can do it by opening a terminal and using "sudo apt install unzip dos2unix" commands or adding those to LIBS folder

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
export PORT_32BIT="N"
get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="$SHDIR/gravitycircuit"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0


$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# extract, diff
GAMEFILE="./gamedata/GravityCircuit.exe"
if [ -f "$GAMEFILE" ]; then
  # Replace with splashscreen?
  echo "Unpacking and patching game, this takes a while on the first start..." > /dev/tty0
  # unpack the game
  unzip -o "$GAMEFILE" -d ./gamedata 
  rm "$GAMEFILE"
  rm -Rf ./gamedata/platform
  cd ./gamedata
  # ungh, mixed line ends, there's probably a better way
  grep -E '^\+\+\+ ' "../gravitycircuit.diff" | sed -E 's/^\+\+\+ ([^\/]+\/)?//' | cut -f1 | xargs -I {} dos2unix "{}"
  # patch the unpacked game
  $GAMEDIR/bin/patch -p1 < "$GAMEDIR/gravitycircuit.diff"
fi

export XDG_DATA_HOME="$GAMEDIR/conf" # allowing saving to the same path as the game
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:/usr/lib":$LD_LIBRARY_PATH
mkdir -p "$XDG_DATA_HOME"

echo "Loading game.." > /dev/tty0

cd $GAMEDIR
$GPTOKEYB "love" -c gravitycircuit.gptk &
./bin/love ./gamedata

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0
