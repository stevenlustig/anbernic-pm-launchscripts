#!/bin/bash

# you will need to obtain libSDL2_gfx-1.0.so.0 (e.g. download the rpm and extract it from https://convertio.co/) and place it in zeldabolb/libs

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

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR=$(dirname "$0")
GAMEDIR="$PORTDIR/zeldaolb"

cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
export TERM=linux
printf "\033c" > $CUR_TTY

## RUN SCRIPT HERE

export LD_LIBRARY_PATH="$GAMEDIR/libs:/usr/lib:/usr/lib32"

$ESUDO chmod -x ./zeldaolb

echo "Starting game." > $CUR_TTY

$GPTOKEYB "zeldaolb" -c "zeldaolb.gptk" &
./zeldaolb

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
