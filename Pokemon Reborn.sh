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

# Source the controls and device info
source $controlfolder/control.txt

# Source custom mod files from the portmaster folder
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
# Pull the controller configs for native controls
get_controls

# Directory setup
PORTDIR=$(dirname "$0")
GAMEDIR="$PORTDIR/reborn"

mkdir -p "$GAMEDIR/conf"

# Enable logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:/usr/lib:/usr/lib32:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTINTERACTIVE="Y"
export XDG_DATA_HOME="$CONFDIR"
export LC_ALL=C
export LANG=C
cd $GAMEDIR

# Move the mkxp.json preset
mv preset/mkxp.json ./mkxp.json

# Gptk and run port
$GPTOKEYB "mkxp-z.${DEVICE_ARCH}" -c "./reborn.gptk" &
pm_platform_helper $GAMEDIR/mkxp-z.${DEVICE_ARCH}
./mkxp-z.${DEVICE_ARCH}

# Cleanup
pm_finish