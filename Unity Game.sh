#!/bin/bash

export HOME=/root

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

source $controlfolder/control.txt
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR="$SHDIR/unitygame"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

export BOX86="$GAMEDIR/box86/box86"
export UNITY_GAME_FOLDER="$GAMEDIR/gamedata"
export LD_LIBRARY_PATH="$GAMEDIR/box86/lib:/usr/lib32:$GAMEDIR/libs:/usr/libs:$UNITY_GAME_FOLDER/MyGame_Data:$GAMEDIR/libs/glibc-2.3.5":/usr/lib/aarch64-linux-gnu:$UNITY_GAME_FOLDER:$LD_LIBRARY_PATH
export UNITY_GAME_EXEC="$UNITY_GAME_FOLDER/UnityGame.x86"
export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/
export BOX86_DYNAREC=1
export LIBGL_NOBANNER=1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=3
export BOX86_LOG=0
export BOX86_LD_PRELOAD=$GAMEDIR/libGame.so
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1



$ESUDO chmod +x "$UNITY_GAME_FOLDER/*"

DSIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  AUDIODEV=hw:2,0 $ESUDO $BOX86 $UNITY_GAME_EXEC 2>&1 | tee $GAMEDIR/log.txt
else
  $ESUDO $BOX86 $UNITY_GAME_EXEC 2>&1 | tee $GAMEDIR/log.txt
fi

#$ESUDO kill -9 $(pidof gptokeyb)

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
#$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0