#!/bin/bash

################################################################################
# Author: 	Aaron Polley                                                       #
# Date:		26/04/2017                                                         #
# Version:	1.0                                                                #
# Purpose:  Check if server connected and reconnect                            #
#           This should be run as a login script via LauchAgent                #
################################################################################

#---Variables and such---#
script_version="1.0"
user_id=`id -u`
user_name=`id -un $user_id`
home_dir="/Users/$user_name"
server_connected="/Volumes/DATA"
log_file="$home_dir/Library/Logs/serverconnect_setup.log"
os_vers=`sw_vers -productVersion | awk -F "." '{print $2}'`

#---Redirect output to log---#
exec >> $log_file 2>&1

server_connect(){
echo "*************************************************************************"
echo `date "+%a %b %d %H:%M:%S"` " - Max ServerConnect beginning v${script_version}"
echo `date "+%a %b %d %H:%M:%S"` "     - User:              $user_name"
echo `date "+%a %b %d %H:%M:%S"` "     - User ID:           $user_id"
echo `date "+%a %b %d %H:%M:%S"` "     - Home Dir:          $home_dir"
echo `date "+%a %b %d %H:%M:%S"` "     - OS Vers:           10.${os_vers}"

echo `date "+%a %b %d %H:%M:%S"` " - Mounting network volumes..."

# Mount the network home
	mount_script=`/usr/bin/osascript > /dev/null << EOT
#	tell application "Finder" 
#	activate
	mount volume "afp://10.61.1.15/DATA"
#	mount volume "afp://10.61.1.15/FTP"
#	mount volume "afp://10.61.1.15/Management"
#	mount volume "afp://10.61.1.15/GM"
#	mount volume "afp://10.61.1.15/SalesReps"
#	mount volume "afp://10.61.1.15"
#	end tell
EOT`

echo `date "+%a %b %d %H:%M:%S"` " - ServerConnect Complete..."

}

#---Script Actions---#
# Don't run for the Admin user
if [ $user_name = "ladmin" ]; then
    exit 0
fi
if [ ! -d "$server_connected" ]; then        # Check if the volume is present
    server_connect
else

echo `date "+%a %b %d %H:%M:%S"` " - Server already connected..."

fi

exit 0