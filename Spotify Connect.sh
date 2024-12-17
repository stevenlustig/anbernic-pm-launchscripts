#!/bin/bash

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

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

SHDIR=$(dirname "$0")

# Source the controls and device info
source $controlfolder/control.txt

# Source custom mod files from the portmaster folder
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
# Pull the controller configs for native controls
get_controls

# Directory setup
GAMEDIR=$SHDIR/librespot
CONFDIR="$GAMEDIR/conf/"
mkdir -p "$GAMEDIR/conf"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Set the XDG environment variables for config & savefiles for LOVE
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:/usr/lib":$LD_LIBRARY_PATH
export LOVEDIR=$GAMEDIR
export UIDIR=$GAMEDIR/librespotui

# Check if the cache directory size is greater than 50 MB
CACHE_DIR="$LOVEDIR/cache"
if [ -d "$CACHE_DIR" ]; then
  CACHE_SIZE_MB=$(du -sm "$CACHE_DIR" | cut -f1)
  if [ "$CACHE_SIZE_MB" -gt 50 ]; then
    rm -rf "$CACHE_DIR"
  fi
fi

# Enable logging
#> "$GAMEDIR/log.txt" && exec > >(tee "$LOVEDIR/log.txt") 2>&1

cd $GAMEDIR

# Run LOVE and Spotify
chmod +x ./love
$GPTOKEYB "love" &
./love librespotui

# Cleanup LOVE
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
