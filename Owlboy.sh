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
source $controlfolder/tasksetter

get_controls

SHDIR=$(dirname "$0")

#GAMEDIR="/$directory/ports/owlboy"
GAMEDIR="$SHDIR/owlboy"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

cd "$GAMEDIR/gamedata"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir and configdir
$ESUDO mkdir -p $HOME/.local/share
$ESUDO mkdir -p $HOME/.config
$ESUDO rm -rf $HOME/.local/share/Owlboy
$ESUDO rm -rf $HOME/.config/Owlboy


whichos=$(grep "title=" "/usr/share/plymouth/themes/text.plymouth")
if [[ $whichos == *"RetroOZ"* ]]; then
  # Fix a problem with savedata
  mkdir -p $HOME/.local/share/Owlboy
  cp -r "$GAMEDIR/savedata/Saves/" $HOME/.local/share/Owlboy
else
  ln -sfv "$GAMEDIR/savedata" $HOME/.local/share/Owlboy
fi
ln -sfv "$GAMEDIR/savedata" $HOME/.config/Owlboy

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono*.dll

# Setup path and other environment variables
# export FNA_PATCH="$GAMEDIR/dlls/OwlboyPatches.dll"
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs":"$monodir/lib":$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "mono" &

DSIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.5 AUDIODEV=hw:2,0 $TASKSET mono Owlboy.exe 2>&1 | tee $GAMEDIR/log.txt
else
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.5 $TASKSET mono Owlboy.exe 2>&1 | tee $GAMEDIR/log.txt
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"
unset LD_LIBRARY_PATH

if [[ $whichos == *"RetroOZ"* ]]; then
  # Fix a problem with savedata
  $ESUDO rm -rf "$GAMEDIR/savedata/Saves-old/"
  $ESUDO mv "$GAMEDIR/savedata/Saves/" "$GAMEDIR/savedata/Saves-old/"
  cp -r $HOME/.local/share/Owlboy/Saves/ "$GAMEDIR/savedata/"
fi

# Disable console
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0
