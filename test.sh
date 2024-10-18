#!/bin/bash
command -v dialog >/dev/null 2>&1 || { echo >&2 "I require \"dialog\" but it's not installed.  Aborting."; exit 1; }

# delete folder contents
rm -rf ./nc-folder/
# rebuild gitattributes file
mkdir ./nc-folder
echo "">./nc-folder/.gitattributes

password=$(tempfile 2>/dev/null)
username=$(tempfile 2>/dev/null)
nextcloudserver=$(tempfile 2>/dev/null)

dialog --title "Next Cloud Client test" --inputbox "Enter your server url " 10 60 $1 2>$nextcloudserver

ret=$?
case $ret in
  0)
    nextcloudserver=$(<$nextcloudserver);;
  1)
    echo "Cancel pressed."
    exit;;
  255)
    [ -s $password ] &&  cat $password || echo "ESC pressed."
    exit;;
esac

dialog --title "Next Cloud Client test" \
--inputbox "Enter your username " 10 30 $2 2>$username

ret=$?
case $ret in
  0)
    username=$(<$username);;
  1)
    echo "Cancel pressed."
    exit;;
  255)
    [ -s $password ] &&  cat $password || echo "ESC pressed."
    exit;;
esac

# get password with the --insecure option
dialog --title "Password" \
--clear \
--insecure \
--passwordbox "Enter your password" 10 30 $3 2> $password

ret=$?


# make decison
case $ret in
  0)
    password=$(<$password);;
  1)
    echo "Cancel pressed.";;
  255)
    [ -s $password ] &&  cat $password || echo "ESC pressed."
    exit;;
esac

 
docker run -it --rm \
 -v ./nc-folder:/media/nextcloud \
 -e NC_USER=$username -e NC_PASS=$password \
 -e NC_URL=$nextcloudserver\
 -e NC_INTERVAL=20\
 volkerhaensel/nextcloud-client
 
