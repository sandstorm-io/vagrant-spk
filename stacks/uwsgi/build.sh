#!/bin/bash
set -euo pipefail
VENV=/opt/app-venv
if [ ! -d $VENV ] ; then
    sudo mkdir -p $VENV -m777
    virtualenv $VENV
else
    echo "$VENV exists, moving on"
fi

if [ -f /opt/app/requirements.txt ] ; then
    $VENV/bin/pip install -r /opt/app/requirements.txt
fi
