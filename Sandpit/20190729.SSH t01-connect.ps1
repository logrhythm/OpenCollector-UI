
if ((get-module PoSH-SSH -ListAvailable).Count -lt 1)
{
    # the right module is not installed
    #find-module PoSH-SSH
    #install-module PoSH-SSH
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

    $Session = New-SSHSession -ComputerName $HostIP -Port 22 -Credential $HostCreds -KeepAliveInterval 100

    # #######################
    # Run command - Short output

    $SHHCommandReturn = Invoke-SSHCommand -SSHSession $Session -Command "uname" -TimeOut 2

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

    # #######################
    # Run command - Long output

    $SHHCommandReturn = Invoke-SSHCommand -SSHSession $Session -Command "ls -lh" -TimeOut 2

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

    # #######################
    # Run command - Long input

    try
    {
        # Works:
        #$SHHCommandReturn = Invoke-SSHCommand -SSHSession $Session -Command ("echo " + "aaa$'\n'bbb" + " >> /tmp/tm.txt") -TimeOut 2
        $SHHCommandReturn = Invoke-SSHCommand -SSHSession $Session -Command ("cat >> /tmp/tm.txt" + ([char]13) + "Bidule" + ([char]13) + "Machin" + ([char]4)) -TimeOut 2

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
    }
    catch
    {
        # Something went wrong
        $_.Exception.Message
    }

    # #######################
    # Disconnect then clear up all connections

    Write-Host "Disconnect then clear up all connections"

    $Sessions = Get-SSHSession
    foreach ($Session in $Sessions)
    {
        try
        {
            $Session.Disconnect()
            Remove-SSHSession -SSHSession $Session | Out-Null
        }
        catch
        {
            # Failed to disconnect
        }
    }

    Get-SSHSession
}
