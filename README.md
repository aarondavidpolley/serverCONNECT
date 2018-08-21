# serverCONNECT

Scripting for mounting, monitoring and re-mounting server volumes

//How To Use//

Download the repo and edit the serverCONNECT.sh file.  Adjust the "Variables To Edit" section, save, and then build the installer using the Packages App Project file included.  See:

http://s.sudre.free.fr/Software/Packages/about.html

As of v1.0, you can also pass a "debug" variable running from command line or LaunchAgent for more verbose logging.  For example:

sh /LibraryScripts/serverCONNECT.sh debug

or

<key>ProgramArguments</key>
<array>
 <string>/Library/Scripts/serverCONNECT.sh</string>
 <string>debug</string>
</array>

Logs are written to ~/Library/Logs/serverCONNECT.log

//LICENSE//

This is available under the MIT License: https://github.com/aarondavidpolley/serverCONNECT/blob/master/LICENSE
