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

Clear-Host

########################################################################################################################
##################################### Variables, Constants and Function declaration ####################################
########################################################################################################################

#  888     888                  d8b          888      888                              .d8888b.                             888                      888             
#  888     888                  Y8P          888      888                             d88P  Y88b                            888                      888             
#  888     888                               888      888                             888    888                            888                      888             
#  Y88b   d88P  8888b.  888d888 888  8888b.  88888b.  888  .d88b.  .d8888b            888         .d88b.  88888b.  .d8888b  888888  8888b.  88888b.  888888 .d8888b  
#   Y88b d88P      "88b 888P"   888     "88b 888 "88b 888 d8P  Y8b 88K                888        d88""88b 888 "88b 88K      888        "88b 888 "88b 888    88K      
#    Y88o88P   .d888888 888     888 .d888888 888  888 888 88888888 "Y8888b.           888    888 888  888 888  888 "Y8888b. 888    .d888888 888  888 888    "Y8888b. 
#     Y888P    888  888 888     888 888  888 888 d88P 888 Y8b.          X88 d8b       Y88b  d88P Y88..88P 888  888      X88 Y88b.  888  888 888  888 Y88b.       X88 
#      Y8P     "Y888888 888     888 "Y888888 88888P"  888  "Y8888   88888P' 88P        "Y8888P"   "Y88P"  888  888  88888P'  "Y888 "Y888888 888  888  "Y888  88888P' 
#                                                                           8P                                                                                       
#                                                                           "                                                                                        
#                                                                                                                                                                    
#  88888888888                                            .d8888b.           8888888888                            888    d8b                                        
#      888                                               d88P  "88b          888                                   888    Y8P                                        
#      888                                               Y88b. d88P          888                                   888                                               
#      888     888  888 88888b.   .d88b.  .d8888b         "Y8888P"           8888888    888  888 88888b.   .d8888b 888888 888  .d88b.  88888b.  .d8888b              
#      888     888  888 888 "88b d8P  Y8b 88K            .d88P88K.d88P       888        888  888 888 "88b d88P"    888    888 d88""88b 888 "88b 88K                  
#      888     888  888 888  888 88888888 "Y8888b.       888"  Y888P"        888        888  888 888  888 888      888    888 888  888 888  888 "Y8888b.             
#      888     Y88b 888 888 d88P Y8b.          X88       Y88b .d8888b        888        Y88b 888 888  888 Y88b.    Y88b.  888 Y88..88P 888  888      X88             
#      888      "Y88888 88888P"   "Y8888   88888P'        "Y8888P" Y88b      888         "Y88888 888  888  "Y8888P  "Y888 888  "Y88P"  888  888  88888P'             
#                   888 888                                                                                                                                          
#              Y8b d88P 888                                                                                                                                          
#               "Y88P"  888                                                                                                                                          

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

# Version
$VersionNumber = "1.0"
$VersionDate   = "2019-09-04"
$VersionAuthor = "Tony Massé (tony.masse@logrhythm.com)"
$Version       = "v$VersionNumber - $VersionDate - $VersionAuthor"

# Time formats
$TimeStampFormatForJSON = "yyyy-MM-ddTHH:mm:ss.fffZ"
$TimeStampFormatForLogs = "yyyy.MM.dd HH:mm:ss"


#  8888888b.  d8b                           888                     d8b                                                888        .d888 d8b 888                         
#  888  "Y88b Y8P                           888                     Y8P                                                888       d88P"  Y8P 888                         
#  888    888                               888                                                                        888       888        888                         
#  888    888 888 888d888  .d88b.   .d8888b 888888  .d88b.  888d888 888  .d88b.  .d8888b         8888b.  88888b.   .d88888       888888 888 888  .d88b.  .d8888b        
#  888    888 888 888P"   d8P  Y8b d88P"    888    d88""88b 888P"   888 d8P  Y8b 88K                "88b 888 "88b d88" 888       888    888 888 d8P  Y8b 88K            
#  888    888 888 888     88888888 888      888    888  888 888     888 88888888 "Y8888b.       .d888888 888  888 888  888       888    888 888 88888888 "Y8888b.       
#  888  .d88P 888 888     Y8b.     Y88b.    Y88b.  Y88..88P 888     888 Y8b.          X88       888  888 888  888 Y88b 888       888    888 888 Y8b.          X88       
#  8888888P"  888 888      "Y8888   "Y8888P  "Y888  "Y88P"  888     888  "Y8888   88888P'       "Y888888 888  888  "Y88888       888    888 888  "Y8888   88888P'       
#                                                                                                                                                                       
#                                                                                                                                                                       
#                                                                                                                                                                       

# Directories and files information
# Base directory
$basePath = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path
cd $basePath

# Last Browse directory
$LastBrowsePath = $basePath

# Config directory and file
$configPath = Join-Path -Path $basePath -ChildPath "config"
if (-Not (Test-Path $configPath))
{
	New-Item -ItemType directory -Path $configPath | out-null
}

$configFile = Join-Path -Path $configPath -ChildPath "config.json"

#  888                                 d8b                   
#  888                                 Y8P                   
#  888                                                       
#  888       .d88b.   .d88b.   .d88b.  888 88888b.   .d88b.  
#  888      d88""88b d88P"88b d88P"88b 888 888 "88b d88P"88b 
#  888      888  888 888  888 888  888 888 888  888 888  888 
#  888      Y88..88P Y88b 888 Y88b 888 888 888  888 Y88b 888 
#  88888888  "Y88P"   "Y88888  "Y88888 888 888  888  "Y88888 
#                         888      888                   888 
#                    Y8b d88P Y8b d88P              Y8b d88P 
#                     "Y88P"   "Y88P"                "Y88P"  

# Log directory and file
$logsPath = Join-Path -Path $basePath -ChildPath "logs"
if (-Not (Test-Path $logsPath))
{
	New-Item -ItemType directory -Path $logsPath | out-null
}

$logFile = Join-Path -Path $logsPath -ChildPath ("LogRhythm.OC-UI." + (Get-Date).tostring("yyyyMMdd") + ".log")
if (-Not (Test-Path $logFile))
{
	New-Item $logFile -type file | out-null
}


# Logging functions
function LogMessage([string] $logLevel, [string] $message)
{
    $Msg  = ([string]::Format("{0}|{1}|{2}", (Get-Date).tostring("$TimeStampFormatForLogs"), $logLevel, $message))
	$Msg | Out-File -FilePath $logFile  -Append        
    Write-Host $Msg
}

function LogInfo([string] $message)
{
	LogMessage "INFO" $message
}

function LogError([string] $message)
{
	LogMessage "ERROR" $message
}

function LogDebug([string] $message)
{
	LogMessage "DEBUG" $message
}


#   .d8888b.                    888                      .d8888b.            .d8888b.  888                        888 
#  d88P  Y88b                   888                     d88P  "88b          d88P  Y88b 888                        888 
#  888    888                   888                     Y88b. d88P          888    888 888                        888 
#  888         8888b.   .d8888b 88888b.   .d88b.         "Y8888P"           888        888  .d88b.  888  888  .d88888 
#  888            "88b d88P"    888 "88b d8P  Y8b       .d88P88K.d88P       888        888 d88""88b 888  888 d88" 888 
#  888    888 .d888888 888      888  888 88888888       888"  Y888P"        888    888 888 888  888 888  888 888  888 
#  Y88b  d88P 888  888 Y88b.    888  888 Y8b.           Y88b .d8888b        Y88b  d88P 888 Y88..88P Y88b 888 Y88b 888 
#   "Y8888P"  "Y888888  "Y8888P 888  888  "Y8888         "Y8888P" Y88b       "Y8888P"  888  "Y88P"   "Y88888  "Y88888 
#                                                                                                                     
#                                                                                                                     
#                                                                                                                     

# Cache directory
$cachePath = Join-Path -Path $configPath -ChildPath "Local Cache"
if (-Not (Test-Path $cachePath))
{
	New-Item -ItemType directory -Path $cachePath | out-null
}

# Local copy of the OCHelper.sh script
$OCHelperScriptLocalFile = Join-Path -Path $cachePath -ChildPath "OCHelper.sh"



#  Y88b   d88P        d8888 888b     d888 888            8888888b.                                                       d8b                   
#   Y88b d88P        d88888 8888b   d8888 888            888   Y88b                                                      Y8P                   
#    Y88o88P        d88P888 88888b.d88888 888            888    888                                                                            
#     Y888P        d88P 888 888Y88888P888 888            888   d88P 888d888  .d88b.   .d8888b  .d88b.  .d8888b  .d8888b  888 88888b.   .d88b.  
#     d888b       d88P  888 888 Y888P 888 888            8888888P"  888P"   d88""88b d88P"    d8P  Y8b 88K      88K      888 888 "88b d88P"88b 
#    d88888b     d88P   888 888  Y8P  888 888            888        888     888  888 888      88888888 "Y8888b. "Y8888b. 888 888  888 888  888 
#   d88P Y88b   d8888888888 888   "   888 888            888        888     Y88..88P Y88b.    Y8b.          X88      X88 888 888  888 Y88b 888 
#  d88P   Y88b d88P     888 888       888 88888888       888        888      "Y88P"   "Y8888P  "Y8888   88888P'  88888P' 888 888  888  "Y88888 
#                                                                                                                                          888 
#                                                                                                                                     Y8b d88P 
#                                                                                                                                      "Y88P"  

# ########
# Functions used to decompress/decode compressed/encoded UI XAML:
# - Get-DecompressedByteArray
# - Get-Base64DecodedDecompressedXML

# Function to decompress the XAML. 
function Get-DecompressedByteArray {
	[CmdletBinding()]
    Param (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [byte[]] $byteArray = $(Throw("-byteArray is required"))
    )
	Process {
	    Write-Verbose "Get-DecompressedByteArray"
        $input = New-Object System.IO.MemoryStream( , $byteArray )
	    $output = New-Object System.IO.MemoryStream
        $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
	    $gzipStream.CopyTo( $output )
        $gzipStream.Close()
		$input.Close()
		[byte[]] $byteOutArray = $output.ToArray()
        Write-Output $byteOutArray
    }
}

# Function to Decode the decompressed XAML. Used to decompress/decode compressed/encoded UI XAML
function Get-Base64DecodedDecompressedXML {
	[CmdletBinding()]
    Param (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $Base64EncodedCompressedXML = $(Throw("-Base64EncodedCompressedXML is required"))
    )
    Begin {
        [System.Text.Encoding] $enc = [System.Text.Encoding]::UTF8
    }

	Process {
        [byte[]]$DecodedBytes = [System.Convert]::FromBase64String($Base64EncodedCompressedXML)
        [string]$DecodedText = $enc.GetString( $DecodedBytes )
        $decompressedByteArray = Get-DecompressedByteArray -byteArray $DecodedBytes
        Write-Output $enc.GetString( $decompressedByteArray )
    }
}


#  888888b.                               .d8888b.      d8888                     8888888b.                        d88P       8888888888                                                888 d8b                   
#  888  "88b                             d88P  Y88b    d8P888                     888  "Y88b                      d88P        888                                                       888 Y8P                   
#  888  .88P                             888          d8P 888                     888    888                     d88P         888                                                       888                       
#  8888888K.   8888b.  .d8888b   .d88b.  888d888b.   d8P  888                     888    888  .d88b.            d88P          8888888    88888b.   .d8888b        .d8888b  .d88b.   .d88888 888 88888b.   .d88b.  
#  888  "Y88b     "88b 88K      d8P  Y8b 888P "Y88b d88   888                     888    888 d8P  Y8b          d88P           888        888 "88b d88P"          d88P"    d88""88b d88" 888 888 888 "88b d88P"88b 
#  888    888 .d888888 "Y8888b. 88888888 888    888 8888888888       888888       888    888 88888888         d88P            888        888  888 888            888      888  888 888  888 888 888  888 888  888 
#  888   d88P 888  888      X88 Y8b.     Y88b  d88P       888                     888  .d88P Y8b.            d88P             888        888  888 Y88b.          Y88b.    Y88..88P Y88b 888 888 888  888 Y88b 888 
#  8888888P"  "Y888888  88888P'  "Y8888   "Y8888P"        888                     8888888P"   "Y8888        d88P              8888888888 888  888  "Y8888P        "Y8888P  "Y88P"   "Y88888 888 888  888  "Y88888 
#                                                                                                                                                                                                             888 
#                                                                                                                                                                                                        Y8b d88P 
#                                                                                                                                                                                                         "Y88P"  

function Base64-Decode {
	[CmdletBinding()]
    Param (
		[Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
#        [string] $Base64EncodedText = $(Throw("-Base64EncodedText is required"))
        [string] $Base64EncodedText = ""
    )
    Begin {
        [System.Text.Encoding] $enc = [System.Text.Encoding]::UTF8
    }

	Process {
        [byte[]]$DecodedBytes = [System.Convert]::FromBase64String($Base64EncodedText)
        [string]$DecodedText = $enc.GetString( $DecodedBytes )
        Write-Output $DecodedText
    }
}

function Base64-Encode {
	[CmdletBinding()]
    Param (
		[Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $TextToBase64Encode = ""
    )
    Begin {
        [System.Text.Encoding] $enc = [System.Text.Encoding]::UTF8
    }

	Process {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($TextToBase64Encode)
        $Base64EncodedText = [Convert]::ToBase64String($Bytes)
        Write-Output $Base64EncodedText
    }
}


#  8888888b.                                            8888888b.  d8b          888                   
#  888   Y88b                                           888  "Y88b Y8P          888                   
#  888    888                                           888    888              888                   
#  888   d88P  .d88b.  88888b.  888  888 88888b.        888    888 888  8888b.  888  .d88b.   .d88b.  
#  8888888P"  d88""88b 888 "88b 888  888 888 "88b       888    888 888     "88b 888 d88""88b d88P"88b 
#  888        888  888 888  888 888  888 888  888       888    888 888 .d888888 888 888  888 888  888 
#  888        Y88..88P 888 d88P Y88b 888 888 d88P       888  .d88P 888 888  888 888 Y88..88P Y88b 888 
#  888         "Y88P"  88888P"   "Y88888 88888P"        8888888P"  888 "Y888888 888  "Y88P"   "Y88888 
#                      888               888                                                      888 
#                      888               888                                                 Y8b d88P 
#                      888               888                                                  "Y88P"  

# #######################
# Bring a popup window, asking for a parameter

function QuestionPupup()
{
    Param (
        [string] $PopupTitle = "",
        [string] $QuestionText = "",
        [string] $QuestionProposedResponse = "",
        [string] $ButtonOKText = "Ok",
        [string] $ButtonCancelText = "Close",
        [int] $SizeWidth = 300,
        [int] $SizeHeight = 200
    )

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = $PopupTitle
    $objForm.Size = New-Object System.Drawing.Size($SizeWidth, $SizeHeight)
    $objForm.StartPosition = "CenterParent"
    #$objForm.FormBorderStyle= "FixedDialog"
    $objForm.FormBorderStyle= "None"
    $objForm.BackColor=0xFF2E2E2E

    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") {$Script:LastQuestionPupupUserInput=$objTextBox.Text;$objForm.Close()}})
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$Script:LastQuestionPupupUserInput="";$objForm.Close()}})

    $objPanel = New-Object System.Windows.Forms.Panel
    $objPanel.Left=0
    $objPanel.Top=0
    $objPanel.Width=$SizeWidth
    $objPanel.Height=$SizeHeight
    $objPanel.BackColor=0xFF2E2E2E
    $objPanel.BorderStyle="FixedSingle"
    $objForm.Controls.Add($objPanel)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size($($SizeWidth - 180),$($SizeHeight - 40))
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = $ButtonOKText
    $OKButton.Add_Click({$Script:LastQuestionPupupUserInput=$objTextBox.Text;$objForm.Close()})
    $OKButton.FlatStyle="Flat"
    $OKButton.BackColor=0xFF4A4A4A
    $OKButton.ForeColor=0xFFCCCCCC
    $objPanel.Controls.Add($OKButton)

    $CANCELButton = New-Object System.Windows.Forms.Button
    $CANCELButton.Location = New-Object System.Drawing.Size($($SizeWidth - 100),$($SizeHeight - 40))
    $CANCELButton.Size = New-Object System.Drawing.Size(75,23)
    $CANCELButton.Text = $ButtonCancelText
    $CANCELButton.Add_Click({$Script:LastQuestionPupupUserInput="";$objForm.Close()})
    $CANCELButton.BackColor=0xFF4A4A4A
    $CANCELButton.ForeColor=0xFFCCCCCC
    $CANCELButton.FlatStyle="Flat"
    $objPanel.Controls.Add($CANCELButton)

    $objTitle = New-Object System.Windows.Forms.Label
    $objTitle.Location = New-Object System.Drawing.Size(0,0)
    $objTitle.Size = New-Object System.Drawing.Size($($SizeWidth),20)
    $objTitle.Text = $PopupTitle
    $objTitle.BackColor=0xFF101010
    $objTitle.ForeColor=0xFFCCCCCC
    $objTitle.Padding="4,3,0,0"
    $objPanel.Controls.Add($objTitle)

    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,40)
    $objLabel.Size = New-Object System.Drawing.Size($($SizeWidth - 20),20)
    $objLabel.Text = $QuestionText
    $objLabel.ForeColor=0xFFCCCCCC
    $objPanel.Controls.Add($objLabel)

    $objTextBox = New-Object System.Windows.Forms.TextBox
    $objTextBox.Location = New-Object System.Drawing.Size(10,60)
    $objTextBox.Size = New-Object System.Drawing.Size($($SizeWidth - 40),20)
    $objTextBox.ForeColor=0xFF989898
    $objTextBox.BackColor=0xFF1F2121
    $objTextBox.BorderStyle="FixedSingle"
    $objTextBox.Text=$QuestionProposedResponse
    $objPanel.Controls.Add($objTextBox)

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objTextBox.Select()})

    [void] $objForm.ShowDialog()

    return $LastQuestionPupupUserInput
}


#   .d8888b.  888                     888    d8b                   
#  d88P  Y88b 888                     888    Y8P                   
#  Y88b.      888                     888                          
#   "Y888b.   888888  8888b.  888d888 888888 888 88888b.   .d88b.  
#      "Y88b. 888        "88b 888P"   888    888 888 "88b d88P"88b 
#        "888 888    .d888888 888     888    888 888  888 888  888 
#  Y88b  d88P Y88b.  888  888 888     Y88b.  888 888  888 Y88b 888 
#   "Y8888P"   "Y888 "Y888888 888      "Y888 888 888  888  "Y88888 
#                                                              888 
#                                                         Y8b d88P 
#                                                          "Y88P"  

# Starting SmartResponse Plug-In Editor
LogInfo "Starting Open-Collector Helper"
LogInfo ("Version: " + $Version)


#  8888888b.                         888        .d8888b.                     .d888 d8b          
#  888   Y88b                        888       d88P  Y88b                   d88P"  Y8P          
#  888    888                        888       888    888                   888                 
#  888   d88P  .d88b.   8888b.   .d88888       888         .d88b.  88888b.  888888 888  .d88b.  
#  8888888P"  d8P  Y8b     "88b d88" 888       888        d88""88b 888 "88b 888    888 d88P"88b 
#  888 T88b   88888888 .d888888 888  888       888    888 888  888 888  888 888    888 888  888 
#  888  T88b  Y8b.     888  888 Y88b 888       Y88b  d88P Y88..88P 888  888 888    888 Y88b 888 
#  888   T88b  "Y8888  "Y888888  "Y88888        "Y8888P"   "Y88P"  888  888 888    888  "Y88888 
#                                                                                           888 
#                                                                                      Y8b d88P 
#                                                                                       "Y88P"  

# Reading config file
if (-Not (Test-Path $configFile))
{
	LogInfo "File 'config.json' doesn't exists."
}
else
{
    LogInfo "File 'config.json' exists."

    try
    {
	    $configJson = Get-Content -Raw -Path $configFile | ConvertFrom-Json
	    ForEach ($attribute in @("DocType")) {
		    if (-Not (Get-Member -inputobject $configJson -name $attribute -Membertype Properties) -Or [string]::IsNullOrEmpty($configJson.$attribute))
		    {
			    LogError ($attribute + " has not been specified in 'config.json' file.")
		    }
	    }
        LogInfo "File 'config.json' parsed correctly."
    }
    catch
    {
	    LogError "Could not parse 'config.json' file. Exiting"
	    return
    }
}


#   .d8888b.                                    .d8888b.                     .d888 d8b          
#  d88P  Y88b                                  d88P  Y88b                   d88P"  Y8P          
#  Y88b.                                       888    888                   888                 
#   "Y888b.    8888b.  888  888  .d88b.        888         .d88b.  88888b.  888888 888  .d88b.  
#      "Y88b.     "88b 888  888 d8P  Y8b       888        d88""88b 888 "88b 888    888 d88P"88b 
#        "888 .d888888 Y88  88P 88888888       888    888 888  888 888  888 888    888 888  888 
#  Y88b  d88P 888  888  Y8bd8P  Y8b.           Y88b  d88P Y88..88P 888  888 888    888 Y88b 888 
#   "Y8888P"  "Y888888   Y88P    "Y8888         "Y8888P"   "Y88P"  888  888 888    888  "Y88888 
#                                                                                           888 
#                                                                                      Y8b d88P 
#                                                                                       "Y88P"  

$DidWeEverConnect=$false

function SaveConfigXML 
{
    $configJson = @{"DocType" = "Main Configuration File"
                    ; "LastUpdateTime" = (Get-Date).ToString($TimeStampFormatForJSON)
                    ; "SavedConnection" =
                        @{"Host" = $script:configJson.SavedConnection.Host
                        ; "Port" = $script:configJson.SavedConnection.Port
                        ; "UserName" = $script:configJson.SavedConnection.UserName
                        ; "Password" = $script:configJson.SavedConnection.Password
                        ; "Proxy" = 
                            @{"Host" = $script:configJson.SavedConnection.Proxy.Host
                            ; "Port" = $script:configJson.SavedConnection.Proxy.Port
                            ; "Type" = $script:configJson.SavedConnection.Proxy.Type
                            }
                        }
                   }
    $configJson.LastUpdateTime=(Get-Date).ToString($TimeStampFormatForJSON)

    if ($script:DidWeEverConnect)
    {
        if ($cbLoginRememberHost.IsChecked) { $configJson.SavedConnection.Host = $tbLoginHost.Text }
        if ($cbLoginOptionsSSHPort.IsChecked) { $configJson.SavedConnection.Port = $tbLoginOptionsSSHPort.Text }
        if ($cbLoginRememberUserName.IsChecked) { $configJson.SavedConnection.UserName = $tbLoginUserName.Text }
        if ($cbLoginRememberPassword.IsChecked) { $configJson.SavedConnection.Password = $tbLoginPassword.Password } ## XXXXX Need to change this to Credentials
        if ($cbLoginOptionsProxyRememberHost.IsChecked) { $configJson.SavedConnection.Proxy.Host = $tbLoginOptionsProxyHost.Text }
        if ($cbLoginOptionsProxyRememberPort.IsChecked) { $configJson.SavedConnection.Proxy.Port = $tbLoginOptionsProxyPort.Text }
        if ($cbLoginOptionsProxyRememberType.IsChecked) { $configJson.SavedConnection.Proxy.Type = $tbLoginOptionsProxyType.Text }
        if ($cbLoginOptionsProxyRememberUserName.IsChecked) { $configJson.SavedConnection.Proxy.UserName = $tbLoginOptionsProxyUserName.Text }
        if ($cbLoginOptionsProxyRememberPassword.IsChecked) { $configJson.SavedConnection.Proxy.Password = $tbLoginOptionsProxyPassword.Password } ## XXXXX Need to change this to Credentials
    }
    LogInfo "Saving to 'config.json' file..."
    if (-Not (Test-Path $configFile))
    {
        LogInfo "File 'config.json' doesn't exist. Creating it."
	    New-Item $script:configFile -type file | out-null
    }
    # Write the Config into the Config file
    $configJson | ConvertTo-Json | Out-File -FilePath $script:configFile     
    LogInfo "Configuration saved."

    # Shift the local variable data to the global one
    $script:configJson = $configJson
}

#  8888888b.                         888       Y88b   d88P        d8888 888b     d888 888      
#  888   Y88b                        888        Y88b d88P        d88888 8888b   d8888 888      
#  888    888                        888         Y88o88P        d88P888 88888b.d88888 888      
#  888   d88P  .d88b.   8888b.   .d88888          Y888P        d88P 888 888Y88888P888 888      
#  8888888P"  d8P  Y8b     "88b d88" 888          d888b       d88P  888 888 Y888P 888 888      
#  888 T88b   88888888 .d888888 888  888         d88888b     d88P   888 888  Y8P  888 888      
#  888  T88b  Y8b.     888  888 Y88b 888        d88P Y88b   d8888888888 888   "   888 888      
#  888   T88b  "Y8888  "Y888888  "Y88888       d88P   Y88b d88P     888 888       888 88888888 
#                                                                                              
#                                                                                              
#                                                                                              

# #################
# Reading XAML file
$XAMLFile = "OpenCollector-UI\OC_UI.xaml"

if (Test-Path $XAMLFile)
{
    LogInfo ("File '{0}' exists." -f $XAMLFile)

    try
    {
        LogInfo ("Loading '{0}'..." -f $XAMLFile)
	    [string]$stXAML = Get-Content -Raw -Path $XAMLFile
        LogInfo "Loaded."
    }
    catch
    {
	    LogError ("Could not load '{0}' file. Exiting" -f $XAMLFile)
	    return
    }

}
else 
{
	LogInfo ("External UI definition file '{0}' doesn't exists. Loading from internal description instead." -f $XAMLFile)

# ##########
# "$OC_UIv1_0" extracted on 2019-09-04 14:47:13 from "OC_UI-v1.0.xaml".
# Sanitised                          : False
# Raw XAML Size                      : 526647 bytes
# Compressed XAML Size               : 76153 bytes (saving: 450494 bytes)
# Base64 Encoded Compressed XAML Size: 101540 bytes (saving: 425107 bytes)

$OC_UIv1_0 = "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"

$stXAML = Get-Base64DecodedDecompressedXML -Base64EncodedCompressedXML $OC_UIv1_0

}

##########
# Sanitise the XAML produced by Visual Studio
$stXAML = $stXAML -replace 'x:Class="[^"]*"'," "
$stXAML = $stXAML -replace 'mc:Ignorable="d"',""
#$stXAML = $stXAML -replace 'x:Name="([^"]*)"','x:Name="$1" Name="$1"'  # Turns out, this cause a lot of troubles :D Getting rid of it :)
$stXAML = $stXAML -replace 'x:Name="([^"]*)"','Name="$1"'
$stXAML = $stXAML -replace '%VERSIONNUMBER%',$VersionNumber
$stXAML = $stXAML -replace '%VERSIONDATE%',$VersionDate
$stXAML = $stXAML -replace '%VERSIONAUTHOR%',$VersionAuthor
         
#########
# Pass the String into an XML
try
{
    LogInfo ("Formatting UI..." -f $XAMLFile)
    [xml]$XAML = $stXAML
    LogInfo "Formatted."
}
catch
{
	LogError ("Failed to format and load the UI design into XML ""{0}"". Exiting" -f $stXAML)
	return
}

###########
# Read XAML
#[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
$reader=(New-Object System.Xml.XmlNodeReader $XAML) 
try
{
    $OCUIForm=[Windows.Markup.XamlReader]::Load( $reader )
}
catch
{
    LogError ("Unable to load Windows.Markup.XamlReader for ConfigReader.MainWindow. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered. Exception: {0}" -f $_.Exception.Message)
    exit
}


##################################
# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $OCUIForm.FindName($_.Name)}


#  8888888b.                                                            888     888 8888888 
#  888   Y88b                                                           888     888   888   
#  888    888                                                           888     888   888   
#  888   d88P 888d888  .d88b.  88888b.   8888b.  888d888  .d88b.        888     888   888   
#  8888888P"  888P"   d8P  Y8b 888 "88b     "88b 888P"   d8P  Y8b       888     888   888   
#  888        888     88888888 888  888 .d888888 888     88888888       888     888   888   
#  888        888     Y8b.     888 d88P 888  888 888     Y8b.           Y88b. .d88P   888   
#  888        888      "Y8888  88888P"  "Y888888 888      "Y8888         "Y88888P"  8888888 
#                              888                                                          
#                              888                                                          
#                              888                                                          


##############################
# Hide the Tabs of my TabItems
ForEach ($TabItem in $tcTabs.Items) {
    $TabItem.Visibility="Hidden"
}


##############################
# Disable the Items of lvStep
ForEach ($lvItem in $lvStep.Items) {
    $lvItem.IsEnabled=$false
}


#  888b    888                   d8b                   888    d8b                   
#  8888b   888                   Y8P                   888    Y8P                   
#  88888b  888                                         888                          
#  888Y88b 888  8888b.  888  888 888  .d88b.   8888b.  888888 888  .d88b.  88888b.  
#  888 Y88b888     "88b 888  888 888 d88P"88b     "88b 888    888 d88""88b 888 "88b 
#  888  Y88888 .d888888 Y88  88P 888 888  888 .d888888 888    888 888  888 888  888 
#  888   Y8888 888  888  Y8bd8P  888 Y88b 888 888  888 Y88b.  888 Y88..88P 888  888 
#  888    Y888 "Y888888   Y88P   888  "Y88888 "Y888888  "Y888 888  "Y88P"  888  888 
#                                         888                                       
#                                    Y8b d88P                                       
#                                     "Y88P"                                        

############
# Navigation

# The Navigation tree on the left of the window
$lvStep.Add_SelectionChanged({

    if ($lvStep.Items.Count -gt 0)
    {
        # Move the right tab
        ($tcTabs.Items | where {$_.Header -eq $lvStep.Items[$lvStep.SelectedIndex].Tag}).IsSelected = $true
    
        # Update connection status
        if ($script:SSHSession.Connected -eq $true)
        {
            $IconConnectionDisconnected.Visibility = "Hidden"
            $IconConnectionConnected.Visibility = "Visible"
        }
        else
        {
            $IconConnectionConnected.Visibility = "Hidden"
            $IconConnectionDisconnected.Visibility = "Visible"
        }

        # Check if we are entering a tab that requires refresh
        # If we are, fill the screen with the relevant data
        switch -wildcard ($lvStep.Items[$lvStep.SelectedIndex].Tag) {
            "Welcome"
            {
                try
                {
                    # 
                }
                catch
                {
                    LogError ("Failed to update {1} UI. Exception: {0}." -f $_.Exception.Message, $lvStep.Items[$lvStep.SelectedIndex].Tag)
                }
                break
            }
            "Login"
            {
                try
                {
                    # Bring stuff from the config
                    $tbLoginHost.Text = $configJson.SavedConnection.Host
                    $tbLoginOptionsSSHPort.Text = $configJson.SavedConnection.Port
                    if ($tbLoginOptionsSSHPort.Text.Length -eq 0)
                    {
                        $tbLoginOptionsSSHPort.Text = "22"
                    }
                    $tbLoginUserName.Text = $configJson.SavedConnection.UserName
                    $tbLoginPassword.Password = $configJson.SavedConnection.Password
                    $tbLoginOptionsProxyHost.Text = $configJson.SavedConnection.Proxy.Host
                    $tbLoginOptionsProxyPort.Text = $configJson.SavedConnection.Proxy.Port
                    $tbLoginOptionsProxyType.Text = $configJson.SavedConnection.Proxy.Type
                    $tbLoginOptionsProxyUserName.Text = $configJson.SavedConnection.Proxy.UserName
                    $tbLoginOptionsProxyPassword.Password = $configJson.SavedConnection.Proxy.Password
                }
                catch
                {
                    LogError ("Failed to update {1} UI. Exception: {0}." -f $_.Exception.Message, $lvStep.Items[$lvStep.SelectedIndex].Tag)
                }
                break
            }
            "Status"
            {
                try
                {
                    #
                } # try
                catch
                {
                    LogError ("Failed to update {1} UI. Exception: {0}." -f $_.Exception.Message, $lvStep.Items[$lvStep.SelectedIndex].Tag)
                }
                break
            }
            "Installation"
            {
                try
                {
                    # 
                }
                catch
                {
                    LogError ("Failed to update {1} UI. Exception: {0}." -f $_.Exception.Message, $lvStep.Items[$lvStep.SelectedIndex].Tag)
                }
                break
            }
            "Pipelines"
            {
                try
                {
                    # 
                    # If there is nothing loaded yet in the list of Pipeline Projects, load it from the Open-Collector
                    if ($dgPipelinesProjectList.Items.Count -le 0)
                    {
                        GetOpenCollectorPipelineProjects
                    }
                }
                catch
                {
                    LogError ("Failed to update {1} UI. Exception: {0}." -f $_.Exception.Message, $lvStep.Items[$lvStep.SelectedIndex].Tag)
                }
                break
            }
            default 
            {

                break
            }
        }                


    }
})


#  8888888888 d8b 888                 .d8888b.           8888888b.  d8b                           888                                     .d88888b.                             
#  888        Y8P 888                d88P  "88b          888  "Y88b Y8P                           888                                    d88P" "Y88b                            
#  888            888                Y88b. d88P          888    888                               888                                    888     888                            
#  8888888    888 888  .d88b.         "Y8888P"           888    888 888 888d888  .d88b.   .d8888b 888888  .d88b.  888d888 888  888       888     888 88888b.   .d88b.  88888b.  
#  888        888 888 d8P  Y8b       .d88P88K.d88P       888    888 888 888P"   d8P  Y8b d88P"    888    d88""88b 888P"   888  888       888     888 888 "88b d8P  Y8b 888 "88b 
#  888        888 888 88888888       888"  Y888P"        888    888 888 888     88888888 888      888    888  888 888     888  888       888     888 888  888 88888888 888  888 
#  888        888 888 Y8b.           Y88b .d8888b        888  .d88P 888 888     Y8b.     Y88b.    Y88b.  Y88..88P 888     Y88b 888       Y88b. .d88P 888 d88P Y8b.     888  888 
#  888        888 888  "Y8888         "Y8888P" Y88b      8888888P"  888 888      "Y8888   "Y8888P  "Y888  "Y88P"  888      "Y88888        "Y88888P"  88888P"   "Y8888  888  888 
#                                                                                                                              888                   888                        
#                                                                                                                         Y8b d88P                   888                        
#                                                                                                                          "Y88P"                    888                        

# Function to Browse for a folder
Function Get-DirectoryName()
{   
    param
    (
        [string] $InitialDirectory = "",
        [string] $Description = $null,
        [Switch] $ShowNewFolderButton = $False
    )
    try
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

        $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $OpenFolderDialog.ShowNewFolderButton = $ShowNewFolderButton
        $OpenFolderDialog.SelectedPath = $InitialDirectory
        $OpenFolderDialog.Description = $Description
        $DialogResult = $OpenFolderDialog.ShowDialog() #| Out-Null
        if ($DialogResult -eq "OK")
        {
            return $OpenFolderDialog.SelectedPath
        }
        else
        {
            return $null
        }
    }
    catch
    {
        LogError "Impossible to browse for directory."
        return $null
    }
}

# Function to Browse for a file
Function Get-FileName()
{   
    param
    (
        [string] $Filter = "All files (*.*)| *.*",
        [string] $InitialDirectory = "",
        [string] $Title = "",
        [string] $FileName = "",
        [Switch] $CheckFileExists = $false,
        [Switch] $ReadOnlyChecked = $false,
        [Switch] $ShowReadOnly = $false,
        [Switch] $Multiselect = $false
    )
    try
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $InitialDirectory
        $OpenFileDialog.filter = $Filter
        $OpenFileDialog.CheckFileExists = $CheckFileExists
        $OpenFileDialog.ReadOnlyChecked = $ReadOnlyChecked
        $OpenFileDialog.ShowReadOnly = $ShowReadOnly
        $OpenFileDialog.Multiselect = $Multiselect
        $OpenFileDialog.Title = $Title
        if ($FileName.Length -gt 0) { $OpenFileDialog.FileName = $FileName }
        $OpenFileDialog.ShowDialog() | Out-Null
        return $OpenFileDialog.filename
    }
    catch
    {
        LogError "Impossible to browse for files."
        return $null
    }
}

# Function to Browse for a file to Save
Function Set-FileName()
{   
    param
    (
        [string] $Filter = "All files (*.*)| *.*",
        [string] $InitialDirectory = "",
        [string] $Title = "",
        [string] $FileName = "",
        [Switch] $CheckFileExists = $false,
        [Switch] $ReadOnlyChecked = $false,
        [Switch] $ShowReadOnly = $false,
        [Switch] $Multiselect = $false,
        [Switch] $CreatePrompt = $false,
        [Switch] $OverwritePrompt = $false,
        [Switch] $ValidateNames = $false
    )
    try
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

        $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $SaveFileDialog.initialDirectory = $InitialDirectory
        $SaveFileDialog.filter = $Filter
        $SaveFileDialog.CheckFileExists = $CheckFileExists
        $SaveFileDialog.Title = $Title
        $SaveFileDialog.CreatePrompt = $CreatePrompt
        $SaveFileDialog.OverwritePrompt = $OverwritePrompt
        $SaveFileDialog.ValidateNames = $ValidateNames
        if ($FileName.Length -gt 0) { $SaveFileDialog.FileName = $FileName }
        $DialogResult = $SaveFileDialog.ShowDialog() #| Out-Null
        if ($DialogResult -eq "OK")
        {
            return $SaveFileDialog.filename
        }
        else
        {
            return $null
        }
    }
    catch
    {
        LogError "Impossible to browse for files."
        return $null
    }
}


#  88888888888                   888    888888b.                                             888 d8b      888          888    d8b                   
#      888                       888    888  "88b                                            888 Y8P      888          888    Y8P                   
#      888                       888    888  .88P                                            888          888          888                          
#      888      .d88b.  888  888 888888 8888888K.   .d88b.  888  888       888  888  8888b.  888 888  .d88888  8888b.  888888 888  .d88b.  88888b.  
#      888     d8P  Y8b `Y8bd8P' 888    888  "Y88b d88""88b `Y8bd8P'       888  888     "88b 888 888 d88" 888     "88b 888    888 d88""88b 888 "88b 
#      888     88888888   X88K   888    888    888 888  888   X88K         Y88  88P .d888888 888 888 888  888 .d888888 888    888 888  888 888  888 
#      888     Y8b.     .d8""8b. Y88b.  888   d88P Y88..88P .d8""8b.        Y8bd8P  888  888 888 888 Y88b 888 888  888 Y88b.  888 Y88..88P 888  888 
#      888      "Y8888  888  888  "Y888 8888888P"   "Y88P"  888  888         Y88P   "Y888888 888 888  "Y88888 "Y888888  "Y888 888  "Y88P"  888  888 
#                                                                                                                                                   
#                                                                                                                                                   
#                                                                                                                                                   

# Setting up the TextBox validation function

[System.Windows.RoutedEventHandler]$textChangedHandler = {
			
    try
    {
        $TextBoxTag = $_.OriginalSource.Tag
        if ($TextBoxTag -match '^ValidIf__(.*)')
        {
            if ($matches.Count -gt 0)
            {
                #LogDebug $matches[1]
                $TextBoxValidated = $false
                $TextBoxText = $_.OriginalSource.Text # Doing this as using $_.OriginalSource.Text in the Switch seems to provide weird results...

                switch -wildcard ($matches[1]) {
                   "NotEmpty"
                   {
                       if (-not ([string]::IsNullOrEmpty($TextBoxText))) { $TextBoxValidated = $true }
                       break
                   }
                   "Empty"
                   {
                       if ([string]::IsNullOrEmpty($TextBoxText)) { $TextBoxValidated = $true }
                       break
                   }
                   "RegEx:*"
                   {
                       $PatternAreYouThere = ($matches[1] -match 'RegEx:(.*)')
                       $Pattern = $matches[1]
                       #LogDebug $Pattern
                       if ($TextBoxText -match $Pattern) { $TextBoxValidated = $true }
                       break
                   }
                   default 
                   {
                       LogDebug ("Validation method un-supported for this TextBox ({0})" -f $matches[1])
                       break
                   }
                }                

                #LogInfo $TextBoxValidated
                if ($TextBoxValidated)
                {  # Valid
                    (([Windows.Media.VisualTreeHelper]::GetParent($_.OriginalSource)).Children | Where-Object {$_ -is [System.Windows.Shapes.Rectangle] }).Fill="#FF007BC2"
                }
                else
                {  # Not valid
                    (([Windows.Media.VisualTreeHelper]::GetParent($_.OriginalSource)).Children | Where-Object {$_ -is [System.Windows.Shapes.Rectangle] }).Fill="Red"
                }
            }
        }
    }
    catch
    {
        LogError "TextBox validation failed."
    }
}

$OCUIForm.AddHandler([System.Windows.Controls.TextBox]::TextChangedEvent, $textChangedHandler)


#  8888888b.                    888        888    d8b                              888     888 8888888                              888          888             
#  888   Y88b                   888        888    Y8P                              888     888   888                                888          888             
#  888    888                   888        888                                     888     888   888                                888          888             
#  888   d88P  .d88b.   8888b.  888        888888 888 88888b.d88b.   .d88b.        888     888   888         888  888 88888b.   .d88888  8888b.  888888  .d88b.  
#  8888888P"  d8P  Y8b     "88b 888        888    888 888 "888 "88b d8P  Y8b       888     888   888         888  888 888 "88b d88" 888     "88b 888    d8P  Y8b 
#  888 T88b   88888888 .d888888 888 888888 888    888 888  888  888 88888888       888     888   888         888  888 888  888 888  888 .d888888 888    88888888 
#  888  T88b  Y8b.     888  888 888        Y88b.  888 888  888  888 Y8b.           Y88b. .d88P   888         Y88b 888 888 d88P Y88b 888 888  888 Y88b.  Y8b.     
#  888   T88b  "Y8888  "Y888888 888         "Y888 888 888  888  888  "Y8888         "Y88888P"  8888888        "Y88888 88888P"   "Y88888 "Y888888  "Y888  "Y8888  
#                                                                                                                     888                                        
#                                                                                                                     888                                        
#                                                                                                                     888                                        


# ###########################################
# Update the Content of a Label in real-time
function UIDispacherInvokeUpdateLabelContent()
{
    param
    (
		[Parameter(Mandatory)]
        [System.Windows.Controls.ContentControl] $LabelToUpdate,
        [string] $NewContent = ""
    )

    try
    {
        # Do it twice, as once seems not to update it... (it would get updated at the next call)
        $OCUIForm.Dispatcher.Invoke([action]{$LabelToUpdate.Content = $NewContent},"Render")
        $OCUIForm.Dispatcher.Invoke([action]{$LabelToUpdate.Content = $NewContent},"Render")
    }
    catch
    {
        LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
        $LabelToUpdate.Content = $NewContent
    }
}

# ###########################################
# Update the IsChecked of a Checkbox an RadioButton in real-time
function UIDispacherInvokeUpdateIsChecked()
{
    param
    (
		[Parameter(Mandatory)]
        [System.Windows.Controls.Primitives.ToggleButton] $ComponentToUpdate,
        [bool] $NewValue = $true
    )

    try
    {
        $OCUIForm.Dispatcher.Invoke([action]{$ComponentToUpdate.IsChecked = $NewValue},"Render")
        $OCUIForm.Dispatcher.Invoke([action]{$ComponentToUpdate.IsChecked = $NewValue},"Render")
    }
    catch
    {
        LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
        $ComponentToUpdate.IsChecked = $NewValue
    }
}

#  888    888 d8b          888            888                                 888       888888b.   d8b               888 d8b                            
#  888    888 Y8P          888            888                                 888       888  "88b  Y8P               888 Y8P                            
#  888    888              888            888                                 888       888  .88P                    888                                
#  8888888888 888  .d88b.  88888b.        888       .d88b.  888  888  .d88b.  888       8888888K.  888 88888b.   .d88888 888 88888b.   .d88b.  .d8888b  
#  888    888 888 d88P"88b 888 "88b       888      d8P  Y8b 888  888 d8P  Y8b 888       888  "Y88b 888 888 "88b d88" 888 888 888 "88b d88P"88b 88K      
#  888    888 888 888  888 888  888       888      88888888 Y88  88P 88888888 888       888    888 888 888  888 888  888 888 888  888 888  888 "Y8888b. 
#  888    888 888 Y88b 888 888  888       888      Y8b.      Y8bd8P  Y8b.     888       888   d88P 888 888  888 Y88b 888 888 888  888 Y88b 888      X88 
#  888    888 888  "Y88888 888  888       88888888  "Y8888    Y88P    "Y8888  888       8888888P"  888 888  888  "Y88888 888 888  888  "Y88888  88888P' 
#                      888                                                                                                                 888          
#                 Y8b d88P                                                                                                            Y8b d88P          
#                  "Y88P"                                                                                                              "Y88P"           

#$dgTestTestsOrder.ItemsSource = $ProjectMemoryObject.Tests



#  888     888 8888888                    888       888          888                                                888             888      
#  888     888   888                      888   o   888          888                                                888             888      
#  888     888   888                      888  d8b  888          888                                                888             888      
#  888     888   888                      888 d888b 888  .d88b.  888  .d8888b  .d88b.  88888b.d88b.   .d88b.        888888  8888b.  88888b.  
#  888     888   888                      888d88888b888 d8P  Y8b 888 d88P"    d88""88b 888 "888 "88b d8P  Y8b       888        "88b 888 "88b 
#  888     888   888         888888       88888P Y88888 88888888 888 888      888  888 888  888  888 88888888       888    .d888888 888  888 
#  Y88b. .d88P   888                      8888P   Y8888 Y8b.     888 Y88b.    Y88..88P 888  888  888 Y8b.           Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888                    888P     Y888  "Y8888  888  "Y8888P  "Y88P"  888  888  888  "Y8888         "Y888 "Y888888 88888P"  
#                                                                                                                                            
#                                                                                                                                            
#                                                                                                                                            

function LoadCommunityWebSite()
{
    $LRCommunityURL='https://www.logrhythm.com'
    LogInfo ("Opening Community WebSite on default browser via ""{0}""" -f $LRCommunityURL)
    try
    {
        [Diagnostics.Process]::Start($LRCommunityURL,'arguments') | Out-Null
    }
    catch
    {
        LogError ("Failed. Exception: {0}." -f $_.Exception.Message)
    }
}

$tbWelcomeVisitCommunity.Add_MouseUp({
    LoadCommunityWebSite
})

$tbWelcomeVisitCommunity.Add_StylusUp({
    LoadCommunityWebSite
})

$tbWelcomeVisitCommunity.Add_TouchUp({
    LoadCommunityWebSite
})

$btWelcomeIAgree.Add_Click({
    ##############################
    # Disable the Items of lvStep
    ForEach ($lvItem in $lvStep.Items) {
        $lvItem.IsEnabled=$true
    }
    $lvStep.SelectedIndex = 1 # Login
})

$btWelcomeExit.Add_Click({
    $OCUIForm.Close()
})


#  888     888 8888888                    888                        d8b                888             888      
#  888     888   888                      888                        Y8P                888             888      
#  888     888   888                      888                                           888             888      
#  888     888   888                      888       .d88b.   .d88b.  888 88888b.        888888  8888b.  88888b.  
#  888     888   888                      888      d88""88b d88P"88b 888 888 "88b       888        "88b 888 "88b 
#  888     888   888         888888       888      888  888 888  888 888 888  888       888    .d888888 888  888 
#  Y88b. .d88P   888                      888      Y88..88P Y88b 888 888 888  888       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888                    88888888  "Y88P"   "Y88888 888 888  888        "Y888 "Y888888 88888P"  
#                                                                888                                             
#                                                           Y8b d88P                                             
#                                                            "Y88P"                                              

$btLoginConnect.Add_Click({
    if ((get-module PoSH-SSH -ListAvailable).Count -lt 1)
    {
        # The right module is not installed
        LogError "The SSH module for PowerShell is not yet installed on this computer."
        $MsgBoxResponse = [System.Windows.MessageBox]::Show("The SSH module for PowerShell is not yet installed on this computer.`n`nWould  you like to install it?`n`nNote: the installation requires to be done as Administrator.",'SSH Module','YesNo','Error')
        switch  ($MsgBoxResponse) {
          'Yes' {
            try
            {
                # Install it as Admin
                LogInfo "Installing the SSH module as Administrator."
                Start-Process powershell -Verb runAs "install-module PoSH-SSH"
            }
            catch
            {
                LogError ("The SSH module failed to install. Exception: {0}." -f $_.Exception.Message)
            }
          }
          'No' {
            LogError "The SSH module is required for this connection to work. Connection not established."
            [System.Windows.MessageBox]::Show("The SSH module is required for this connection to work.`n`nConnection not established.",'SSH Module','Ok','Information')
          }
        }
    }
    else
    {
        try
        {
            # ######################
            # Build the credentials

            # For the Open Collector Host
            $HostUser = $tbLoginUserName.Text
            if ($tbLoginPassword.Password.Length -gt 0)
            {
                $HostPass = convertto-securestring $tbLoginPassword.Password -asplaintext -force
            }
            else
            {
                $HostPass = (new-object System.Security.SecureString)
            }

            $HostCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $HostUser, $HostPass

            # For the Proxy
            if ($tbLoginOptionsProxyUserName.Text.Length -gt 0)
            {
                try
                {
                    $ProxyUser = $tbLoginOptionsProxyUserName.Text
                    if ($tbLoginOptionsProxyPassword.Password.Length -gt 0)
                    {
                        $ProxyPass = convertto-securestring $tbLoginOptionsProxyPassword.Password -asplaintext -force
                    }
                    else
                    {
                        $ProxyPass = (new-object System.Security.SecureString)
                    }
                    $ProxyCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $ProxyUser, $ProxyPass
                }
                catch
                {
                    $ProxyCredentials = $null
                    $ProxyUser = "" # This prevents the Proxy credentials to be provided to the connection
                    LogError ("Failed to process Proxy Credentials. Exception: {0}." -f $_.Exception.Message)
                    [System.Windows.MessageBox]::Show(("Failed to process Proxy Credentials.`n`nException: {0}." -f $_.Exception.Message),'SSH Connection','Ok','Error')
                }
            }

            # #######################
            # Connect

            $SSHConnectionTimeout=30

            if ($tbLoginOptionsProxyHost.Text.Length -eq 0)
            {
                # No proxy, direct connection
                $script:SSHSession = New-SSHSession -ComputerName $tbLoginHost.Text -Port $tbLoginOptionsSSHPort.Text.ToInt32($null) -Credential $HostCreds -KeepAliveInterval 100 -AcceptKey -ConnectionTimeout $SSHConnectionTimeout
            }
            else 
            {
                # There is a Proxy
                if ($tbLoginOptionsProxyUserName.Text.Length -gt 0)
                {
                    # There are some Proxy credentials
                    $script:SSHSession = New-SSHSession -ComputerName $tbLoginHost.Text -Port $tbLoginOptionsSSHPort.Text.ToInt32($null) -Credential $HostCreds -KeepAliveInterval 100 -AcceptKey -ProxyServer $tbLoginOptionsProxyHost.Text -ProxyPort $tbLoginOptionsProxyPort.Text.ToInt32($null) -ProxyType $tbLoginOptionsProxyType.Text -ProxyCredential $ProxyCredentials -ConnectionTimeout $SSHConnectionTimeout
                }
                else
                {
                    # No Proxy credentials
                    $script:SSHSession = New-SSHSession -ComputerName $tbLoginHost.Text -Port $tbLoginOptionsSSHPort.Text.ToInt32($null) -Credential $HostCreds -KeepAliveInterval 100 -AcceptKey -ProxyServer $tbLoginOptionsProxyHost.Text -ProxyPort $tbLoginOptionsProxyPort.Text.ToInt32($null) -ProxyType $tbLoginOptionsProxyType.Text -ConnectionTimeout $SSHConnectionTimeout
                }
            }
            if ($script:SSHSession.Connected)
            {
                LogInfo ("Connected to host ""{0}:{2}"" as user ""{1}"" over SSH." -f $tbLoginHost.Text, $HostUser, $tbLoginOptionsSSHPort.Text)
                $IconConnectionDisconnected.Visibility = "Hidden"
                $IconConnectionConnected.Visibility = "Visible"
                $btLoginConnect.IsEnabled = $false
                $btLoginDisconnect.IsEnabled = $true
                $script:DidWeEverConnect = $true
            }
            else
            {
                $script:DidWeEverConnect = $false
                LogError ("Failed to connect to host ""{0}:{2}"" as user ""{1}"" over SSH. Check host, username and password and try again." -f $tbLoginHost.Text, $HostUser, $tbLoginOptionsSSHPort.Text)
                [System.Windows.MessageBox]::Show(("Failed to connect to host ""{0}:{2}"" as user ""{1}"" over SSH.`n`nCheck Host, User Name and Password and try again." -f $tbLoginHost.Text, $HostUser, $tbLoginOptionsSSHPort.Text),'SSH Connection','Ok','Error')
            }

        }
        catch
        {
            LogError ("Failed to connect to host over SSH. Exception: {0}." -f $_.Exception.Message)
            [System.Windows.MessageBox]::Show(("Failed to connect to host over SSH.`n`nException: {0}." -f $_.Exception.Message),'SSH Connection','Ok','Error')
        }

    }
})

function SSHDisconnect()
{
    if ((get-module PoSH-SSH -ListAvailable).Count -lt 1)
    {
        # The right module is not installed
        LogError "The SSH module for PowerShell is not yet installed on this computer."
    }
    else
    {
        try
        {
            # #######################
            # Disconnect then clear up all connections

            LogInfo "Disconnect then clear up all SSH connections"

            $Sessions = Get-SSHSession
            foreach ($Session in $Sessions)
            {
                try
                {
                    $Session.Disconnect()
                    Remove-SSHSession -SSHSession $Session | Out-Null
                    LogInfo (" \-- Connection disconnected (Connection ID: {0}) from Host {1}." -f $Session.SessionId, $Session.Host)
                }
                catch
                {
                    LogError (" \-- Failed to disconnect (Connection ID: {1}) from Host {2}. Exception: {0}." -f $_.Exception.Message, $Session.SessionId, $Session.Host)
                }
            }
        }
        catch
        {
        }
    }
}



$btLoginDisconnect.Add_Click({
    if ((get-module PoSH-SSH -ListAvailable).Count -lt 1)
    {
        # The right module is not installed
        LogError "The SSH module for PowerShell is not yet installed on this computer."
    }
    else
    {
        try
        {
            SSHDisconnect
            $IconConnectionConnected.Visibility = "Hidden"
            $IconConnectionDisconnected.Visibility = "Visible"
            $btLoginConnect.IsEnabled = $true
            $btLoginDisconnect.IsEnabled = $false
            $script:SSHSession = $null
        }
        catch
        {
            LogError ("Failed to disconnect from Open-Collector. Exception: {0}." -f $_.Exception.Message)
        }

    }
})


#  888     888 8888888                     .d8888b.  888             888                            888             888      
#  888     888   888                      d88P  Y88b 888             888                            888             888      
#  888     888   888                      Y88b.      888             888                            888             888      
#  888     888   888                       "Y888b.   888888  8888b.  888888 888  888 .d8888b        888888  8888b.  88888b.  
#  888     888   888                          "Y88b. 888        "88b 888    888  888 88K            888        "88b 888 "88b 
#  888     888   888         888888             "888 888    .d888888 888    888  888 "Y8888b.       888    .d888888 888  888 
#  Y88b. .d88P   888                      Y88b  d88P Y88b.  888  888 Y88b.  Y88b 888      X88       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888                     "Y8888P"   "Y888 "Y888888  "Y888  "Y88888  88888P'        "Y888 "Y888888 88888P"  
#                                                                                                                            
#                                                                                                                            
#                                                                                                                            

function GetOpenCollectorInstalledPipeline
{
    # #########
    # Get the Open-Collector installed pipelines
    try
    {
        $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --ListInstalledPipelines") -TimeOut 20
    }
    catch
    {
        # Oopsy Daisy... Something went wrong
        LogError ("Failed to list the Installed Pipelines of ""Open-Collector"". Exception: {0}." -f $_.Exception.Message)
    }

    if ($SHHCommandReturn.ExitStatus -eq 0)
    {
        try
        {
            $Response = $SHHCommandReturn.Output | ConvertFrom-Json
            LogInfo ("Found {0} Installed Pipleines in Open-Collector." -f $Response.Count)
            # Clear the current list of Pipelines
            $dgPipelinesInstalledList.Items.Clear()
            # Add all the ones we got from OCHelper
            foreach ($InstalledPipeline in $Response)
            {
                # Create a new blank Pipeline entry
                $NewPipelineItem = Select-Object -inputobject "" Name,Status,Enabled
                LogInfo (" \-- Found Pipeline named ""{0}"", with enabled status: ""{1}""." -f $InstalledPipeline.PipelineName, $InstalledPipeline.Enabled)
                
                # CHeck the Status
                if ($InstalledPipeline.Enabled -eq "true")
                {
                    $NewPipelineItem.Status = "Enabled"
                    $NewPipelineItem.Enabled = $true
                }
                else
                {
                    $NewPipelineItem.Status = "Disabled"
                    $NewPipelineItem.Enabled = $false
                }
                                    
                # We might decide later to translate the full pipeline name into a shorter one. For now, I just keep as is.
                $NewPipelineItem.Name = $InstalledPipeline.PipelineName

                # Add to the table
                $dgPipelinesInstalledList.Items.Add($NewPipelineItem)
            }
        }
        catch
        {
            LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
        }
    }
}

$btStatusInstalledPipelinesRefresh.Add_Click({
    # Refresh the Installed Pipeline list
    GetOpenCollectorInstalledPipeline
})

function CheckOCHelperPresence
{
    # #########
    # Check for the presense of OCHelper.sh

    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("ls ./OCHelper.sh") -TimeOut 2
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for the presense of ""OCHelper.sh"". Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            #$rbStatusOCHelperInstalled.IsChecked = $true
            LogInfo """OCHelper.sh"" presence: true."
            UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusOCHelperInstalled -NewValue $true
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOCHelperStatus -NewContent "A copy of OCHelper.sh exist on this server."
        }
        else
        {
            #$rbStatusOCHelperMissing.IsChecked = $true
            LogInfo """OCHelper.sh"" presence: false."
            UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusOCHelperMissing -NewValue $true
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOCHelperStatus -NewContent "No OCHelper.sh exist on this server."
        }
    } # if ($script:SSHSession.Connected)
}

function CheckOCHelperVersion
{
    # #########
    # Check for the version of OCHelper.sh

    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckOCHelperVersion") -TimeOut 5
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for the version of ""OCHelper.sh"". Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            LogInfo ("""OCHelper.sh"" Version: {0}." -f $SHHCommandReturn.Output)
            $OCHelperVersion=$SHHCommandReturn.Output
            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                $OCHelperVersion = $Response.version.Full
            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbStatusOCHelperVersion -NewContent $OCHelperVersion
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOCHelperStatus -NewContent ("A copy of OCHelper.sh exist on this server. Version: {0}" -f $OCHelperVersion)
        }
        else
        {
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbStatusOCHelperVersion -NewContent "** Unknown **"
        }

    } # if ($script:SSHSession.Connected)
}

function CheckDockerPresence
{
    # #########
    # Check for the presense of Docker

    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckDockerPresence") -TimeOut 2
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for the presense of ""Docker"". Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            $rbStatusDockerInstalled.IsChecked = $true
            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                LogInfo ("Docker presence: {0}." -f $Response.Presence)
            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
            if ($Response.Presence.ToLower() -ne "true")
            {
                #$rbStatusDockerNone.IsChecked = $true
                UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusDockerNone -NewValue $true
                UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedDockerStatus -NewContent "Docker has been found on this server."
            }
        }
        else
        {
            #$rbStatusDockerNone.IsChecked = $true
            UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusDockerNone -NewValue $true
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedDockerStatus -NewContent "No Docker has been found on this server."
        }
    } # if ($script:SSHSession.Connected)
}

function CheckDockerVersion
{
    # #########
    # Check for the version of Docker

    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckDockerVersion") -TimeOut 5
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for the version of ""Docker"". Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            #$rbStatusDockerRunning.IsChecked = $true
            try
            {
                $OCUIForm.Dispatcher.Invoke([action]{$rbStatusDockerRunning.IsChecked = $true},"Render")
            }
            catch
            {
                LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
                $rbStatusDockerRunning.IsChecked = $true
            }

            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                LogInfo ("Docker version {0}." -f $Response.Version.Full)
                #$lbStatusDockerVersion.Content = $Response.Version.Full
                UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbStatusDockerVersion -NewContent $Response.Version.Full
                UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedDockerStatus -NewContent ("Docker has been found on this server. Version: {0}" -f $Response.Version.Full)
            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
        }
    } # if ($script:SSHSession.Connected)
}

function CheckOpenCollectorPresence
{
    # #########
    # Check for the presense of Open-Collector

    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckOCPresence") -TimeOut 10
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for the presense of ""Open-Collector"". Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            #$rbStatusOpenCollectorInstalled.IsChecked = $true
            UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusOpenCollectorInstalled -NewValue $true
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent "Open-Collector has been found on this server."
            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                LogInfo ("Open-Collector presence: {0}." -f $Response.Presence)
            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
            if ($Response.Presence.ToLower() -ne "true")
            {
                #$rbStatusOpenCollectorNone.IsChecked = $true
                UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusOpenCollectorNone -NewValue $true
                UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent "No Open-Collector has been found on this server."
            }
        }
        else
        {
            #$rbStatusOpenCollectorNone.IsChecked = $true
            UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusOpenCollectorNone -NewValue $true
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent "No Open-Collector has been found on this server."
        }
    } # if ($script:SSHSession.Connected)
}

function CheckOpenCollectorVersion
{
    # #########
    # Check for the version of Open-Collector

    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckOCVersion") -TimeOut 10
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for the version of ""Open-Collector"". Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                LogInfo ("Open-Collector version {0}." -f $Response.Version.Full)
                #$lbStatusOpenCollectorVersion.Content = $Response.Version.Full
                UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbStatusOpenCollectorVersion -NewContent $Response.Version.Full
                UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent ("Open-Collector has been found on this server. Version: {0}" -f $Response.Version.Full)
            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
        }
    } # if ($script:SSHSession.Connected)
}

function CheckOpenCollectorHealth
{
    # #########
    # Check for the Health of Open-Collector

    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckOCHealth") -TimeOut 10
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for the health of ""Open-Collector"". Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                LogInfo ("Open-Collector health status ""{0}""." -f $Response.Health)
                If ($Response.Health.ToLower() -eq "up")
                {
                    #$rbStatusOpenCollectorRunning.IsChecked = $true
                    UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusOpenCollectorRunning -NewValue $true
                }
                else
                {
                    LogInfo ("Health of ""Open-Collector"" is set to ""{0}""." -f $Response.Health)
                }
                UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent ("Open-Collector has been found on this server. Health: {0}" -f $Response.Health)
            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
        }
        else
        {
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent "No Open-Collector has been found on this server."
        }
    } # if ($script:SSHSession.Connected)
}

function RefreshStatusTab
{
    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        # ####################
        # Refresh the statuses

        # Check for the presense of OCHelper.sh
        CheckOCHelperPresence

        # Check for the version of OCHelper.sh
        CheckOCHelperVersion

        # Check for the presense of Docker
        CheckDockerPresence

        # #########
        # Check for the version of Docker
        CheckDockerVersion

        # Check for the presense of the Open-Collector
        CheckOpenCollectorPresence

        # Check for the version of Open-Collector
        CheckOpenCollectorVersion

        # Check for the health of Open-Collector
        CheckOpenCollectorHealth

        # #########
        # Check for Internet connectivity
        CheckInternetConnectivity

        # #########
        # Get the Open-Collector installed pipelines
        GetOpenCollectorInstalledPipeline

    } # if ($script:SSHSession.Connected)
}

function CheckInternetConnectivity
{
    # #########
    # Check for Internet connectivity

    $DomainsReached=0
    $DomainsChecked=0

    # Are we connected to the Open-Collector?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckInternetConnectivity") -TimeOut 30
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for Internet connectivity. Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                LogInfo ("Open-Collector Internet connectivity: ""{0}""." -f $Response.Result)
                If ($Response.Result.ToLower() -match "Full Internet Connectivity")
                {
                    UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusInternetConnectivityConnected -NewValue $true
                }
                elseIf ($Response.Result.ToLower() -match "Partial Internet Connectivity")
                {
                    UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusInternetConnectivityPartial -NewValue $true
                }
                else #If ($Response.Result.ToLower() -match "No Internet Connectivity")
                {
                    UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusInternetConnectivityNone -NewValue $true
                }

                # Update the Status text field
                UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbStatusInternetConnectionStatus -NewContent $Response.Result

                # Update the progress bar
                If ($Response.Result -match "\(\s*\d+\s*/\s*\d+\s*\)")
                {
                    $Response.Result | Select-String -Pattern "\(\s*(\d+)\s*/\s*(\d+)\s*\)" | % {
    #                "Full Internet Connectivity (3 / 5)" | Select-String -Pattern "\(\s*(\d+)\s*/\s*(\d+)\s*\)" | % {
                        $DomainsReached = $($_.matches.groups[1].Value).ToInt32($null)
                        $DomainsChecked = $($_.matches.groups[2].Value).ToInt32($null)
                    }

                    try
                    {
                        $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.Value = $DomainsReached},"Render")
                        $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.Value = $DomainsReached},"Render")
                    }
                    catch
                    {
                        LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
                        $pbStatusInternetConnectionStatus.Value = $DomainsReached
                    }

                    try
                    {
                        $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.Maximum = $DomainsChecked},"Render")
                        $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.Maximum = $DomainsChecked},"Render")
                    }
                    catch
                    {
                        LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
                        $pbStatusInternetConnectionStatus.Maximum = $DomainsChecked
                    }

                    try
                    {
                        $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.ToolTip = $Response.Detailed},"Render")
                        $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.ToolTip = $Response.Detailed},"Render")
                    }
                    catch
                    {
                        LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
                        $pbStatusInternetConnectionStatus.ToolTip = $Response.Detailed
                    }
                } # If ($Response.Result -match "\(\s*\d+\s*/\s*\d+\s*\)")


            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
        }
        else
        {
            UIDispacherInvokeUpdateIsChecked -ComponentToUpdate $rbStatusInternetConnectivityNone -NewValue $true
        
            # Update the progress bar
            try
            {
                $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.Value = 0},"Render")
                $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.Value = 0},"Render")
            }
            catch
            {
                LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
                $pbStatusInternetConnectionStatus.Value = 0
            }

            try
            {
                $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.Maximum = 1},"Render")
                $OCUIForm.Dispatcher.Invoke([action]{$pbStatusInternetConnectionStatus.Maximum = 1},"Render")
            }
            catch
            {
                LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
                $pbStatusInternetConnectionStatus.Maximum = 1
            }

            # Update the Status text field
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbStatusInternetConnectionStatus -NewContent ""

        } # if ($SHHCommandReturn.ExitStatus -eq 0)
    } # if ($script:SSHSession.Connected)
    else
    {
        LogError "Not possible to check the Internet connection of the Open-Collector as we are not connected to the Open-Collector host."
    }
}

$btStatusRefresh.Add_Click({
    # Refresh the whole Status page
    RefreshStatusTab
})



#  888     888 8888888                    8888888                   888             888 888          888    d8b                         888             888      
#  888     888   888                        888                     888             888 888          888    Y8P                         888             888      
#  888     888   888                        888                     888             888 888          888                                888             888      
#  888     888   888                        888   88888b.  .d8888b  888888  8888b.  888 888  8888b.  888888 888  .d88b.  88888b.        888888  8888b.  88888b.  
#  888     888   888                        888   888 "88b 88K      888        "88b 888 888     "88b 888    888 d88""88b 888 "88b       888        "88b 888 "88b 
#  888     888   888         888888         888   888  888 "Y8888b. 888    .d888888 888 888 .d888888 888    888 888  888 888  888       888    .d888888 888  888 
#  Y88b. .d88P   888                        888   888  888      X88 Y88b.  888  888 888 888 888  888 Y88b.  888 Y88..88P 888  888       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888                    8888888 888  888  88888P'  "Y888 "Y888888 888 888 "Y888888  "Y888 888  "Y88P"  888  888        "Y888 "Y888888 88888P"  
#                                                                                                                                                                
#                                                                                                                                                                
#                                                                                                                                                                

function InstallationDeployOCHelper
{
    # #########
    # Deploy the OCHelper.sh on the Open-Collector host
    
    # Steps:
    # 1. Try to get it over the net from the Open-Collector host directly
    # 1.1 From all the repositories
    # 2. Try to get it over the net from the local host, then drop it to the Open-Collector host
    # 2.1 From all the repositories
    # 2. use the local copy, then drop it to the Open-Collector host
    # 3. Check the integrity
    # 4. Backup old OSHelper.sh (into OSHelper.sh.old)
    # 5. Copy OSHelper.sh_tmp into OSHelper.sh
    # 6. Make the OSHelper.sh executable
    # 7. Check Version

    # Repositories
    $OCHelperRepositories = @("http://tiny.cc/OCHelper-sh-repo01","http://tiny.cc/OCHelper-sh-repo02", "https://logrhythm.box.com/shared/static/qf9d67e41il5o92y9y8wax705wrxftqd.sh")

    # Check variables
    $IsOCHelperTMPCopied=$false
    $IsOCHelperTMPIntegrityValid=$false
    $IsOCHelperTMPRenamed=$false
    $IsOCHelperExecutable=$false
    $IsOCHelperInstalled=$false
    $StatusText=""

    # #######
    # Step 1. First try to get it over the net from the Open-Collector host directly

    # Are we connected to the Open-Collector?
    if ($script:SSHSession.Connected)
    {
        $CurrentRepo = 0
        $LastExitStatus = -1

        # Go through all the Repositories
        while (($CurrentRepo -lt $OCHelperRepositories.Count) -and ($LastExitStatus -ne 0)) {
            try
            {
                $OCHelperRepo=$OCHelperRepositories[$CurrentRepo]
                $Command = "curl -Lsf ""$OCHelperRepo"" > OCHelper.sh_tmp"
                LogInfo ("Trying to download OCHelper.sh (for now, as OCHelper.sh_tmp) from the Open-Collector from repository {0}/{1} (URL: ""{2}"")." -f $($CurrentRepo+1), $OCHelperRepositories.Count, $OCHelperRepo)
                $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut 30

                $LastExitStatus = $SHHCommandReturn.ExitStatus
            }
            catch
            {
                # Oopsy Daisy... Something went wrong
                LogError ("Failed to send download command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
            }
            $CurrentRepo++
        } # while (($CurrentRepo -lt $OCHelperRepositories.Count) -and ($LastExitStatus -ne 0)) {

        if ($LastExitStatus -eq 0)
        {
            # We got one to work
            LogInfo (" \-- Successfuly downloaded OCHelper.sh (for now, as OCHelper.sh_tmp).")
            $IsOCHelperTMPCopied=$true
        }
        else
        {
            LogError (" \-- Failed to download OCHelper.sh after {0} attemps." -f $CurrentRepo)
        }


        # #######
        # Step 3. Check the integrity
        if ($IsOCHelperTMPCopied)
        {
            try
            {
                LogInfo " \-- Integrity checking OCHelper.sh_tmp."
                $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("bash OCHelper.sh_tmp --SelfIntegrityCheck") -TimeOut 10

                $LastExitStatus = $SHHCommandReturn.ExitStatus
            }
            catch
            {
                # Oopsy Daisy... Something went wrong
                LogError ("Failed to send check command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
            }
            if ($LastExitStatus -eq 0)
            {
                LogInfo "     \-- Passed."
                
                # OCHelper.sh_tmp is correctly copied (and checked) on the Open-collector
                $IsOCHelperTMPIntegrityValid=$true
            }
            else
            {
                LogError "     \-- Failed."
            }
        } # if ($IsOCHelperTMPCopied)

        # #######
        # 4. Backup old OSHelper.sh (into OSHelper.sh.old)
        if ($IsOCHelperTMPIntegrityValid)
        {
            try
            {
                LogInfo " \-- Copying OCHelper.sh_tmp into OCHelper.sh (and delete the OCHelper.sh_tmp)."
                $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("cat OCHelper.sh > OCHelper.sh.old") -TimeOut 5

                $LastExitStatus = $SHHCommandReturn.ExitStatus
            }
            catch
            {
                # Oopsy Daisy... Something went wrong
                LogError ("Failed to send backup command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
            }
            if ($LastExitStatus -eq 0)
            {
                LogInfo "     \-- Passed."
            }
            else
            {
                LogError "     \-- Failed (which is fine if there was no OCHelper.sh before)."
            }
        } # if ($IsOCHelperTMPIntegrityValid)

        # #######
        # 5. Copy OSHelper.sh_tmp into OSHelper.sh
        if ($IsOCHelperTMPIntegrityValid)
        {
            try
            {
                LogInfo " \-- Backing up old OCHelper.sh."
                $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("cat OCHelper.sh_tmp > OCHelper.sh && rm -f OCHelper.sh_tmp") -TimeOut 5

                $LastExitStatus = $SHHCommandReturn.ExitStatus
            }
            catch
            {
                # Oopsy Daisy... Something went wrong
                LogError ("Failed to send copy command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
            }
            if ($LastExitStatus -eq 0)
            {
                LogInfo "     \-- Passed."
                
                $IsOCHelperTMPRenamed=$true
            }
            else
            {
                LogError "     \-- Failed."
            }
        } # if ($IsOCHelperTMPIntegrityValid)

        # #######
        # 6. Make the OSHelper.sh executable
        if ($IsOCHelperTMPRenamed)
        {
            try
            {
                LogInfo " \-- Making OSHelper.sh executable."
                $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("chmod +x OCHelper.sh") -TimeOut 5

                $LastExitStatus = $SHHCommandReturn.ExitStatus
            }
            catch
            {
                # Oopsy Daisy... Something went wrong
                LogError ("Failed to send chmod command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
            }
            if ($LastExitStatus -eq 0)
            {
                LogInfo "     \-- Passed."
                
                $IsOCHelperExecutable=$true
            }
            else
            {
                LogError "     \-- Failed."
            }
        } # if ($IsOCHelperTMPRenamed)

        # #######
        # 7. Check Version
        if ($IsOCHelperExecutable)
        {
            try
            {
                LogInfo " \-- Checking OSHelper.sh version."
                $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckOCHelperVersion") -TimeOut 5

                $LastExitStatus = $SHHCommandReturn.ExitStatus
            }
            catch
            {
                # Oopsy Daisy... Something went wrong
                LogError ("Failed to send command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
            }
            if ($LastExitStatus -eq 0)
            {
                LogInfo ("     \-- Passed. Version: {0}." -f $SHHCommandReturn.Output)
                
                $IsOCHelperInstalled=$true
            }
            else
            {
                LogError "     \-- Failed."
            }
        } # if ($IsOCHelperExecutable)

        if ($IsOCHelperInstalled)
        {
            $StatusText = "OSHelper.sh deployed on Open-Collector hosts."
            LogInfo $StatusText
        }
        else
        {
            $StatusText = "Failed to deploy OSHelper.sh on Open-Collector hosts. Do review logs in PowerShell console."
            LogError $StatusText
        }
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOCHelperStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsOCHelperInstalled
}

$btInstallationAdvancedOCHelperDeploy.Add_Click({
    # Deploy the OCHelper.sh script
    InstallationDeployOCHelper
})

$btInstallationAdvancedOCHelperCheck.Add_Click({
    CheckOCHelperPresence
    CheckOCHelperVersion
})

function CheckOSVersion
{
    # #########
    # Check for the version of Operating System

    # Are we connected?
    if ($script:SSHSession.Connected)
    {
        try
        {
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --CheckOSVersion") -TimeOut 5
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to check for the version of ""OCHelper.sh"". Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            LogInfo ("OS Version: {0}." -f $SHHCommandReturn.Output)
            $OSVersion=$SHHCommandReturn.Output
            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                $OSVersion = $Response.version.Full
            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOSVersion -NewContent $OSVersion
        }
        else
        {
            UIDispacherInvokeUpdateLabelContent -LabelToUpdate $lbInstallationAdvancedOSVersion -NewContent "** Unknown **"
        }

    } # if ($script:SSHSession.Connected)
}

$btInstallationAdvancedOSCheck.Add_Click({
    CheckOSVersion
})

$btInstallationAdvancedDockerCheck.Add_Click({
    CheckDockerPresence
    CheckDockerVersion
})

$btInstallationAdvancedOpenCollectorCheck.Add_Click({
    CheckOpenCollectorHealth
})

function InstallationToolInstall()
{
    # #########
    # Install tool on the Open-Collector host

    param
    (
		[Parameter(Mandatory)]
        [string] $ToolToInstall,
		[Parameter(Mandatory)]
        [string] $OCHelperOption,
        [int] $OCHelperTimeoutInSeconds = 20
    )

    $IsInstallSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        try
        {
            LogInfo ("Installing {0}." -f $ToolToInstall)
            
            $Repositories="[]"
            if ($tbInstallationOptionsExtraRepositoriesTools.Text.Length -gt 0)
            {
                $RepositoriesTable = $tbInstallationOptionsExtraRepositoriesTools.Text.Split(" ")
                if ($RepositoriesTable.Count -gt 0)
                {
                    $Repositories = "["
	                ForEach ($Repository in $RepositoriesTable) {
		                if (-Not ([string]::IsNullOrEmpty($Repository)))
		                {
			                $Repositories += ("{{""URL"":""{0}""}}" -f $Repository)
		                }
                    }
                    $Repositories += "]"
                    $Repositories = $Repositories.Replace('}{','},{')
                }
            }
            $Command = ("./OCHelper.sh --{1} '{{""ExtraRepositories"": {0}}}'" -f $Repositories, $OCHelperOption)
            LogDebug ("Command: {0}" -f $Command)
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $OCHelperTimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send install {1} command to the Open-Collector. Exception: {0}." -f $_.Exception.Message, $ToolToInstall)
        }
        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsInstallSuccessful = $true
        }
        else
        {
            LogError "     \-- Failed."
        }

        if ($IsInstallSuccessful)
        {
            $StatusText = ("{0} deployed on Open-Collector hosts." -f $ToolToInstall)
            LogInfo $StatusText
        }
        else
        {
            $StatusText = ("Failed to deploy {0} on Open-Collector hosts. Do review logs in PowerShell console." -f $ToolToInstall)
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedToolsStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsInstallSuccessful
}

$btInstallationAdvancedToolsInstallLrctl.Add_Click({
    # Install LRCTL
    InstallationToolInstall -ToolToInstall "LRCTL" -OCHelperOption "DeployLatestLrctl" -OCHelperTimeoutInSeconds 20
})

$btInstallationAdvancedToolsInstallLrjq.Add_Click({
    # Install LRJQ
    InstallationToolInstall -ToolToInstall "LRJQ" -OCHelperOption "DeployLatestLRJQ" -OCHelperTimeoutInSeconds 20
})

$btInstallationAdvancedToolsInstallOcpipeline.Add_Click({
    # Install Ocpipeline
    InstallationToolInstall -ToolToInstall "Ocpipeline" -OCHelperOption "DeployLatestOcpipeline" -OCHelperTimeoutInSeconds 20
})


function InstallUpdateProgress()
{
    param
    (
        [string] $StatusText = "",
        [int] $ProgressBarValue = -1,
        [int] $ProgressBarMaxValue = -1
    )

    # Update the Status text field
    if ($StatusText.Length -gt 0)
    {
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallStatus -NewContent $StatusText
    }

    # Update the progress Bar Value
    if ($ProgressBarValue -ge 0)
    {
        try
        {
            $OCUIForm.Dispatcher.Invoke([action]{$pbInstallProgress.Value = $ProgressBarValue},"Render")
            $OCUIForm.Dispatcher.Invoke([action]{$pbInstallProgress.Value = $ProgressBarValue},"Render")
        }
        catch
        {
            LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
            $pbInstallProgress.Value = $ProgressBarValue
        }
    }

    # Update the progress Bar Maximum Value
    if ($ProgressBarMaxValue -ge 0)
    {
        try
        {
            $OCUIForm.Dispatcher.Invoke([action]{$pbInstallProgress.Maximum = $ProgressBarMaxValue},"Render")
            $OCUIForm.Dispatcher.Invoke([action]{$pbInstallProgress.Maximum = $ProgressBarMaxValue},"Render")
        }
        catch
        {
            LogError ("Failed to render the UI in real-time. Exception: {0}." -f $_.Exception.Message)
            $pbInstallProgress.Maximum = $ProgressBarMaxValue
        }
    }
}

function InstallationInstallDocker()
{
    # #########
    # Install Docker on the Open-Collector host

    $ToolToInstall="Docker"
    $OCHelperTimeoutInSeconds=500
    $IsInstallSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        try
        {
            LogInfo ("Installing {0}." -f $ToolToInstall)
            
            $ExtraParams=$tbInstallationOptionsExtraParamDockerInstall.Text
            if ($ExtraParams.Length -gt 0)
            {
                # {"ExtraParameters": "%s_base64_encoded"}
                $ExtraParams = Base64-Encode -TextToBase64Encode $ExtraParams
            }
            $Command = ("./OCHelper.sh --InstallDocker '{{""ExtraParameters"": ""{0}""}}'" -f $ExtraParams)
            LogDebug ("Command: {0}" -f $Command)
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $OCHelperTimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send install {1} command to the Open-Collector. Exception: {0}." -f $_.Exception.Message, $ToolToInstall)
        }
        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsInstallSuccessful = $true
        }
        else
        {
            LogError "     \-- Failed."
            if ($LastOutput.length -gt 0)
            {
                try
                {
                    $LastOutput = $LastOutput | ConvertFrom-Json
                    try
                    {
                        $LastOutput = $(Base64-Decode Base64-Decode -Base64EncodedText $LastOutput.Error)
                    }
                    catch
                    {
                        LogError "Response.Error could not be Base64 decoded."
                    }
                }
                catch
                {
                    LogError "Response JSON could not be decoded."
                }
                LogError "====== Output dump - BEGIN ======"
                LogError -e "$LastOutput"
                LogError "====== Output dump - END ======"
            }
        }

        if ($IsInstallSuccessful)
        {
            $StatusText = ("{0} deployed on Open-Collector hosts." -f $ToolToInstall)
            LogInfo $StatusText
        }
        else
        {
            $StatusText = ("Failed to deploy {0} on Open-Collector hosts. Do review logs in PowerShell console." -f $ToolToInstall)
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedDockerStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsInstallSuccessful
}

$btInstallationAdvancedDockerInstall.Add_Click({
    # Deploy Docker
    # Zeem bam Boom!
    InstallationInstallDocker
})

function InstallationUpgradeDocker()
{
    # #########
    # Upgrade Docker on the Open-Collector host

    $ToolToInstall="Docker"
    $OCHelperTimeoutInSeconds=500
    $IsInstallSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        try
        {
            LogInfo ("Upgrading {0}." -f $ToolToInstall)
            
            $ExtraParams=$tbInstallationOptionsExtraParamDockerUpgrade.Text
            if ($ExtraParams.Length -gt 0)
            {
                # {"ExtraParameters": "%s_base64_encoded"}
                $ExtraParams = Base64-Encode -TextToBase64Encode $ExtraParams
            }
            $Command = ("./OCHelper.sh --UpgradeDocker '{{""ExtraParameters"": ""{0}""}}'" -f $ExtraParams)
            LogDebug ("Command: {0}" -f $Command)
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $OCHelperTimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send upgrade {1} command to the Open-Collector. Exception: {0}." -f $_.Exception.Message, $ToolToInstall)
        }
        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsInstallSuccessful = $true
        }
        else
        {
            LogError "     \-- Failed."
            if ($LastOutput.length -gt 0)
            {
                try
                {
                    $LastOutput = $LastOutput | ConvertFrom-Json
                    try
                    {
                        $LastOutput = $(Base64-Decode Base64-Decode -Base64EncodedText $LastOutput.Error)
                    }
                    catch
                    {
                        LogError "Response.Error could not be Base64 decoded."
                    }
                }
                catch
                {
                    LogError "Response JSON could not be decoded."
                }
                LogError "====== Output dump - BEGIN ======"
                LogError -e "$LastOutput"
                LogError "====== Output dump - END ======"
            }
        }

        if ($IsInstallSuccessful)
        {
            $StatusText = ("{0} upgraded on Open-Collector hosts." -f $ToolToInstall)
            LogInfo $StatusText
        }
        else
        {
            $StatusText = ("Failed to upgrade {0} on Open-Collector hosts. Do review logs in PowerShell console." -f $ToolToInstall)
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedDockerStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsInstallSuccessful
}

$btInstallationAdvancedDockerUpgrade.Add_Click({
    # Upgrade Docker
    InstallationUpgradeDocker
})

function InstallationInstallOpenCollector()
{
    # #########
    # Install Open-Collector on the Open-Collector host

    $ToolToInstall="Open-Collector"
    $OCHelperTimeoutInSeconds=500
    $IsInstallSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        try
        {
            LogInfo ("Installing {0}." -f $ToolToInstall)
            
            $ExtraParams=$tbInstallationOptionsExtraParamOpencollectorInstall.Text
            if ($ExtraParams.Length -gt 0)
            {
                # {"ExtraParameters": "%s_base64_encoded"}
                $ExtraParams = Base64-Encode -TextToBase64Encode $ExtraParams
            }
            $Command = ("./OCHelper.sh --InstallOC '{{""ExtraParameters"": ""{0}""}}'" -f $ExtraParams)
            LogDebug ("Command: {0}" -f $Command)
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $OCHelperTimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send install {1} command to the Open-Collector. Exception: {0}." -f $_.Exception.Message, $ToolToInstall)
        }

        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }

        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsInstallSuccessful = $true
            LogDebug "====== Output dump - BEGIN ======"
            LogDebug $LastOutputDump
            LogDebug "====== Output dump - END ======"
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }

        if ($IsInstallSuccessful)
        {
            $StatusText = ("{0} deployed on Open-Collector hosts." -f $ToolToInstall)
            LogInfo $StatusText
        }
        else
        {
            $StatusText = ("Failed to deploy {0} on Open-Collector hosts. Do review logs in PowerShell console." -f $ToolToInstall)
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsInstallSuccessful
}

$btInstallationAdvancedOpenCollectorInstall.Add_Click({
    # Deploy Open-Collector
    # Roule Ma Poule !
    InstallationInstallOpenCollector
})

function InstallationUpgradeOpenCollector()
{
    # #########
    # Upgrade Open-Collector on the Open-Collector host

    $ToolToInstall="Open-Collector"
    $OCHelperTimeoutInSeconds=500
    $IsInstallSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        try
        {
            LogInfo ("Upgrading {0}." -f $ToolToInstall)
            
            $ExtraParams=$tbInstallationOptionsExtraParamOpencollectorUpgrade.Text
            if ($ExtraParams.Length -gt 0)
            {
                # {"ExtraParameters": "%s_base64_encoded"}
                $ExtraParams = Base64-Encode -TextToBase64Encode $ExtraParams
            }
            $Command = ("./OCHelper.sh --UpgradeOC '{{""ExtraParameters"": ""{0}""}}'" -f $ExtraParams)
            LogDebug ("Command: {0}" -f $Command)
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $OCHelperTimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send upgrade {1} command to the Open-Collector. Exception: {0}." -f $_.Exception.Message, $ToolToInstall)
        }

        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }

        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsInstallSuccessful = $true
            LogDebug "====== Output dump - BEGIN ======"
            LogDebug $LastOutputDump
            LogDebug "====== Output dump - END ======"
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }

        if ($IsInstallSuccessful)
        {
            $StatusText = ("{0} upgraded on Open-Collector hosts." -f $ToolToInstall)
            LogInfo $StatusText
        }
        else
        {
            $StatusText = ("Failed to upgrade {0} on Open-Collector hosts. Do review logs in PowerShell console." -f $ToolToInstall)
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsInstallSuccessful
}

$btInstallationAdvancedOpenCollectorUpgrade.Add_Click({
    # Uprade Open-Collector
    InstallationUpgradeOpenCollector
})

Enum ServiceManagerActions
{
 Start
 Stop
 Restart
}

function InstallationOpenCollectorServiceManager()
{
    param
    (
		[Parameter(Mandatory)]
        #[System.Enum] $ServiceOperation,
        [string] $ServiceOperation,
        [string] $ExtraParameters = "",
        [int] $TimeoutInSeconds = 30
    )

    # #########
    # Manage the Open-Collector service/container on the Open-Collector host

    $ToolToManage="Open-Collector"
    $IsOperationSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        try
        {
            LogInfo ("Managing Service for {0}. Action: {1}" -f $ToolToManage, $ServiceOperation)
            
            if ($ExtraParameters.Length -gt 0)
            {
                # {"ExtraParameters": "%s_base64_encoded"}
                try
                {
                    $ExtraParameters = Base64-Encode -TextToBase64Encode $ExtraParameters
                }
                catch
                {
                    $ExtraParameters = ""
                }
            }
            $Command = ("./OCHelper.sh --{1}OC '{{""ExtraParameters"": ""{0}""}}'" -f $ExtraParameters, $ServiceOperation)
            LogDebug ("Command: {0}" -f $Command)
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send service management {1} command to the Open-Collector. Exception: {0}." -f $_.Exception.Message, $ToolToManage)
        }
        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsOperationSuccessful = $true
        }
        else
        {
            LogError "     \-- Failed."
            if ($LastOutput.length -gt 0)
            {
                try
                {
                    $LastOutput = $LastOutput | ConvertFrom-Json
                    try
                    {
                        $LastOutput = $(Base64-Decode Base64-Decode -Base64EncodedText $LastOutput.Error)
                    }
                    catch
                    {
                        LogError "Response.Error could not be Base64 decoded."
                    }

                    try
                    {
                        $LastOutput += "`n`n"
                        $LastOutput = $(Base64-Decode Base64-Decode -Base64EncodedText $LastOutput.Result)
                    }
                    catch
                    {
                        LogError "Response.Result could not be Base64 decoded."
                    }
                }
                catch
                {
                    LogError "Response JSON could not be decoded."
                }
                LogError "====== Output dump - BEGIN ======"
                LogError $LastOutput
                LogError "====== Output dump - END ======"
            }
        }

        if ($IsOperationSuccessful)
        {
            $StatusText = ("{1} operation on service {0} on Open-Collector hosts successful." -f $ToolToManage, $ServiceOperation)
            LogInfo $StatusText
        }
        else
        {
            $StatusText = ("{1} operation on service {0} on Open-Collector hosts failed. Do review logs in PowerShell console." -f $ToolToManage)
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedOpenCollectorStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

$btInstallationAdvancedOpenCollectorStart.Add_Click({
    # Start Open-Collector
    #InstallationOpenCollectorServiceManager -ServiceOperation [ServiceManagerActions]::Start -ExtraParameters "" -TimeoutInSeconds 60
    InstallationOpenCollectorServiceManager -ServiceOperation "Start" -ExtraParameters "" -TimeoutInSeconds 60
})

$btInstallationAdvancedOpenCollectorRestart.Add_Click({
    # Restart Open-Collector
    #InstallationOpenCollectorServiceManager -ServiceOperation [ServiceManagerActions]::Restart -ExtraParameters "" -TimeoutInSeconds 500
    InstallationOpenCollectorServiceManager -ServiceOperation "Restart" -ExtraParameters "" -TimeoutInSeconds 500
})

$btInstallationAdvancedOpenCollectorStop.Add_Click({
    # Stop Open-Collector
    #InstallationOpenCollectorServiceManager -ServiceOperation [ServiceManagerActions]::Stop -ExtraParameters "" -TimeoutInSeconds 60
    InstallationOpenCollectorServiceManager -ServiceOperation "Stop" -ExtraParameters "" -TimeoutInSeconds 60
})

$btInstallFullinstall.Add_Click({
    # Variables
    $CurrentStep=0
    $TotalStep=0
    $TotalStep++ # DeployOCHelper
    $TotalStep++ # Install LRCTL
    $TotalStep++ # Install LRJQ
    $TotalStep++ # Install Ocpipeline
    $TotalStep++ # Install Docker
    $TotalStep++ # Install Open-Collector
    $CurrentStepName=""
    $TimeoutInSeconds=60

    $MsgBoxResponse = [System.Windows.MessageBox]::Show("This will totally replace the configuration of any existing Open-Collector by a vanilla configuration.`n`nWould  you like continue?`n`nNote: you can check the presence of the Open-Collector in the Status tab.",'Open-Collector Installation','YesNo','Warning','No')
    switch  ($MsgBoxResponse) {
        'No' {
            LogInfo "Decided against installing the full Open-Collector stack."
        }
        'Yes' {
            # Go ahead 
            LogInfo "User confirmed that installing the configuration to the full Open-Collector stack should go ahead"

            # Update initial Status
            InstallUpdateProgress -ProgressBarMaxValue $TotalStep -ProgressBarValue $CurrentStep -StatusText "Starting Installation"

            # Deploy the OCHelper.sh script
            $CurrentStepName="deploying OCHelper.sh (Bridgehead for this tool)"
            InstallUpdateProgress -StatusText ("Started {0}..." -f $CurrentStepName)
            if (InstallationDeployOCHelper)
            {
                $CurrentStep++
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Succesfully finished {0}." -f $CurrentStepName)
            }
            else
            {
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Failed {0}." -f $CurrentStepName)
            }

            # Installing LRCTL
            $CurrentStepName="installing LRCTL"
            InstallUpdateProgress -StatusText ("Started {0}..." -f $CurrentStepName)
            if (InstallationToolInstall -ToolToInstall "LRCTL" -OCHelperOption "DeployLatestLrctl" -OCHelperTimeoutInSeconds $TimeoutInSeconds)
            {
                $CurrentStep++
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Succesfully finished {0}." -f $CurrentStepName)
            }
            else
            {
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Failed {0}." -f $CurrentStepName)
            }

            # Installing LRJQ
            $CurrentStepName="installing LRJQ"
            InstallUpdateProgress -StatusText ("Started {0}..." -f $CurrentStepName)
            if (InstallationToolInstall -ToolToInstall "LRJQ" -OCHelperOption "DeployLatestLRJQ" -OCHelperTimeoutInSeconds $TimeoutInSeconds)
            {
                $CurrentStep++
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Succesfully finished {0}." -f $CurrentStepName)
            }
            else
            {
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Failed {0}." -f $CurrentStepName)
            }

            # Installing Ocpipeline
            $CurrentStepName="installing Ocpipeline"
            InstallUpdateProgress -StatusText ("Started {0}..." -f $CurrentStepName)
            if (InstallationToolInstall -ToolToInstall "Ocpipeline" -OCHelperOption "DeployLatestOcpipeline" -OCHelperTimeoutInSeconds $TimeoutInSeconds)
            {
                $CurrentStep++
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Succesfully finished {0}." -f $CurrentStepName)
            }
            else
            {
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Failed {0}." -f $CurrentStepName)
            }

            # Installing Docker
            $CurrentStepName="installing Docker"
            InstallUpdateProgress -StatusText ("Started {0}..." -f $CurrentStepName)
            if (InstallationInstallDocker)
            {
                $CurrentStep++
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Succesfully finished {0}." -f $CurrentStepName)
            }
            else
            {
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Failed {0}." -f $CurrentStepName)
            }

            # Installing Open-Collector
            $CurrentStepName="installing Open-Collector"
            InstallUpdateProgress -StatusText ("Started {0}..." -f $CurrentStepName)
            if (InstallationInstallOpenCollector)
            {
                $CurrentStep++
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Succesfully finished {0}." -f $CurrentStepName)
            }
            else
            {
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Failed {0}." -f $CurrentStepName)
            }

<# NOT NECESSARY, AS OPEN-COLLECTOR IS STARTED AS PART OF THE INSTALL PROCESS
            # Starting Open-Collector
            $CurrentStepName="starting Open-Collector"
            InstallUpdateProgress -StatusText ("Started {0}..." -f $CurrentStepName)
            if (InstallationOpenCollectorServiceManager -ServiceOperation "Start" -ExtraParameters "" -TimeoutInSeconds $TimeoutInSeconds)
            {
                $CurrentStep++
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Succesfully finished {0}." -f $CurrentStepName)
            }
            else
            {
                InstallUpdateProgress -ProgressBarValue $CurrentStep -StatusText ("Failed {0}." -f $CurrentStepName)
            }
#>
        } # 'Yes' {
    } # switch  ($MsgBoxResponse) {

})

function InstallOpenCollectorConfigExport()
{
    # #########
    # Export the configuration of the Open-Collector to disk locally

    param
    (
		[Parameter(Mandatory)]
        [string] $FileName,
        [int] $TimeoutInSeconds = 30
    )

    $IsOperationSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        try
        {
            LogInfo ("Exporting the Open-Collector configuration to ""{0}""." -f $FileName)
            
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --ReadOCConfiguration") -TimeOut $TimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send config export command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
        }
        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            if ($LastOutput.length -gt 0)
            {
                try
                {
                    $LastOutput | Out-File -FilePath $FileName -Force -NoNewline
                    $IsOperationSuccessful = $true
                }
                catch
                {
                    LogError "Response from OCHelper could not be saved to disk."
                }
            }
        }
        else
        {
            LogError "     \-- Failed."
        }

        if ($IsOperationSuccessful)
        {
            $StatusText = ("Open Collector configuration saved to disk. File name: ""{0}""." -f $FileName)
            LogInfo $StatusText
            $StatusText = "Open Collector configuration saved to disk."
        }
        else
        {
            $StatusText = "Failed to save Open Collector configuration to disk."
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedOpenCollectorConfigStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

function InstallOpenCollectorConfigImport()
{
    # #########
    # Import the configuration of the Open-Collector from a local file

    param
    (
		[Parameter(Mandatory)]
        [string] $FileName,
        [int] $TimeoutInSeconds = 30
    )

    $IsOperationSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        LogInfo ("Importing the Open-Collector configuration from ""{0}""." -f $FileName)
            
        if (Test-Path $FileName)
        {
            LogInfo ("  \-- File ""{0}"" exists. That's a good start." -f $FileName)

            try
            {
                LogInfo ("  \-- Loading ""{0}""..." -f $FileName)
	            [string]$OpenCollectorConfig = Get-Content -Raw -Path $FileName
                LogInfo "   \-- Loaded."
                try
                {
                    if ($OpenCollectorConfig.Length -gt 0)
                    {
                        # {"RawConfig": "%s_base64_encoded"}
                        $RawConfig = Base64-Encode -TextToBase64Encode $OpenCollectorConfig
                    }
                    $Command = ("./OCHelper.sh --WriteOCConfiguration '{{""RawConfig"": ""{0}""}}'" -f $RawConfig)
                    $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeoutInSeconds
                    $LastExitStatus = $SHHCommandReturn.ExitStatus
                    $LastOutput = $SHHCommandReturn.Output
                }
                catch
                {
                    # Oopsy Daisy... Something went wrong
                    LogError ("Failed to send config import command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
                }

                $LastOutputDump=$LastOutput

                if ($LastOutput.length -gt 0)
                {
                    try
                    {
                        $LastOutput = $LastOutput | ConvertFrom-Json
                        try
                        {
                            $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                        }
                        catch
                        {
                            LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                        }

                        try
                        {
                            $LastOutputDump += "`n`n"
                            $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                        }
                        catch
                        {
                            LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                        }
                    }
                    catch
                    {
                        LogError "Response JSON could not be decoded."
                    }
                }

                if ($LastExitStatus -eq 0)
                {
                    LogInfo "     \-- Passed."
                    $IsOperationSuccessful = $true
                    LogDebug "====== Output dump - BEGIN ======"
                    LogDebug $LastOutputDump
                    LogDebug "====== Output dump - END ======"
                }
                else
                {
                    LogError "     \-- Failed."
                    LogError "====== Output dump - BEGIN ======"
                    LogError $LastOutputDump
                    LogError "====== Output dump - END ======"
                }

            }
            catch
            {
	            LogError ("  \-- Could not load ""{0}"" file." -f $FileName)
            }

        }
        else 
        {
	        LogInfo ("Configuration file ""{0}"" doesn't exists." -f $FileName)
        }



        if ($IsOperationSuccessful)
        {
            $StatusText = ("Open Collector configuration imported from disk. File name: ""{0}""." -f $FileName)
            LogInfo $StatusText
            $StatusText = "Open Collector configuration imported from disk."
        }
        else
        {
            $StatusText = "Failed to import Open Collector configuration from disk."
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedOpenCollectorConfigStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

$btInstallationAdvancedOpenCollectorConfigExport.Add_Click({
    $ConfigFileToExportTo = Set-FileName -Filter "Open-Collector Configuration files (*.yml)|*.yml|All files (*.*)| *.*" -Title "Save an Open-Collector Configuration file" -InitialDirectory $script:LastBrowsePath -FileName ("{0}.OpenCollector Configuration Export.yml" -f (Get-Date).tostring("yyyy.MM.dd_HH.mm.ss")) -OverwritePrompt
    if ($ConfigFileToExportTo.Length -gt 0)
    {
        InstallOpenCollectorConfigExport -FileName $ConfigFileToExportTo -TimeoutInSeconds 60
    }
})

$btInstallationAdvancedOpenCollectorConfigImport.Add_Click({
    $ConfigFileToImport = Get-FileName -Filter "Open-Collector Configuration files (*.yml)|*.yml|All files (*.*)| *.*" -Title "Open an Open-Collector Configuration file" -CheckFileExists -InitialDirectory $script:LastBrowsePath
    if ($ConfigFileToImport.Length -gt 0)
    {
        $MsgBoxResponse = [System.Windows.MessageBox]::Show("This will totally replace the Open-Collector configuration with the file from this computer.`n`nThere will be no verificataion done, and that file will be inserted directly. You better be sure.`n`nWould  you like continue and import it?`n`nNote: doing an Export of the current configuration before is a VERY GOOD idea.",'Open-Collector Configuration Import','YesNo','Warning','No')
        switch  ($MsgBoxResponse) {
          'Yes' {
            try
            {
                # Go ahead and burn that config in the OC
                LogInfo ("User confirmed that importing configuration to the Open-Collector should go ahead. File: ""{0}""." -f $ConfigFileToImport)
                InstallOpenCollectorConfigImport -FileName $ConfigFileToImport -TimeoutInSeconds 60
            }
            catch
            {
                LogError ("Failed to import the configuration. Exception: {0}." -f $_.Exception.Message)
            }
          }
          'No' {
            LogInfo "Decided against importing the config to the Open-Collector. Good. Probably better that way."
          }
        }
    }
})

function InstallOpenCollectorLogsExport()
{
    # #########
    # Export the logs of the Open-Collector to local disk

    param
    (
		[Parameter(Mandatory)]
        [string] $FileName,
        [int] $TimeoutInSeconds = 30
    )

    $IsOperationSuccessful=$false

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        try
        {
            LogInfo ("Exporting the Open-Collector logs to ""{0}""." -f $FileName)
            
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --ReadOCLogs") -TimeOut $TimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send logs export command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
        }
        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            if ($LastOutput.length -gt 0)
            {
                try
                {
                    $LastOutput | Out-File -FilePath $FileName -Force
                    $IsOperationSuccessful = $true
                }
                catch
                {
                    LogError "Response from OCHelper could not be saved to disk."
                }
            }
        }
        else
        {
            LogError "     \-- Failed."
        }

        if ($IsOperationSuccessful)
        {
            $StatusText = ("Open Collector logs saved to disk. File name: ""{0}""." -f $FileName)
            LogInfo $StatusText
            $StatusText = "Open Collector logs saved to disk."
        }
        else
        {
            $StatusText = "Failed to save Open Collector logs to disk."
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedOpenCollectorLogsStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

$btInstallationAdvancedOpenCollectorLogsExport.Add_Click({
    $LogFileToExportTo = Set-FileName -Filter "Open-Collector Log files (*.log)|*.log|All files (*.*)| *.*" -Title "Save an Open-Collector Log file" -InitialDirectory $script:LastBrowsePath -FileName ("{0}.OpenCollector Configuration Logs.log" -f (Get-Date).tostring("yyyy.MM.dd_HH.mm.ss")) -OverwritePrompt
    if ($LogFileToExportTo.Length -gt 0)
    {
        InstallOpenCollectorLogsExport -FileName $LogFileToExportTo -TimeoutInSeconds 60
    }
})


#  888     888 8888888                    8888888b.  d8b                   888 d8b                                  888             888      
#  888     888   888                      888   Y88b Y8P                   888 Y8P                                  888             888      
#  888     888   888                      888    888                       888                                      888             888      
#  888     888   888                      888   d88P 888 88888b.   .d88b.  888 888 88888b.   .d88b.  .d8888b        888888  8888b.  88888b.  
#  888     888   888                      8888888P"  888 888 "88b d8P  Y8b 888 888 888 "88b d8P  Y8b 88K            888        "88b 888 "88b 
#  888     888   888         888888       888        888 888  888 88888888 888 888 888  888 88888888 "Y8888b.       888    .d888888 888  888 
#  Y88b. .d88P   888                      888        888 888 d88P Y8b.     888 888 888  888 Y8b.          X88       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888                    888        888 88888P"   "Y8888  888 888 888  888  "Y8888   88888P'        "Y888 "Y888888 88888P"  
#                                                        888                                                                                 
#                                                        888                                                                                 
#                                                        888                                                                                 

$btPipelinesInstalledRefresh.Add_Click({
    # Refresh the Installed Pipeline list
    GetOpenCollectorInstalledPipeline
})

$dgPipelinesInstalledList.Add_SelectionChanged({
    #LogDebug ("Selection Changed to ""{0}""." -f $dgPipelinesInstalledList.SelectedItem.Name)
    if ($dgPipelinesInstalledList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesInstalledList.SelectedItem.Enabled)
        {
            $rbPipelinesInstalledEnabled.IsChecked = $true
        }
        else
        {
            $rbPipelinesInstalledDisabled.IsChecked = $true
        }
        
        # Is it a LogRhythm default rule?
        if ($dgPipelinesInstalledList.SelectedItem.Name -match "^logrhythm/")
        {
            # LogRhythm rule
            # Disable the radio buttons, so the status can't be changed
            $rbPipelinesInstalledEnabled.IsEnabled = $false
            $rbPipelinesInstalledDisabled.IsEnabled = $false
        }
        else
        {
            # Non LogRhythm rule
            # Enable the radio buttons
            $rbPipelinesInstalledEnabled.IsEnabled = $true
            $rbPipelinesInstalledDisabled.IsEnabled = $true
        }

    } # if ($dgPipelinesInstalledList.SelectedIndex -ge 0)
})

function PipelinesManage()
{
    # #########
    # Enable or Disable the pipeline on the Open-Collector host

    param
    (
        [string] $PipelineName="",
        [string] $Action="Enable", # Enable or Disable
        [int] $TimeOutInSeconds=10
    )

    $IsOperationSuccessful=$false

    if ($PipelineName.Length -le 0)
    {
        LogError "No pipeline name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($Action.ToLower() -eq "enable")
    {
        $Action="Enable"
    }
    else
    {
        if ($Action.ToLower() -eq "disable")
        {
            $Action="Disable"
        }
        else
        {
            LogError ("Wrong Action provided (""{0}""). Doing nothing." -f $Action)
            return $IsOperationSuccessful
        }
    }

    if ($script:SSHSession.Connected)
    {
        try
        {
            LogInfo ("{0} the pipeline ""{1}"" on the Open-Collector host." -f $Action, $PipelineName)
            $Command=("./OCHelper.sh --{1}InstalledPipeline '{{""PipelineName"": ""{0}""}}'" -f $PipelineName, $Action)
            $Command=("./OCHelper.sh --EnableInstalledPipeline '{{""PipelineName"": ""{0}""}}'" -f $PipelineName, $Action)
            LogDebug "Command: ""$Command""."
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeOutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to {1} the Pipeline on the Open-Collector host. Exception: {0}." -f $_.Exception.Message, $Action)
        }

        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }


        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsOperationSuccessful = $true
            LogDebug "====== Output dump - BEGIN ======"
            LogDebug $LastOutputDump
            LogDebug "====== Output dump - END ======"
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }


    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

$rbPipelinesInstalledEnabled.Add_Click({
    # Enable the Installed Pipeline
    if ($dgPipelinesInstalledList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesInstalledList.SelectedItem.Enabled)
        {
            LogDebug "Already Enabled"
        }
        else
        {
            LogDebug "Enable the Installed Pipeline"
            # Enable the Installed Pipeline
            PipelinesManage -PipelineName $dgPipelinesInstalledList.SelectedItem.Name -Action "Enable"

            # Refresh the Installed Pipeline list
            GetOpenCollectorInstalledPipeline
        }
    }
})

$rbPipelinesInstalledDisabled.Add_Click({
    # Disable the Installed Pipeline
    if ($dgPipelinesInstalledList.SelectedIndex -ge 0)
    {
        if (-Not $dgPipelinesInstalledList.SelectedItem.Enabled)
        {
            LogDebug "Already Disabled"
        }
        else
        {
            LogDebug "Disable the Installed Pipeline"
            # Disable the Installed Pipeline
            PipelinesManage -PipelineName $dgPipelinesInstalledList.SelectedItem.Name -Action "Disable"

            # Refresh the Installed Pipeline list
            GetOpenCollectorInstalledPipeline
        }
    }
})


function GetOpenCollectorPipelineProjects()
{
    # #########
    # Get the pipelines project from the Open-Collector host (but only the ones in the user's personal folder)
    if ($script:SSHSession.Connected)
    {
        try
        {
            LogInfo ("Getting the list of Pipelines Projects on the Open-Collector host. Exception: {0}." -f $_.Exception.Message)
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ("./OCHelper.sh --ListPipelineProjects") -TimeOut 10
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to list the Pipelines Projects on the Open-Collector host. Exception: {0}." -f $_.Exception.Message)
        }

        if ($SHHCommandReturn.ExitStatus -eq 0)
        {
            try
            {
                $Response = $SHHCommandReturn.Output | ConvertFrom-Json
                LogInfo ("Found {0} Pipelines Projects on the Open-Collector host for current user." -f $Response.Count)
                # Clear the current list of Pipelines
                $dgPipelinesProjectList.Items.Clear()
                # Add all the ones we got from OCHelper
                foreach ($PipelineProject in $Response)
                {
                    # Create a new blank Pipeline entry
                    $NewPipelineItem = Select-Object -inputobject "" Name
                    LogInfo (" \-- Found Pipeline Project named ""{0}""." -f $PipelineProject.PipelineProjectName)
                
                    # We might decide later to translate the full pipeline name into a shorter one. For now, I just keep as is.
                    $NewPipelineItem.Name = $PipelineProject.PipelineProjectName

                    # Add to the table
                    $dgPipelinesProjectList.Items.Add($NewPipelineItem)
                }
            }
            catch
            {
                LogError ("Failed to read OCHelper JSON output. Exception: {0}." -f $_.Exception.Message)
            }
        }
    } # if ($script:SSHSession.Connected)
}


$btPipelinesProjectRefresh.Add_Click({
    # Refresh the Pipeline Project list
    GetOpenCollectorPipelineProjects
})

$dgPipelinesProjectList.Add_SelectionChanged({

    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            $btPipelinesProjectInstall.IsEnabled = $true

            PipelinesProjectLoadFilter -ProjectName $dgPipelinesProjectList.SelectedItem.Name
            PipelinesProjectLoadTransform -ProjectName $dgPipelinesProjectList.SelectedItem.Name
        }
        else
        {
            $btPipelinesProjectInstall.IsEnabled = $false
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)
})

function PipelinesProjectCreateNew()
{
    # #########
    # Create the new pipelines project on the Open-Collector host

    param
    (
        [string] $NewProjectName=""
    )

    $IsOperationSuccessful=$false

    #LogDebug ("New Project name: ""{0}""." -f $NewPipelineProjectName)
    if ($NewProjectName.Length -le 0)
    {
        LogError "No new project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    foreach ($PipelineProjectListItem in $dgPipelinesProjectList.Items)
    {
        # Check if another Pipeline project exists with the same name (as this is the only ID we have)
        if ($PipelineProjectListItem.Name -eq $NewProjectName)
        {
            LogError ("  \-- Found an existing Pipeline Project named ""{0}"". Doing nothing" -f $PipelineProjectListItem.Name)
            return $IsOperationSuccessful
        }
    }

    if ($script:SSHSession.Connected)
    {
        try
        {
            LogInfo "Creating a new Pipelines Projects on the Open-Collector host."
            $NewProjectName = $NewProjectName.Replace('"',"'")
            $Command=("./OCHelper.sh --CreatePipelineProject '{{""ProjectName"": ""{0}""}}'" -f $NewProjectName)
            #LogDebug "Command: ""$Command""."
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut 10
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to create the Pipelines Project on the Open-Collector host. Exception: {0}." -f $_.Exception.Message)
        }

        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }


        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsOperationSuccessful = $true
            #LogDebug "====== Output dump - BEGIN ======"
            #LogDebug $LastOutputDump
            #LogDebug "====== Output dump - END ======"

            # Fall back on just adding the name
            try
            {
                # Add to the table
                $NewPipelineItem = Select-Object -inputobject "" Name
                
                # Pipeline project name
                $NewPipelineItem.Name = $NewProjectName

                # Add to the table
                $dgPipelinesProjectList.Items.Add($NewPipelineItem)
            }
            catch
            {
                LogError "Failed to add New Project to the table."
            }
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }

    } # if ($script:SSHSession.Connected)
    
    return $IsOperationSuccessful
}

$btPipelinesProjectNew.Add_Click({
    # Create a new Pipeline Project
    $NewPipelineProjectName=""
    $NewPipelineProjectName = QuestionPupup -PopupTitle "New Pipeline Project" -QuestionText "New Project name:" -ButtonOKText "Ok" -ButtonCancelText "Nope" -SizeWidth 320 -SizeHeight 150
    if ($NewPipelineProjectName.Length -gt 0)
    {
        PipelinesProjectCreateNew -NewProjectName $NewPipelineProjectName
    }
    else
    {
        LogInfo "No name provided for the new Project."
    }
})

function PipelinesProjectPackage()
{
    # #########
    # Package the pipelines project on the Open-Collector host

    param
    (
        [string] $ProjectName="",
        [int] $TimeOutInSeconds=60
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        try
        {
            LogInfo "Package the pipelines project on the Open-Collector host."
            $ProjectName = $ProjectName.Replace('"',"'")
            $Command=("./OCHelper.sh --PackagePipelineProject '{{""ProjectName"": ""{0}""}}'" -f $ProjectName)
            LogDebug "Command: ""$Command""."
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeOutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to package the Pipelines Project on the Open-Collector host. Exception: {0}." -f $_.Exception.Message)
        }

        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }


        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsOperationSuccessful = $true
            #LogDebug "====== Output dump - BEGIN ======"
            #LogDebug $LastOutputDump
            #LogDebug "====== Output dump - END ======"
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }


    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

function PipelinesProjectInstall()
{
    # #########
    # Install the pipelines project on the Open-Collector host

    param
    (
        [string] $ProjectName="",
        [int] $TimeOutInSeconds=60
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        try
        {
            LogInfo "Install the pipelines project on the Open-Collector host."
            $ProjectName = $ProjectName.Replace('"',"'")
            $Command=("./OCHelper.sh --InstallPipelinePackage '{{""ProjectName"": ""{0}""}}'" -f $ProjectName)
            LogDebug "Command: ""$Command""."
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeOutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to install the Pipelines Project on the Open-Collector host. Exception: {0}." -f $_.Exception.Message)
        }

        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }


        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsOperationSuccessful = $true
            LogDebug "====== Output dump - BEGIN ======"
            LogDebug $LastOutputDump
            LogDebug "====== Output dump - END ======"
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }


    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

$btPipelinesProjectInstall.Add_Click({
    # Package then Install the Pipeline Project
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            $MsgBoxResponse = [System.Windows.MessageBox]::Show("This Package then Install this Project Pipeline in the live Pipeline set of the Open-Collector.`n`nWould  you like continue?",'Open-Collector Pipeline Project Install','YesNo','Warning','No')
            switch  ($MsgBoxResponse) {
              'Yes' {
                try
                {
                    # Go ahead and package/install the Project
                    LogInfo ("User confirmed that packaging and installing the project on the Open-Collector should go ahead. Pipeline project: ""{0}""." -f $dgPipelinesProjectList.SelectedItem.Name)
                    if (PipelinesProjectPackage -ProjectName $dgPipelinesProjectList.SelectedItem.Name)
                    {
                        if (PipelinesProjectInstall -ProjectName $dgPipelinesProjectList.SelectedItem.Name)
                        {
                            GetOpenCollectorInstalledPipeline
                        }
                    }
                }
                catch
                {
                    LogError ("Failed to Package then Install the project. Exception: {0}." -f $_.Exception.Message)
                }
              }
              'No' {
                LogInfo "Decided against packaging and installing the project on the Open-Collector."
              }
            }
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)

})


#PipelinesProjectDelete -ProjectName $dgPipelinesProjectList.SelectedItem.Name
function PipelinesProjectDelete()
{
    # #########
    # Delete the given Project from the Open-Collector host

    param
    (
        [string] $ProjectName=""
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        try
        {
            LogInfo "Delete the Pipelines Project from the Open-Collector host."
            $ProjectName = $ProjectName.Replace('"',"'")
            $Command=("./OCHelper.sh --DeletePipelineProject '{{""ProjectName"": ""{0}""}}'" -f $ProjectName)
            #LogDebug "Command: ""$Command""."
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut 10
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to delete the Pipelines Project from the Open-Collector host. Exception: {0}." -f $_.Exception.Message)
        }



        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }


        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsOperationSuccessful = $true
            #LogDebug "====== Output dump - BEGIN ======"
            #LogDebug $LastOutputDump
            #LogDebug "====== Output dump - END ======"
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }


    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

$btTestTestsDelete.Add_Click({
    # Delete the Pipeline Project
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            $MsgBoxResponse = [System.Windows.MessageBox]::Show("This will delete the Project files from the Open-Collector host.`n`nWould  you like continue and delete it?",'Open-Collector Pipeline project Delete','YesNo','Warning','No')
            switch  ($MsgBoxResponse) {
              'Yes' {
                try
                {
                    # Go ahead and delete the Project
                    LogInfo ("User confirmed that deleting the project on the Open-Collector should go ahead. Pipeline project: ""{0}""." -f $dgPipelinesProjectList.SelectedItem.Name)
                    PipelinesProjectDelete -ProjectName $dgPipelinesProjectList.SelectedItem.Name
                    GetOpenCollectorPipelineProjects
                }
                catch
                {
                    LogError ("Failed to delete the project. Exception: {0}." -f $_.Exception.Message)
                }
              }
              'No' {
                LogInfo "Decided against deleting the project on the Open-Collector."
              }
            }
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)

})

function PipelinesProjectLoadFilter()
{
    # #########
    # Load the Fitler for the given Project from the Open-Collector host

    param
    (
        [string] $ProjectName=""
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        try
        {
            LogInfo "Load the Fitler for the Pipelines Project from the Open-Collector host."
            $ProjectName = $ProjectName.Replace('"',"'")
            $Command=("./OCHelper.sh --GetPipelineProjectFilter '{{""ProjectName"": ""{0}""}}'" -f $ProjectName)
            #LogDebug "Command: ""$Command""."
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut 10
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to load the Filter for the Pipelines Project from the Open-Collector host. Exception: {0}." -f $_.Exception.Message)
        }



        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            if ($LastOutput.length -gt 0)
            {
                try
                {
                    # Clear the field
                    $tbPipelinesProjectEditorFilter.Text=""
                    
                    # Having issues with the end of lines from the OC, hence the funny hoop through jumping exercise
                    $LastOutput.ForEach({$tbPipelinesProjectEditorFilter.AppendText("$_`n")})
                    $IsOperationSuccessful = $true
                }
                catch
                {
                    LogError "Response from OCHelper could not be brought to screen."
                }
            }
        }
        else
        {
            LogError "     \-- Failed."
        }

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

function PipelinesProjectLoadTransform()
{
    # #########
    # Load the Transform for the given Project from the Open-Collector host

    param
    (
        [string] $ProjectName=""
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        try
        {
            LogInfo "Load the Transform for the Pipelines Project from the Open-Collector host."
            $ProjectName = $ProjectName.Replace('"',"'")
            $Command=("./OCHelper.sh --GetPipelineProjectTransform '{{""ProjectName"": ""{0}""}}'" -f $ProjectName)
            #LogDebug "Command: ""$Command""."
            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut 10
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to load the Transform for the Pipelines Project from the Open-Collector host. Exception: {0}." -f $_.Exception.Message)
        }



        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            if ($LastOutput.length -gt 0)
            {
                try
                {
                    # Clear the field
                    $tbPipelinesProjectEditorTransform.Text=""
                    
                    # Having issues with the end of lines from the OC, hence the funny hoop through jumping exercise
                    $LastOutput.ForEach({$tbPipelinesProjectEditorTransform.AppendText("$_`n")})
                    $IsOperationSuccessful = $true
                }
                catch
                {
                    LogError "Response from OCHelper could not be brought to screen."
                }
            }
        }
        else
        {
            LogError "     \-- Failed."
        }

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

function PipelinesProjectSaveFilter()
{
    # #########
    # Save the Filter for the given Project to the Open-Collector host

    param
    (
        [string] $ProjectName = "",
        [string] $NewFilter = "",
        [int] $TimeoutInSeconds = 30
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        LogInfo ("Saving Filter to the Open-Collector, for Project ""{0}""." -f $ProjectName)

        try
        {
            if ($NewFilter.Length -gt 0)
            {
                # {"ProjectName": "%s", "NewFilter": "%s_base64_encoded"}
                $EncodedFilter = Base64-Encode -TextToBase64Encode $NewFilter
            }
            else
            {
                $EncodedFilter=""
            }
            $Command = ("./OCHelper.sh --UpdatePipelineProjectFilter '{{""ProjectName"": ""{0}"", ""NewFilter"": ""{1}""}}'" -f $ProjectName, $EncodedFilter)
            
            #LogDebug ("Command: {0}" -f $Command)

            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send Filter update command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
        }

        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }

        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsOperationSuccessful = $true
            #LogDebug "====== Output dump - BEGIN ======"
            #LogDebug $LastOutputDump
            #LogDebug "====== Output dump - END ======"
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }



        if ($IsOperationSuccessful)
        {
            $StatusText = ("Open Collector configuration imported from disk. File name: ""{0}""." -f $FileName)
            LogInfo $StatusText
            $StatusText = "Open Collector configuration imported from disk."
        }
        else
        {
            $StatusText = "Failed to import Open Collector configuration from disk."
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedOpenCollectorConfigStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}


function PipelinesProjectSaveTransform()
{
    # #########
    # Save the Transform for the given Project to the Open-Collector host

    param
    (
        [string] $ProjectName = "",
        [string] $NewTransform = "",
        [int] $TimeoutInSeconds = 30
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        LogInfo ("Saving Transform to the Open-Collector, for Project ""{0}""." -f $ProjectName)

        try
        {
            if ($NewTransform.Length -gt 0)
            {
                # {"ProjectName": "%s", "NewTransform": "%s_base64_encoded"}
                $EncodedTransform = Base64-Encode -TextToBase64Encode $NewTransform
            }
            else
            {
                $EncodedTransform=""
            }
            $Command = ("./OCHelper.sh --UpdatePipelineProjectTransform '{{""ProjectName"": ""{0}"", ""NewTransform"": ""{1}""}}'" -f $ProjectName, $EncodedTransform)
            
            #LogDebug ("Command: {0}" -f $Command)

            $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeoutInSeconds
            $LastExitStatus = $SHHCommandReturn.ExitStatus
            $LastOutput = $SHHCommandReturn.Output
        }
        catch
        {
            # Oopsy Daisy... Something went wrong
            LogError ("Failed to send Transform update command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
        }

        $LastOutputDump=$LastOutput

        if ($LastOutput.length -gt 0)
        {
            try
            {
                $LastOutput = $LastOutput | ConvertFrom-Json
                try
                {
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                }
                catch
                {
                    LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }

                try
                {
                    $LastOutputDump += "`n`n"
                    $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                }
                catch
                {
                    LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                }
            }
            catch
            {
                LogError "Response JSON could not be decoded."
            }
        }

        if ($LastExitStatus -eq 0)
        {
            LogInfo "     \-- Passed."
            $IsOperationSuccessful = $true
            #LogDebug "====== Output dump - BEGIN ======"
            #LogDebug $LastOutputDump
            #LogDebug "====== Output dump - END ======"
        }
        else
        {
            LogError "     \-- Failed."
            LogError "====== Output dump - BEGIN ======"
            LogError $LastOutputDump
            LogError "====== Output dump - END ======"
        }



        if ($IsOperationSuccessful)
        {
            $StatusText = ("Open Collector configuration imported from disk. File name: ""{0}""." -f $FileName)
            LogInfo $StatusText
            $StatusText = "Open Collector configuration imported from disk."
        }
        else
        {
            $StatusText = "Failed to import Open Collector configuration from disk."
            LogError $StatusText
        }
        
        # Update the Status text field
        UIDispacherInvokeUpdateLabelContent -LabeltoUpdate $lbInstallationAdvancedOpenCollectorConfigStatus -NewContent $StatusText

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

$btPipelinesProjectEditorFilterTest.Add_Click({
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            PipelinesProjectTestFilter -TestAllLogs -ProjectName $dgPipelinesProjectList.SelectedItem.Name
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)
})

$btPipelinesProjectEditorFilterSave.Add_Click({
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            PipelinesProjectSaveFilter -ProjectName $dgPipelinesProjectList.SelectedItem.Name -NewFilter $tbPipelinesProjectEditorFilter.Text
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)
})

$btPipelinesProjectEditorFilterReload.Add_Click({
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            PipelinesProjectLoadFilter -ProjectName $dgPipelinesProjectList.SelectedItem.Name
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)
})

$btPipelinesProjectEditorTransformTest.Add_Click({
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            PipelinesProjectTestTransform -TestAllLogs -ProjectName $dgPipelinesProjectList.SelectedItem.Name
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)
})

$btPipelinesProjectEditorTransformSave.Add_Click({
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            PipelinesProjectSaveTransform -ProjectName $dgPipelinesProjectList.SelectedItem.Name -NewTransform $tbPipelinesProjectEditorTransform.Text
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)
})


$btPipelinesProjectEditorTransformReload.Add_Click({
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            PipelinesProjectLoadTransform -ProjectName $dgPipelinesProjectList.SelectedItem.Name
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)
})


# ##################
# LOG TESTER

function PipelinesProjectTestFilter()
{
    # #########
    # Test the Filter for the given Project to the Open-Collector host against the selected log(s)

    param
    (
        [string] $ProjectName = "",
        [switch] $TestAllLogs = $false, # If false, will only test the selected items
        [int] $TimeoutInSeconds = 30
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($TestAllLogs -and ($dgPipelinesProjectEditorLogSample.Items.Count -le 0))
    {
        LogError "No logs to test against. Doing nothing."
        return $IsOperationSuccessful
    }

    if ((-not $TestAllLogs) -and ($dgPipelinesProjectEditorLogSample.SelectedItems.Count -le 0))
    {
        LogError "No logs selected to test against. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        LogInfo ("Testing the Filter against the selected log(s), for Project ""{0}""." -f $ProjectName)

        if ($TestAllLogs)
        {
            $LogItemsToTest = $dgPipelinesProjectEditorLogSample.Items
        }
        else
        {
            $LogItemsToTest = $dgPipelinesProjectEditorLogSample.SelectedItems
        }

        foreach ($LogToTest in $LogItemsToTest){
            #LogDebug ("LogToTest: {0}" -f $LogToTest.Log)
            try
            {
                #$LogToTest='{  "@timestamp": "2019-07-11T17:07:14.506Z",  "@metadata": {    "beat": "pubsubbeat",    "type": "doc",    "version": "6.2.2"  },  "type": "jzopencollector.localdomain",  "message_id": "612752041643074",  "publish_time": "2019-07-11T17:09:18.383Z",  "message": "{\"insertId\":\"1iy2930f3xqlcs\",\"jsonPayload\":{\"actor\":{\"user\":\"tmasse77@gmail.com\"},\"event_subtype\":\"compute.instances.stop\",\"event_timestamp_us\":\"1562864957188492\",\"event_type\":\"GCE_API_CALL\",\"ip_address\":\"\",\"operation\":{\"id\":\"5235552903964054482\",\"name\":\"operation-1562864956387-58d6ada8eb20b-10b4f0e0-98f06ac0\",\"type\":\"operation\",\"zone\":\"europe-west2-c\"},\"request\":{\"body\":\"null\",\"url\":\"https://www.googleapis.com/compute/v1/projects/dans-project-246409/zones/europe-west2-c/instances/instance-1/stop?key=AIzaSyDSodt0Zfdm6HAYoNjRFro8odqM5qeppJM\"},\"resource\":{\"id\":\"2119558395618573823\",\"name\":\"instance-1\",\"type\":\"instance\",\"zone\":\"europe-west2-c\"},\"trace_id\":\"operation-1562864956387-58d6ada8eb20b-10b4f0e0-98f06ac0\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36,gzip(gfe)\",\"version\":\"1.2\"},\"labels\":{\"compute.googleapis.com/resource_id\":\"2119558395618573823\",\"compute.googleapis.com/resource_name\":\"instance-1\",\"compute.googleapis.com/resource_type\":\"instance\",\"compute.googleapis.com/resource_zone\":\"europe-west2-c\"},\"logName\":\"projects/dans-project-246409/logs/compute.googleapis.com%2Factivity_log\",\"receiveTimestamp\":\"2019-07-11T17:09:17.269030579Z\",\"resource\":{\"labels\":{\"instance_id\":\"2119558395618573823\",\"project_id\":\"dans-project-246409\",\"zone\":\"europe-west2-c\"},\"type\":\"gce_instance\"},\"severity\":\"INFO\",\"timestamp\":\"2019-07-11T17:09:17.188492Z\"}",  "beat": {    "name": "jzopencollector.localdomain",    "hostname": "jzopencollector.localdomain",    "version": "6.2.2"  },  "attributes": {    "logging.googleapis.com/timestamp": "2019-07-11T17:09:17.188492Z"  }}'
                if ($LogToTest.Log.Length -gt 0)
                {
                    # {"ProjectName": "%s", "LogToTest": "%s_base64_encoded"}
                    $EncodedLogToTest = Base64-Encode -TextToBase64Encode $LogToTest.Log
                }
                else
                {
                    $EncodedLogToTest=""
                }
                $Command = ("./OCHelper.sh --TestPipelineProjectFilter '{{""ProjectName"": ""{0}"", ""LogToTest"": ""{1}""}}'" -f $ProjectName, $EncodedLogToTest)
            
                #LogDebug ("Command: {0}" -f $Command)

                $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeoutInSeconds
                $LastExitStatus = $SHHCommandReturn.ExitStatus
                $LastOutput = $SHHCommandReturn.Output
            }
            catch
            {
                # Oopsy Daisy... Something went wrong
                LogError ("Failed to send Filter test command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
            }

            $LastOutputDump=$LastOutput

            if ($LastOutput.length -gt 0)
            {
                try
                {
                    $LastOutput = $LastOutput | ConvertFrom-Json
                    try
                    {
                        $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                    }
                    catch
                    {
                        LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                    }

                    try
                    {
                        $LastOutputDump += "`n`n"
                        $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                    }
                    catch
                    {
                        LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                    }
                }
                catch
                {
                    LogError "Response JSON could not be decoded."
                }
            }

            if ($LastExitStatus -eq 0)
            {
                LogInfo "     \-- Match."
                $IsOperationSuccessful = $true
                $LogToTest.Match="Match"
                #LogDebug "====== Output dump - BEGIN ======"
                #LogDebug $LastOutputDump
                #LogDebug "====== Output dump - END ======"
            }
            else
            {
                LogError "     \-- Failed or No Match."
                $LogToTest.Match="Nope"
                LogError "====== Output dump - BEGIN ======"
                LogError $LastOutputDump
                LogError "====== Output dump - END ======"
            }
        } # foreach ($LogToTest in $dgPipelinesProjectEditorLogSample.SelectedItems){

        # Refresh the table
        $dgPipelinesProjectEditorLogSample.Items.Refresh()

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

function PipelinesProjectTestTransform()
{
    # #########
    # Test the Transform for the given Project to the Open-Collector host against the selected log(s)

    param
    (
        [string] $ProjectName = "",
        [switch] $TestAllLogs = $false, # If false, will only test the selected items
        [int] $TimeoutInSeconds = 30
    )

    $IsOperationSuccessful=$false

    if ($ProjectName.Length -le 0)
    {
        LogError "No project name provided. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($TestAllLogs -and ($dgPipelinesProjectEditorLogSample.Items.Count -le 0))
    {
        LogError "No logs to test against. Doing nothing."
        return $IsOperationSuccessful
    }

    if ((-not $TestAllLogs) -and ($dgPipelinesProjectEditorLogSample.SelectedItems.Count -le 0))
    {
        LogError "No logs selected to test against. Doing nothing."
        return $IsOperationSuccessful
    }

    if ($script:SSHSession.Connected)
    {
        $LastExitStatus = -1
        $LastOutput = ""
        LogInfo ("Testing the Transform against the selected log(s), for Project ""{0}""." -f $ProjectName)

        if ($TestAllLogs)
        {
            $LogItemsToTest = $dgPipelinesProjectEditorLogSample.Items
        }
        else
        {
            $LogItemsToTest = $dgPipelinesProjectEditorLogSample.SelectedItems
        }

        foreach ($LogToTest in $LogItemsToTest){
            try
            {
                if ($LogToTest.Log.Length -gt 0)
                {
                    # {"ProjectName": "%s", "LogToTest": "%s_base64_encoded"}
                    $EncodedLogToTest = Base64-Encode -TextToBase64Encode $LogToTest.Log
                }
                else
                {
                    $EncodedLogToTest=""
                }
                $Command = ("./OCHelper.sh --TestPipelineProjectTransform '{{""ProjectName"": ""{0}"", ""LogToTest"": ""{1}""}}'" -f $ProjectName, $EncodedLogToTest)
            
                #LogDebug ("Command: {0}" -f $Command)

                $SHHCommandReturn = Invoke-SSHCommand -SSHSession $script:SSHSession -Command ($Command) -TimeOut $TimeoutInSeconds
                $LastExitStatus = $SHHCommandReturn.ExitStatus
                $LastOutput = $SHHCommandReturn.Output
            }
            catch
            {
                # Oopsy Daisy... Something went wrong
                LogError ("Failed to send Transform Test command to the Open-Collector. Exception: {0}." -f $_.Exception.Message)
            }

            $LastOutputDump=$LastOutput

            if ($LastOutput.length -gt 0)
            {
                try
                {
                    $ResultTransform=""
                    $LastOutput = $LastOutput | ConvertFrom-Json
                    try
                    {
                        $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Error)
                    }
                    catch
                    {
                        LogError ("Response.Error could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                    }

                    try
                    {
                        $LastOutputDump += "`n`n"
                        $LastOutputDump = $(Base64-Decode -Base64EncodedText $LastOutput.Result)
                        # LRJQ_Parsing_Result: {....
                        if($(Base64-Decode -Base64EncodedText $LastOutput.Result) -match '[^"]LRJQ_Parsing_Result:\s*(?<Transform>.+)')
                        {
                            $ResultTransform=$Matches.Transform
                        }
                    }
                    catch
                    {
                        LogError ("Response.Result could not be Base64 decoded. Exception: {0}." -f $_.Exception.Message)
                    }
                }
                catch
                {
                    LogError "Response JSON could not be decoded."
                }
            }

            if ($LastExitStatus -eq 0)
            {
                LogInfo "     \-- Transformed."
                $LogToTest.TransformOutput = $ResultTransform
                $IsOperationSuccessful = $true
                #LogDebug "====== Output dump - BEGIN ======"
                #LogDebug $LastOutputDump
                #LogDebug "====== Output dump - END ======"
            }
            else
            {
                LogError "     \-- Failed or No Transform."
                $LogToTest.TransformOutput = ("*ERROR*: {0}" -f $ResultTransform)
                LogError "====== Output dump - BEGIN ======"
                LogError $LastOutputDump
                LogError "====== Output dump - END ======"
            }
        } # foreach ($LogToTest in $dgPipelinesProjectEditorLogSample.SelectedItems){

        # Refresh the table
        $dgPipelinesProjectEditorLogSample.Items.Refresh()

    } # if ($script:SSHSession.Connected)

    return $IsOperationSuccessful
}

$btPipelinesProjectEditorLogSampleTest.Add_Click({
    if ($dgPipelinesProjectList.SelectedIndex -ge 0)
    {
        if ($dgPipelinesProjectList.SelectedItem.Name.Length -gt 0)
        {
            if ($dgPipelinesProjectEditorLogSample.SelectedItems.Count -gt 0)
            {
                # Only do the selected logs
                PipelinesProjectTestFilter -ProjectName $dgPipelinesProjectList.SelectedItem.Name
                PipelinesProjectTestTransform -ProjectName $dgPipelinesProjectList.SelectedItem.Name
            }
            else
            {
                # No selected logs, test them all
                PipelinesProjectTestFilter -ProjectName $dgPipelinesProjectList.SelectedItem.Name -TestAllLogs
                PipelinesProjectTestTransform -ProjectName $dgPipelinesProjectList.SelectedItem.Name -TestAllLogs
            }
        }
    } # if ($dgPipelinesProjectList.SelectedIndex -ge 0)
})

$btPipelinesProjectEditorLogSampleLoadFromFile.Add_Click({
    #$dgPipelinesProjectEditorLogSample.Items
    $LogFileToImport = Get-FileName -Filter "Log files (*.log;*.json;*.txt;*.csv)|*.log;*.json;*.txt;*.csv|All files (*.*)| *.*" -Title "Open an Log sample file" -CheckFileExists -InitialDirectory $script:LastBrowsePath
    if ($LogFileToImport.Length -gt 0)
    {
        PipelinesProjectEditorLogSampleLoadFromFile -FileName $LogFileToImport
    }
})

function PipelinesProjectEditorLogSampleLoadFromFile()
{
    # #########
    # Load log sample file

    param
    (
		[Parameter(Mandatory)]
        [string] $FileName
    )

    $IsOperationSuccessful=$false

    LogInfo ("Load log sample file from ""{0}""." -f $FileName)
            
    if (Test-Path $FileName)
    {
        LogInfo ("  \-- File exists. That's a good start." -f $FileName)

        try
        {
            LogInfo ("  \-- Loading log lines from file..." -f $FileName)

            $LogLinesFound=0
            $LogLinesLoaded=0

            foreach($LogLine in Get-Content -Path $FileName) {
                $LogLinesFound++
                $IsOperationSuccessful=$true
                if($LogLine.Length -gt 0)
                {
                    try
                    {
                        $NewLogItem = Select-Object -inputobject "" GUID,Log, Match, TransformOutput
                        
                        $NewLogItem.GUID = New-Guid
                        $NewLogItem.Log = ("{0}" -f $LogLine)
                        $NewLogItem.Match = "*Not tested*"
                        $NewLogItem.TransformOutput = "*Not tested*"

                        $dgPipelinesProjectEditorLogSample.Items.Add($NewLogItem)
                        $LogLinesLoaded++
                    }
                    catch
                    {
                        # Oopsy Daisy... Something went wrong
                        LogError ("Failed to import line from Log File. Exception: {0}." -f $_.Exception.Message)
                    }
                }
            }
            LogInfo ("   \-- Loaded {0} log lines (out of {1} lines from the file)." -f $LogLinesLoaded, $LogLinesFound)


        }
        catch
        {
	        LogError "  \-- Could not load Log file."
        }

    }
    else 
    {
	    LogInfo ("Log Sample file ""{0}"" doesn't exists." -f $FileName)
    }


    return $IsOperationSuccessful
}

$btPipelinesProjectEditorLogSampleExportToFile.Add_Click({
    # #########
    # Export log sample output to file

    $TestOutputFileToExportTo = Set-FileName -Filter "Text File - Transform Only (*.txt)|*.txt|Comma Separated File (*.csv)|*.csv|XML File (*.xml)|*.xml|JSON File (*.json)|*.json|All files (*.*)| *.*" -Title "Export Test Output to File" -InitialDirectory $script:LastBrowsePath -FileName ("{0}.OpenCollector Log Test Output Export.txt" -f (Get-Date).tostring("yyyy.MM.dd_HH.mm.ss")) -OverwritePrompt
    if ($TestOutputFileToExportTo.Length -gt 0)
    {
        # Find the extension
        $ExportFileExtension=".txt"
        try
        {
            $ExportFileExtension=[IO.Path]::GetExtension($TestOutputFileToExportTo)
        }
        catch
        {
            LogError ("Failed to determinate the extension of the choosen file. Exception: {0}." -f $_.Exception.Message)
        }

        switch -wildcard ($ExportFileExtension) {
            ".txt"
            {
                try
                {
                    $dgPipelinesProjectEditorLogSample.Items.ForEach( { $_.TransformOutput }) | Out-File -FilePath $TestOutputFileToExportTo -Force
                }
                catch
                {
                    LogError ("Failed to export to ""{1}"". Exception: {0}." -f $_.Exception.Message, $TestOutputFileToExportTo)
                }
                break
            }
            ".csv"
            {
                try
                {
                    $dgPipelinesProjectEditorLogSample.Items | select Log,Match,TransformOutput | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $TestOutputFileToExportTo -Force
                }
                catch
                {
                    LogError ("Failed to export to ""{1}"". Exception: {0}." -f $_.Exception.Message, $TestOutputFileToExportTo)
                }
                break
            }
            ".xml"
            {
                try
                {
                    $dgPipelinesProjectEditorLogSample.Items | select Log,Match,TransformOutput | ConvertTo-Xml -NoTypeInformation -As "String" -Depth 5 | Out-File -FilePath $TestOutputFileToExportTo -Force
                }
                catch
                {
                    LogError ("Failed to export to ""{1}"". Exception: {0}." -f $_.Exception.Message, $TestOutputFileToExportTo)
                }
                break
            }
            ".json"
            {
                try
                {
                    $dgPipelinesProjectEditorLogSample.Items | select Log,Match,TransformOutput | ConvertTo-Json -Depth 5 | Out-File -FilePath $TestOutputFileToExportTo -Force
                }
                catch
                {
                    LogError ("Failed to export to ""{1}"". Exception: {0}." -f $_.Exception.Message, $TestOutputFileToExportTo)
                }
                break
            }
            default 
            {
                try
                {
                    LogInfo "Did not recognise the file extension. Falling back to default Text format (only Trasnform output)."
                    $dgPipelinesProjectEditorLogSample.Items.ForEach( { $_.TransformOutput }) | Out-File -FilePath $TestOutputFileToExportTo -Force
                }
                catch
                {
                    LogError ("Failed to export to ""{1}"". Exception: {0}." -f $_.Exception.Message, $TestOutputFileToExportTo)
                }
                break
            }
        } # switch -wildcard ($ExportFileExtension) {
        
    }
})

$btPipelinesProjectEditorLogSampleDeleteLog.Add_Click({
    # #########
    # Delete log sample items

    LogInfo ("Deleting {0} Log Sample item(s)" -f $dgPipelinesProjectEditorLogSample.SelectedItems.Count)
    try
    {
        while ($dgPipelinesProjectEditorLogSample.SelectedItems.Count -gt 0)
        {
            $dgPipelinesProjectEditorLogSample.Items.remove($dgPipelinesProjectEditorLogSample.SelectedItems[$dgPipelinesProjectEditorLogSample.SelectedItems.count -1])
        } # while ($dgPipelinesProjectEditorLogSample.SelectedItems.Count -gt 0)
    }
    catch
    {
        LogError ("Problem while deleting Log Sample item(s). Exception: {0}." -f $_.Exception.Message)
    }
    $dgPipelinesProjectEditorLogSample.Items.Refresh()
})



#  8888888888                                     888    d8b                   
#  888                                            888    Y8P                   
#  888                                            888                          
#  8888888    888  888  .d88b.   .d8888b 888  888 888888 888  .d88b.  88888b.  
#  888        `Y8bd8P' d8P  Y8b d88P"    888  888 888    888 d88""88b 888 "88b 
#  888          X88K   88888888 888      888  888 888    888 888  888 888  888 
#  888        .d8""8b. Y8b.     Y88b.    Y88b 888 Y88b.  888 Y88..88P 888  888 
#  8888888888 888  888  "Y8888   "Y8888P  "Y88888  "Y888 888  "Y88P"  888  888 
#                                                                              
#                                                                              
#                                                                              

########################################################################################################################
##################################################### Execution!!  #####################################################
########################################################################################################################

# Run the UI
$OCUIForm.ShowDialog() | out-null

# Disconnect any left over connections
SSHDisconnect

# Save the configuration
SaveConfigXML

# Time to depart, my old friend...
LogInfo "Exiting Open-Collector Helper"
# Didn't we have a joly good time?
