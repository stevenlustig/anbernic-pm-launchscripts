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
source $controlfolder/device_info.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty0

GAMEDIR="$SHDIR/JediAcademy"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
printf "\033c" > /dev/tty0

sed -i "s/seta r_customheight \".*\"/seta r_customheight \"$DISPLAY_HEIGHT\"/" "$GAMEDIR/conf/openjk/base/openjk_sp.cfg"
sed -i "s/seta r_customwidth \".*\"/seta r_customwidth \"$DISPLAY_WIDTH\"/" "$GAMEDIR/conf/openjk/base/openjk_sp.cfg"

cd $GAMEDIR
$ESUDO mkdir -p $HOME/.local/share
$ESUDO rm -rf $HOME/.local/share/openjk
ln -sfv $GAMEDIR/conf/openjk/ $HOME/.local/share/

export DEVICE_ARCH="aarch64"
export LIBGL_FB=4 
export LIBGL_ES=2 
export LIBGL_GL=21

if [ "$LIBGL_FB" != "" ]; then
export SDL_VIDEO_GL_DRIVER="$GAMEDIR/gl4es.aarch64/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$GAMEDIR/gl4es.aarch64/libEGL.so.1"
fi 

export LD_LIBRARY_PATH="/usr/lib32":"$GAMEDIR/libs":"/usr/lib":$LD_LIBRARY_PATH
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

#chmod +x ./openjk_sp.aarch64

$GPTOKEYB "openjk_sp.aarch64" -c "openjk_sp.aarch64.gptk" &
LIBGL_DEBUG=verbose ./openjk_sp.aarch64

$ESUDO kill -9 $(pidof gptokeyb)
unset DISPLAY

$ESUDO systemctl restart oga_events & 
printf "\033c" >> /dev/tty1
