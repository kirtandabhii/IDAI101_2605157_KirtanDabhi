#!/bin/bash
# Double-click this file to preview the ScamShield AI demo page with a working chatbot.
# Dialogflow Messenger refuses to run from a file:// page, so this serves it over http instead.
cd "$(dirname "$0")"
echo "ScamShield AI demo -> http://localhost:8000"
echo "Leave this window open while you test. Press Ctrl+C when done."
( sleep 1; open "http://localhost:8000" ) &
python3 -m http.server 8000
