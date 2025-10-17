#!/bin/bash
set -euo pipefail
VENV=/opt/app-venv
cd /opt/app

# Change app.py to your app's filename
$VENV/bin/python3 app.py

exit 0
