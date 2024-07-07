#!/bin/bash

set pipefail

if [ -n "$MODE" ]; then
    echo Running in mode: $MODE
else
    echo "MODE is empty, set either RECENT or ALL"
    exit 1
fi

if [ -f source.txt ]; then
    echo "File source.txt exists."
else
    echo "File source.txt does not exist."
    exit 1
fi

if [ -n "$REPEAT_SECONDS" ]; then
    echo Run every $REPEAT_SECONDS seconds
else
    echo "REPEAT_SECONDS is empty"
    exit 1
fi

mkdir -p logs

while true; do
    if [ "$MODE" == "RECENT" ]; then
        sh recent.sh
        tail -f output.log
    fi

    if [ "$MODE" == "ALL" ]; then
        ./recent.sh
        tail -f output.log
    fi
 
    sleep $REPEAT_SECONDS
done


