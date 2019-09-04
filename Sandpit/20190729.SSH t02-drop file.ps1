
if ((get-module PoSH-SSH -ListAvailable).Count -lt 1)
{
    # the right module is not installed
    #find-module PoSH-SSH
    #install-module PoSH-SSH
    Start-Process powershell -Verb runAs "install-module PoSH-SSH"
}
else
{

    #Get-Command -Module posh-ssh

    # #######################
    # Build up connection configuration

    $HostIP = '192.168.101.120'

    $HostUser = 'root'
    $HostPass = convertto-securestring 'logrhythm!1' -asplaintext -force

    $HostCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $HostUser, $HostPass

    # #######################
    # Connect

    $SSHSession = New-SSHSession -ComputerName $HostIP -Port 22 -Credential $HostCreds -KeepAliveInterval 100

    # #######################
    # Run command

    Get-SSHSession

    $SHHCommandReturn = Invoke-SSHCommand -SSHSession $SSHSession -Command "uname" -TimeOut 2

    if ($SHHCommandReturn.ExitStatus -eq 0)
    {
        $SHHCommandReturn.Output
        $SHHCommandReturn.Duration.TotalMilliseconds
    }
    else
    {
        # Something went wrong
        $SHHCommandReturn.Error
        $SHHCommandReturn.Output
    }

    Get-SSHSession

$TextToAdd = @"
Tony
Bidule
"@


    $SSHStream = New-SSHShellStream -SSHSession $SSHSession
    if ($SSHStream.CanWrite)
    {
        #start-sleep -Seconds 1 # Not sure why, but if I try to to Write to it immediatly, it does nothing...
        $SSHStream.WriteLine("cat >> /tmp/tm.txt")
        Start-Sleep -Milliseconds 100
        $SSHStream.WriteLine("Tony")
        $SSHStream.WriteLine("Bidule")
        $SSHStream.Write([char]4)
<#
$commandAndText = @"
cat > /tmp/tm.txt

Tony
Bidule

"@
        #$commandAndText = $commandAndText + 0x03
        $SSHStream.Write($commandAndText)
#>
    }
    $SSHStream.Read()
    Start-Sleep -Milliseconds 500
    $SSHStream.Dispose()
    Get-SSHSession

    # #######################
    # Disconnect then clear up all connections

    $SSHSessions = Get-SSHSession
    foreach ($SSHSession_ in $SSHSessions)
    {
        try
        {
            $SSHSession_.Disconnect()
            Remove-SSHSession -SSHSession $SSHSession_ | Out-Null
        }
        catch
        {
            # Failed to disconnect
        }
    }

    Get-SSHSession
}
