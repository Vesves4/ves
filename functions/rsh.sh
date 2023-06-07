USERZ="$1"
ADDRZ="$2"
PATHZ="$3"

if [ -z $USERZ ] || [ -z $ADDRZ ] || [ -z $PATHZ ]
  then
  echo "Please provide valid arguments: remote [USER] [IP_ADDRESS] [PATH/TO/SCRIPT]"
else
  ssh $USERZ@$ADDRZ bash < $PATHZ
fi