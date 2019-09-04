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
# ################
#
# TO DO
# - Save credentials in a safe way
# - In InstallationDeployOCHelper, do Steps 2. (use local host to download OCHelper) and 3. (use local cached copy of OCHelper)
# - Install tab, Save the Options to the Config file
# - Install tab, Read the Options from the Config file
# - Everything else...
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
$VersionNumber = "0.9"
$VersionDate   = "2019-08-09"
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
# "" extracted on  from ".\.xaml".
# Sanitised                          : False
# Raw XAML Size                      : ?? bytes
# Compressed XAML Size               : ?? bytes (saving: ?? bytes)
# Base64 Encoded Compressed XAML Size: ?? bytes (saving: ?? bytes)

$OC_UIvX_X = ""

$stXAML = Get-Base64DecodedDecompressedXML -Base64EncodedCompressedXML $OC_UIvX_X

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
        [Diagnostics.Process]::Start($LRCommunityURL,’arguments‘) | Out-Null
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
