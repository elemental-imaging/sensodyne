#!/bin/bash

# ---------------------------------------------------------
# Customizable Settings
# ---------------------------------------------------------

# where to store the sparse-image
SENSODYNE=${HOME}/Development/.sensodyne.dmg.sparseimage

# location where sensodyne will be mounted
MOUNTPOINT=${HOME}/Development/Sensodyne

# name of sensodyne as visible in Finder
VOLUME_NAME=Sensodyne

# volume size
VOLUME_SIZE=1g

# ---------------------------------------------------------
# Functionality
# ---------------------------------------------------------

create() {
    hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size ${VOLUME_SIZE} -volname ${VOLUME_NAME} ${SENSODYNE}
}

automount() {
    cat << EOF > com.sensodyne.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>RunAtLoad</key>
        <true/>
        <key>Label</key>
        <string>com.sensodyne</string>
        <key>ProgramArguments</key>
        <array>
            <string>hdiutil</string>
            <string>attach</string>
            <string>-notremovable</string>
            <string>-nobrowse</string>
            <string>-mountpoint</string>
            <string>${MOUNTPOINT}</string>
            <string>${SENSODYNE}</string>
        </array>
    </dict>
</plist>
EOF
    sudo cp com.sensodyne.plist /Library/LaunchDaemons/com.sensodyne.plist
}

detach() {
    m=$(hdiutil info | grep "${MOUNTPOINT}" | cut -f1)
    if [ ! -z "$m" ]; then
        sudo hdiutil detach $m
    fi
}

attach() {
    sudo hdiutil attach -notremovable -nobrowse -mountpoint ${MOUNTPOINT} ${SENSODYNE}
}

compact() {
    detach
    hdiutil compact ${SENSODYNE} -batteryallowed
    attach
}

help() {
    cat <<EOF
usage: sensodyne <command>

Possible commands:
   create       Initialize case-sensitive volume (only needed first time)
   automount    Configure OS X to mount the volume automatically on restart
   mount        Attach the case-sensitive volume
   unmount      Detach the case-sensitive volume
   compact      Remove any uneeded reserved space in the volume
   help         Display this message
EOF
}

invalid() {
    printf "sensodyne: '$1' is not a valid command.\n\n";
    help
}

case "$1" in
    create) create;;
    automount) automount;;
    mount) attach;;
    unmount) detach;;
    compact) compact;;
    help) help;;
    '') help;;
    *) invalid $1;;
esac
