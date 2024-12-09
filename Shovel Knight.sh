#!/bin/bash

export HOME=/root

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

SHDIR=$(dirname "$0")

source $controlfolder/control.txt

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

#GAMEDIR="/$directory/ports/shovelknight"
GAMEDIR="$SHDIR/shovelknight"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

cd $GAMEDIR/gamedata/shovelknight/32

export LIBGL_NOBANNER=1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=3
export BOX86_LOG=0
export BOX86_LD_PRELOAD=$GAMEDIR/libShovelKnight.so
export LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib:/usr/lib32
export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/
export BOX86_DYNAREC=1
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO mkdir -p $HOME/.local/share
$ESUDO rm -rf $HOME/.local/share/Yacht\ Club\ Games
$ESUDO ln -s $GAMEDIR/Yacht\ Club\ Games $HOME/.local/share/
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "box86" -c "$GAMEDIR/shovelknight.gptk" &
echo "Loading, please wait... (might take a while!)" > /dev/tty0

DSIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  AUDIODEV=hw:2,0 $GAMEDIR/box86/box86 ShovelKnight 2>&1 | tee $GAMEDIR/log.txt
else
  $GAMEDIR/box86/box86 ShovelKnight 2>&1 | tee $GAMEDIR/log.txt
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset SDL_GAMECONTROLLERCONFIG
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0