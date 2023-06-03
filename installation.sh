#!/bin/bash
echo "Setting up ves script"

EXISTING_FILE="$(cat /home/$USER/ves/ves.sh 2>/dev/null)"
EXISTING_FOLDER="$(ls /home/$USER/ | grep ves 2>/dev/null)"
EXISTING_ALIAS="$(cat /home/$USER/.bashrc | grep ves.sh 2>/dev/null)"

directory() {
  mkdir /home/$USER/ves 2>/dev/null
}

file() {
  curl https://raw.githubusercontent.com/Vesves4/ves/main/ves.sh > /home/$USER/ves/ves.sh 2>/dev/null
  chmod +x /home/$USER/ves/ves.sh 2>/dev/null
}

alias_setup() {
  echo "alias ves=\"sudo -u $USER /home/$USER/ves/ves.sh\"" >> /home/$USER/.bashrc 2>/dev/null
  . /home/$USER/.bashrc
}

if [ -z "$EXISTING_FILE" ] && [ -z "$EXISTING_FOLDER" ] && [ -z "$EXISTING_ALIAS" ]
  then
  echo "Initial setup.. Installing script now"
  sleep 1s
  directory
  file
  alias_setup
  echo "Installation successfull, please restart your terminal"
elif [ -z "$EXISTING_FILE" ] && [ "$EXISTING_FOLDER" ] && [ "$EXISTING_ALIAS" ]
  then
  echo "File is missing, fixing it now"
  file
  sleep 1
  echo "Installation successfull"
elif [ -z "$EXISTING_FILE" ] && [ "$EXISTING_FOLDER" ] && [ -z "$EXISTING_ALIAS" ]
  then
  echo "Only script folder was found, please not that the script location must be ~/ves/ves.sh"
  file
  alias_setup
  sleep 1
  echo "Installation successfull, please restart your terminal"
elif [ "$EXISTING_FILE" ] && [ "$EXISTING_FOLDER" ] && [ -z "$EXISTING_ALIAS" ]
  then
  echo "Missing alias, fixing..."
  alias_setup
  sleep 1
  echo "Installation successfull, please restart your terminal"
elif [ -z "$EXISTING_FILE" ] && [ -z "$EXISTING_FOLDER" ] && [ "$EXISTING_ALIAS" ]
  then
  echo "Found alias but missing files, fixing now.."
  directory
  file
  sleep 1
  echo "Installation successfull, please restart your terminal"
elif [ "$EXISTING_FILE" ] && [ "$EXISTING_FOLDER" ] && [ "$EXISTING_ALIAS" ]
  then
  echo "'ves' script already installed, you can update it by running 'ves update'"
  echo "In case you havent restarted your terminal after installation, you can also do '. ~/.bashrc'"
else
  echo "Error"
fi
