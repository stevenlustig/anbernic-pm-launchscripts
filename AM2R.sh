#!/bin/bash

# When generating the required am2r.apk using AM2RLauncher 2.3.0, make sure you check "include hires audio files when making the android (apk) version" in the Launchers settings. Then rename the resulting file to am2r.apk, it should be around 300MB in size.
#grab undertale libs (openal, etc) and place them in libs

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

get_controls

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

SHDIR=$(dirname "$0")
GAMEDIR="$SHDIR/am2r"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

export LD_LIBRARY_PATH="$GAMEDIR/libs":"/usr/lib":"/usr/lib32"
$ESUDO rm -rf ~/.config/am2r
ln -sfv $GAMEDIR/conf/am2r/ ~/.config/

chmod +x ./gmloader

$GPTOKEYB "gmloader" -c "./am2r.gptk" &
./gmloader "$GAMEDIR/gamedata/am2r.apk"

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> /dev/tty1
printf "\033c" >> /dev/tty0