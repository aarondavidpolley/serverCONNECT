#!/bin/bash

################################################################################
# Author:    Aaron Polley                                                      #
# Date:      14/09/2017                                                        #
# Version:   0.01                                                              #
# Purpose:   Scripting for mounting, monitoring and re-mounting server volumes #
#            Should be triggered by LaunchAgent using WatchPaths               #
################################################################################

#---Variables and such---#
script_version="0.01"
user_id=`id -u`
user_name=`id -un $user_id`
home_dir=`dscl . read /Users/"$user_name" NFSHomeDirectory | awk '{print $2}'`
log_file="$home_dir/Library/Logs/serverCONNECT.log"
os_vers=`sw_vers -productVersion | awk -F "." '{print $2}'`
DateTime=`date "+%a %b %d %H:%M:%S"`
ServerName="KFD NAS"
ServerIP="10.3.14.20"
ServerDomain="server.mycompany.private"
ShareVolume="Software"
ShareMountPoint="/Volumes/$ShareVolume/"
SharePath="$ServerIP/$ShareVolume"
#--Uncomment the correct ShareType, only have 1!--#
#ShareType="smb"
ShareType="afp"

#---Redirect output to log---#
exec >> $log_file 2>&1


#---Script Function---#

server_connect(){

echo "*************************************************************************"
echo "$DateTime - serverCONNECT beginning v${script_version}"
echo "$DateTime     - User:              $user_name"
echo "$DateTime     - User ID:           $user_id"
echo "$DateTime     - Home Dir:          $home_dir"
echo "$DateTime     - OS Vers:           10.${os_vers}"

echo "$DateTime - Mounting network volumes for $ServerName..."

# Mount the network home
	mount_script=`/usr/bin/osascript > /dev/null << EOT
#	tell application "Finder"
#	activate
	mount volume "$ShareType://$SharePath"
#	end tell
EOT`

echo "$DateTime - Pausing for 5 seconds..."

sleep 5

echo "$DateTime - serverCONNECT Complete..."

echo "*************************************************************************"

}

#---Script Actions---#
# Don't run for specific user, i.e. Admin
if [ $user_name = "ladmin" ]; then
    exit 0
fi
if [ ! -e "$ShareMountPoint" ]; then        # Check if the volume is present

  if ping -q -c 1 -W 1 "$ServerIP" >/dev/null; then

    echo "$DateTime - Server IP is up"

    server_connect

  else

     echo "$DateTime - Server IP is down, nothing to do"

  fi

else

echo "$DateTime - Server already connected..."

fi

exit 0
