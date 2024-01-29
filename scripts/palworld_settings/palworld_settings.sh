#!/bin/sh

echo "Now running Enhanced Palworld Settings script."
if ! [ -x "$(command -v python3)" ]; then
    echo "Python is not installed."
    exit 1
fi



echo "Running palworld_settings.py..."
python3 /home/steam/server/palworld_settings/palworld_settings.py
returnCode=$?

if [ $returnCode -ne 0 ]; then
    echo "Error occurred while running palworld_settings.py with exit code: $returnCode"
    exit $returnCode
fi

exit 0