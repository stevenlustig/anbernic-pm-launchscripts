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
 
SHDIR=$(dirname "$0")

source $controlfolder/control.txt
source $controlfolder/tasksetter

get_controls

GAMEDIR="$SHDIR/blossomtales2"
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
$ESUDO rm -rf $HOME/.local/share/Blossom\ Tales\ 2
$ESUDO rm -rf $HOME/.config/Blossom\ Tales\ 2

# Setup savedir linux
$ESUDO rm -rf ~/.local/share/Blossom\ Tales\ 2
mkdir -p ~/.local/share
mkdir -p "$GAMEDIR/savedata/linux"
ln -sfv "$GAMEDIR/savedata/linux" ~/.local/share/Blossom\ Tales\ 2


# Setup savedir windows
$ESUDO rm -rf ~/.config/Blossom\ Tales\ 2
mkdir -p ~/.config
mkdir -p "$GAMEDIR/savedata/windows"
ln -sfv "$GAMEDIR/savedata/windows" ~/.config/Blossom\ Tales\ 2



# Remove all the dependencies in favour of system libs - e.g. the included 
# Custom version of FNA included with patcher- v23, but with VorbisFile-CS added back (from v16)
# see https://github.com/JohnnyonFlame/FNAHacks/tree/Shipwreck
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs":"/usr/lib":"/usr/lib32":"$monodir/lib":$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"

export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
#export FNA3D_OPENGL_FORCE_VBO_DISCARD=1

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "mono" &

DSIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.5 AUDIODEV=hw:2,0 $TASKSET mono BlossomTales2.exe 2>&1 | tee $GAMEDIR/log.txt
else
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.5 $TASKSET mono BlossomTales2.exe 2>&1 | tee $GAMEDIR/log.txt
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"
unset LD_LIBRARY_PATH

# Disable console
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0

