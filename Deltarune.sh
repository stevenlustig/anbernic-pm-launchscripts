#!/bin/bash


# Download the windows version of Deltarune (Steam)
# delete the .ini, .exe and dll files.
# create assets/ folder and place everything else inside excepting the data.win
# You need to obtain armeabi-v7a/libc++_shared.so, armeabi-v7a/liboboe.so, armeabi-v7a/libyoyo.so from an Android game made in Game Maker Studio 2. 
# Compile it yourself and extract them or download a game and get them
# place them in /lib/armeabi-v7a
# create game.zip from assets/ and lib/ folders
# change the extension to .apk
# place the apk in PORTS/deltarune

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

source $controlfolder/control.txt
source $controlfolder/device_info.txt
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

$ESUDO chmod 666 /dev/tty0

GAMEDIR="$SHDIR/deltarune"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs:$GAMEDIR/utils/libs":$LD_LIBRARY_PATH
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

printf "\033c" > /dev/tty0
install() {
    $ESUDO mkdir -p gamedata/assets/
    $ESUDO rm -rf gamedata/*.exe gamedata/*.dll gamedata/*.ini
    mv gamedata/*.ogg gamedata/assets/
    mv gamedata/*.png gamedata/assets/
    mv gamedata/*.dat gamedata/assets/
    mv gamedata/*.json gamedata/assets/
    mv gamedata/mus/*.ogg gamedata/assets/mus/
    mv gamedata/snd_power gamedata/assets/snd_power
    mv gamedata/lang/*.json gamedata/assets/lang/

    cd gamedata
    $ESUDO ../utils/zip -r -0 ../game.apk ./assets || return 1
    rm -rf assets/
    cd $GAMEDIR
    touch installed
}

[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid
[ -f "./gamedata/game.unx" ] && mv gamedata/game.unx gamedata/game.droid

if [ ! -f installed ]; then
    echo "Performing first-time setup, please wait..." > /dev/tty0
    install
    if [ $? -ne 0 ]; then
        echo "An error occurred during the installation process. Exiting." > /dev/tty0
        exit 1
    fi
fi

$GPTOKEYB "gmloader" -c "deltarune.gptk" &
echo "Loading, please wait... " > /dev/tty0

$ESUDO chmod +x "$GAMEDIR/gmloader"

./gmloader game.apk

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
printf "\033c" > /dev/tty0

#$ESUDO kill -9 "$(pidof gptokeyb)"