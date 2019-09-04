![GUI for LogRhythm Open-Collector](Images/Banner.png "GUI for LogRhythm Open-Collector")
# GUI for LogRhythm Open-Collector (OpenCollector-UI)

## Releases

### Installation Steps:
- Create a folder on your drive
- copy / decompress "```OC_UI-v**X.Y**.ps1```" (where **X.Y** is the version number, for example "```OC_UI-v**1.0**.ps1```") into the newly created folder

### Running it:
- run "```OC_UI-vX.Y.ps1```" from the PowerShell command line
- if prompted for trusting non signed script, agree
- if you want to remove the warning, you can authorise non-signed scripts with the following procedure:
  - run PowerShell command line **as Administrator**
  - enter the following command:
````Set-ExecutionPolicy -ExecutionPolicy Unrestricted````
  - close the PowerShell prompt that is running as Administrator

### Notes:
#### Open-Collector Helper - v1.0
- In the **Login** screen, you must provide ```root``` or similarly priviledged user credentials, to be able to install the stack (well, it's at least required to install Docker)
  - I have ideas on how to remove this constrain, but it didn't make it in v1.0
- The credentials you enter are only saved when closing the App if there was a succesful connection.
  - People think it doesn't work when they do not connect, and close the App.
- The credentials are saved in plain text in the config.json file.
  - if you don't like that, un-tick the "[ ] **Remember me**" and/or "[ ] **Remember my password**" boxes
  - I have plan to save them in a safe way, but didn't have time for v1.0
- I do not save any of the Options to the Config file in the **Install** screen
  - Again, no time for v1.0

```powershell
# ###########################################
#
# LogRhythm Open-Collector Helper
#
# ###############
#
# (c) 2019, LogRhythm
#
#
# ###############
#
# Change Log:
#
# v0.1 - 2019-08-09 - Tony Massé (tony.masse@logrhythm.com)
# - Skeleton
# - Load UI from external YAML
#
# v0.9 - 2019-08-09 - Tony Massé (tony.masse@logrhythm.com)
# - Navigation mapping (Left menu with screen/tabs)
# - Login tab, including all the option, fully working
# - Connection over SSH and disconnection
# - Connection status (bottom right of window)
# - Save and read configuration (for the Host)
# - Status tab, fully working
# - Status tab, semi real-time update of the widgets
# - Create the Internet Connection status check
# - Install tab, almost fully functional (missing Config Export/Import)
# - Install tab, fully functional
# - Pipeline tab, almost fully functional (missing Delete log and export results)
#
# v1.0 - 2019-09-04 - Tony Massé (tony.masse@logrhythm.com)
# - Package UI in the PowerShell script
# - Release
#
# ################
#
# TO DO
# - Save credentials in a safe way
# - In InstallationDeployOCHelper, do Steps 2. (use local host to download OCHelper) and 3. (use local cached copy of OCHelper)
# - Install tab, Save the Options to the Config file
# - Install tab, Read the Options from the Config file
# - Offer a way for people who need to enter a password for SUDO to do so (via parameters)
#
# ################
```
