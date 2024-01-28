#!/bin/sh

echo "Now running Enhanced Palworld Settings script."
# install python if not installed
if ! command -v python &> /dev/null
then
    echo "Python is not installed. Installing Python..."
    sudo apt-get update && sudo apt-get install -y python
    echo "Python is installed."
fi

echo "Running palworld_settings.py..."
# run palworld_settings.py
python palworld_settings.py
