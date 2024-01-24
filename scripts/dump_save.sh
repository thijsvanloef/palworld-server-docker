#!/bin/bash

DATE=$(date +"%d-%m-%Y")
FILE_PATH="/palworld/backups/palworld-save-${DATE}.tar.gz"
cd /palworld/Pal/

tar -zcf $FILE_PATH "Saved/"
echo "file dumped at $FILE_PATH"
