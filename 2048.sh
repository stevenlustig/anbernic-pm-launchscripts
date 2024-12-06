#!/bin/bash

export HOME=/root

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi
 
SHDIR=$(dirname "$0")
GAMEDIR="$SHDIR/2048"

source $controlfolder/control.txt
source $controlfolder/device_info.txt

get_controls

$ESUDO chmod 666 /dev/tty0
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

RA_CFG=/.config/retroarch/retroarch.cfg
RA_CORE=/mnt/vendor/deep/retro/cores
RA_WORK=/mnt/vendor/deep/retro

cd "$GAMEDIR"

$GPTOKEYB "retroarch" &
$RA_WORK/retroarch $RA_CFG -L 2048_libretro.so.aarch64


printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0