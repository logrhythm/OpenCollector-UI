![GUI for LogRhythm Open-Collector](../Images/Banner.png "GUI for LogRhythm Open-Collector")
# GUI for LogRhythm Open-Collector (OpenCollector-UI)

## Resources

This folder is used to store items that are downloaded automatically or on demand by the different tools.

#### OCHelper.sh
This is downloaded on the LogRhythm Open-Collector host, typically by the PowerShell GUI.
It is the CLI tool that acts a bridgehead / API backend for the other User Interfaces (PowerShell GUI, Web UI, etc...)

#### lrctl.zip
This is downloaded on the LogRhythm Open-Collector host, typically by ```OCHelper.sh```.
This contains the LogRhythm Open-Collector lightweight installer and the key to access its full size installer.

#### lrjq.zip
This is downloaded on the LogRhythm Open-Collector host, typically by ```OCHelper.sh```.
LRJQ is a JQ test tool that can be used from the CLI to test JQ Filters and JQ Transforms. 
```OCHelper.sh``` calls it to test the different files of a Pipeline Project. Usually because the UI asked for it.

#### ocpipeline.zip
This is downloaded on the LogRhythm Open-Collector host, typically by ```OCHelper.sh```.
This tool is designed to create the Pipeline Project templates/blanks.

#### Other files
The other files are there because they make it easier for me to test and sign things, but they are not Resources that get downloaded.
- ```**Test.sh**```
  - A simple list of the functions of the ```OCHelper.sh```, with examples of parameters to provide.
  - Do not run this tool, it's only design for me to 1. Remember the commands, 2. Test them by copying/pasting one or more lines from it.
- ```**Sign_OCHelper_sh.sh**```
  - The small Bash script I made to sign (MD5 checksum, nothing fancy) the ```OCHelper.sh``` script.
  - It allows this command to work ```./OCHelper.sh --SelfIntegrityCheck```
- **oc.conf.VirginUTC.txt**
  - A config export from a LogRhythm Open-Collector that has been freshly installed and minimally configured.
  - A copy is included in ```lrctl.zip``` as it's used by the ```OCHelper.sh``` script during one of the Post-Install steps of the Open-Collector intallation procedure.
- **20190802.Box_links.txt**
  - A backed-up list of the direct download links of all the above files. Both on Box.com and Github.com. As well as the mapping between the short URL (tiny.cc) and their equivalent long URL.
  - The scripts always use the short URLs, which in turn points to the long URLs on either Box.com or Github.com. Allowing me to change the mapping if necessary.
  