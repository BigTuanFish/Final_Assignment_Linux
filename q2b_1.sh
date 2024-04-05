#!/bin/bash
#Q2b_1

#Install python3-flask if not already installed

if ! dpkg -s python3-flask >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y python3-flask
    echo "python3-flask installed successfully."
else
    echo "python3-flask is already installed."
fi
