#!/bin/bash
# You need LOVE libs and LOVE binary. Take it from To The Moon ones.

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

# Pm:
source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

# Variables
GAMEDIR="$SHDIR/fridaynightfunkin"
CONFDIR="$GAMEDIR/conf/"

echo "--directory=$directory---,HOTKEY=$HOTKEY--"

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Set the XDG environment variables for config & savefiles
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Source love2d runtime
source $controlfolder/runtimes/"love_11.5"/love.txt
export LD_LIBRARY_PATH="$GAMEDIR/libs":"/usr/lib":"/usr/lib32":$LD_LIBRARY_PATH

# Use the love runtime
chmod +x ./love

$GPTOKEYB "$LOVE_GPTK" -c "./fridaynightfunkin.gptk" &
#pm_platform_helper  "$GAMEDIR/love"
./love "$GAMEDIR/gamedata"

# Cleanup any running gptokeyb instances, and any platform specific stuff.
#pm_finish

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0