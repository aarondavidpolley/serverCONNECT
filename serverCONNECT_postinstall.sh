#!/bin/bash

################################################################################
# Author:    Aaron Polley                                                      #
# Date:      25/11/2017                                                        #
# Version:   1.0                                                               #
# Purpose:   Post install script for serverCONNECT                             #
################################################################################

#---Variables and such---#
script_version="1.0"
user_id=`id -u`
user_name=`id -un $user_id`
home_dir=`dscl . read /Users/"$user_name" NFSHomeDirectory | awk '{print $2}'`
log_file="/var/log/serverCONNECT_install.log"
os_vers=`sw_vers -productVersion | awk -F "." '{print $2}'`
currentUser=`/usr/bin/stat -f%Su /dev/console`
DateTime=`date "+%a %b %d %H:%M:%S"`
OldVersion="/Library/LaunchAgents/com.max.serverCONNECT.plist"

#---Redirect output to log---#
exec >> $log_file 2>&1


#---Script Start---#
echo "*************************************************************************"
echo "$DateTime - serverCONNECT postinstall v${script_version}"
echo "$DateTime     - User:              $user_name"
echo "$DateTime     - User ID:           $user_id"
echo "$DateTime     - Home Dir:          $home_dir"
echo "$DateTime     - OS Vers:           10.${os_vers}"
echo "$DateTime     - LoadUser:          $currentUser"

# This is useful for loading launch daemons and agents.

    # Run postinstall actions for root.
    echo "$DateTime - Executing postinstall scripts per user"
    # Add commands to execute in system context here.

    #Check if v0.1 LaunchAgent exists#

    if [ -e "$OldVersion" ]; then

      #Unload and remove old Agent#

      for pid_uid in $(ps -axo pid,uid,args | grep -i "[l]oginwindow.app" | awk '{print $1 "," $2}'); do
          pid=$(echo $pid_uid | cut -d, -f1)
          uid=$(echo $pid_uid | cut -d, -f2)
          # Replace echo with e.g. launchctl load.
          launchctl asuser "$uid" chroot -u "$uid" / echo "$DateTime - Unloading old agent for $uid"
          launchctl asuser "$uid" chroot -u "$uid" / launchctl unload /Library/LaunchAgents/com.max.serverCONNECT.plist
      done

      rm /Library/LaunchAgents/com.max.serverCONNECT.plist

    fi

    # Reload Agent for all logged in users.
    for pid_uid in $(ps -axo pid,uid,args | grep -i "[l]oginwindow.app" | awk '{print $1 "," $2}'); do
        pid=$(echo $pid_uid | cut -d, -f1)
        uid=$(echo $pid_uid | cut -d, -f2)
        # Per User Actions
        launchctl asuser "$uid" chroot -u "$uid" / echo "$DateTime - Executing postinstall for $uid"
        launchctl asuser "$uid" chroot -u "$uid" / launchctl unload /Library/LaunchAgents/com.github.aarondavidpolley.serverCONNECT.plist
        launchctl asuser "$uid" chroot -u "$uid" / launchctl load -w /Library/LaunchAgents/com.github.aarondavidpolley.serverCONNECT.plist
    done

echo "$DateTime - Complete..."

echo "*************************************************************************"

exit 0
