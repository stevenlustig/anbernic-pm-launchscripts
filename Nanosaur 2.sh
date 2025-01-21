#!/bin/bash

#in order to get the game working you will need to patch SDL2 missing functions with a custom .so
# that you can compile through the .c code you can grab here: https://pastebin.com/EDtDiDc1
# using GCC as compiler: gcc -shared -fPIC -o libSDL2_bridge.so sdl_symbol_bridge.c
# In addition, you might need the libgl_default.txt that exposes some variables in MuOS and Knulli.
# create a txt and place it where the sh are in PORTS so you can freely use it anytime you want
# from here: https://pastebin.com/GrktyAFd

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

get_controls

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="$SHDIR/nanosaur2"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0


cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export DEVICE_ARCH="${DEVICE_ARCH:-aarch64}"

if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
  source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
  source "$SHDIR/libgl_default.txt"
fi

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi 

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/Libs:$LD_LIBRARY_PATH"

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "Nanosaur2" &
LD_PRELOAD=$GAMEDIR/Libs/libSDL2_bridge.so ./Nanosaur2

unset LD_LIBRARY_PATH
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &

printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0