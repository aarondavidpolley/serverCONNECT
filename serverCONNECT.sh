#!/bin/bash

################################################################################
# Author:    Aaron Polley                                                      #
# Date:      25/11/2017                                                        #
# Version:   1.0                                                               #
# Purpose:   Scripting for mounting, monitoring and re-mounting server volumes #
#            Should be triggered by LaunchAgent using WatchPaths               #
################################################################################

#---Variables To Edit---#
ServerName="NAS"       #Specify the server sharing/bonjour name
ServerIP="10.3.14.20"       #Specify the server IP
ServerDomain="server.mycompany.private"       #Specify the server DNS name/hostname
ServerAddress="$ServerIP"       #Change to "$ServerDomain" if it is the preffered connection address
ShareVolumes=("Software" "DATA")     #Specify the server volume/folder names in quotes (""), separated by spaces
ShareType="afp"       #Change to "smb" if it is the desired connection method

#---Logic Variables---#
script_version="1.0"
user_id=`id -u`
user_name=`id -un $user_id`
home_dir=`dscl . read /Users/"$user_name" NFSHomeDirectory | awk '{print $2}'`
log_file="$home_dir/Library/Logs/serverCONNECT.log"
os_vers=`sw_vers -productVersion | awk -F "." '{print $2}'`
DateTime=`date "+%a %b %d %H:%M:%S"`

#---Redirect output to log---#
exec >> $log_file 2>&1


#---Script Actions---#
# Don't run for specific user, i.e. Admin
if [ $user_name = "ladmin" ] || [ $user_name = "admin" ] || [ $user_name = "administrator" ]; then

    if [[ $1 = "debug" ]]; then
      echo "$DateTime - Running as excluded user, exiting"
    fi
    exit 0
fi



#---------------GAME TIME----------------

if [[ $1 = "debug" ]]; then
	echo "*************************************************************************"
	echo "$DateTime - serverCONNECT beginning v${script_version}"
	echo "$DateTime     - User:              $user_name"
	echo "$DateTime     - User ID:           $user_id"
	echo "$DateTime     - Home Dir:          $home_dir"
	echo "$DateTime     - OS Vers:           10.${os_vers}"
fi

if [[ $2 = "dev" ]]; then

echo "$DateTime - ShareVolumes:"
printf "%s\n" "${ShareVolumes[@]}"
fi

if ping -q -c 1 -W 1 "$ServerIP" >/dev/null; then

	if [[ $1 = "debug" ]]; then
    echo "$DateTime - Server IP is up"
	fi

	#---Start Loop---#
  for ShareVolume in "${ShareVolumes[@]}" ; do

		ShareMountPoint=$(echo "/Volumes/$ShareVolume")
		ShareMountCheck=`mount | grep "$ShareMountPoint"`
		SharePath=$(echo "$ServerAddress/$ShareVolume")

		if [[ $2 = "dev" ]]; then
			echo "$DateTime - ShareMountCheck Results: $ShareMountCheck"
		fi

		if [ "$ShareMountCheck" == "" ]; then        # Checking if the volume is present

					if [[ $1 = "debug" ]]; then
						echo "$DateTime - $ShareMountPoint (or variant) does not exist"
					fi

					#---Script Function---#
					echo "$DateTime - Mounting $ShareType://$SharePath on $ServerName..."

					# Mount the network home
					/usr/bin/osascript <<END

          tell application "Finder"
            mount volume "$ShareType://$SharePath"
          end tell
END

          if [[ $1 = "debug" ]]; then
            echo "$DateTime - Pausing for 5 seconds..."
          fi

					sleep 5
		else
 			if [[ $1 = "debug" ]]; then
 				echo "$DateTime - $ShareVolume already connected..."
 			fi
 		fi

  done

  if [[ $2 = "dev" ]]; then
    echo "$DateTime - Final mount list:"
    mount | grep "$ShareType"
  fi

  if [[ $1 = "debug" ]]; then
  echo "$DateTime - serverCONNECT Complete..."
  echo "*************************************************************************"
  fi

else

	if [[ $1 = "debug" ]]; then
		echo "$DateTime - Server IP of $ServerIP is down, nothing to do"
    echo "$DateTime - serverCONNECT Complete..."
    echo "*************************************************************************"
	fi

fi

exit 0
