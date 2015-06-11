#!/bin/bash
DEV_PKGS=($(sandstorm mongo <<EOF | grep GREPME | cut -d ' ' -f 2-
use meteor
var cursor = db.devapps.find();
while (cursor.hasNext()) {
    var app = cursor.next();
    print("GREPME " + app.packageId);
}
EOF
))

PKG_COUNT=${#DEV_PKGS[@]}

if [ $PKG_COUNT -ne 1 ] ; then
    echo "Dev package ids:"
    for (( i=0; i<$PKG_COUNT; i++)); do
        echo $i "${DEV_PKGS[$i]}"
    done
    echo "Multiple packages are currently available in dev-mode; which are you looking for?"
    # TODO: ask user, use selection
    return
else
    SELECTED_PKG=${DEV_PKGS[0]}
    echo "Found unique dev package: $SELECTED_PKG"
fi

DEV_GRAINS=($(sandstorm mongo <<EOF | grep GREPME | cut -d ' ' -f 2-
use meteor
var cursor = db.grains.find({packageId: "$SELECTED_PKG"});
while (cursor.hasNext()) {
    var grain = cursor.next();
    print("GREPME " + grain._id);
}
EOF
))

GRAIN_COUNT=${#DEV_GRAINS[@]}

if [ $GRAIN_COUNT -ne 1 ] ; then
    for (( i=0; i<$GRAIN_COUNT; i++)); do
        echo $i "${DEV_GRAINS[$i]}"
    done
    echo "Select grain:"
    # TODO: ask user, use selection
    return
else
    SELECTED_GRAIN_ID=${DEV_GRAINS[0]}
    echo "Found unique grain id $SELECTED_GRAIN_ID for $SELECTED_PKG"
fi

echo "grain id: $SELECTED_GRAIN_ID"
SUPERVISOR_PID=$(pgrep --newest --full "$SELECTED_GRAIN_ID")
echo "supervisor: $SUPERVISOR_PID"
GRAIN_PID=$(pgrep --oldest --parent $SUPERVISOR_PID)
echo "grain pid: $GRAIN_PID"

echo "entering namespaces"
sudo nsenter --target "$GRAIN_PID" --mount --uts --ipc --net --pid --wd
