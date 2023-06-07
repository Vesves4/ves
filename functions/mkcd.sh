FOLDER="$1"

if [ -z "$FODLER" ]
  then
  echo "Usage: mkcd <folder_name>"
else
    mkdir -p "$FOLDER"
    cd "$FOLDER"
fi