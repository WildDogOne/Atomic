param (
    [bool]$remote = $false,
    [String]$remoteHost,
    [bool]$test_atomic = $false,
    [bool]$test_sentinel = $true
)
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
. "$ScriptDir\config.ps1"
. "$ScriptDir\functions\functions.ps1"

$atomics = Get-ChildItem "$ScriptDir\atomics"
$sentinel_rules = @{ }


if ($remote)
{
    $hostname = $remoteHost
    if ($remoteHost -eq $null)
    {
        Write-Host "Please specify a remote host to run the tests against"
        exit
    }
    $psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)
}
else
{
    $hostname = [System.Net.Dns]::GetHostName()
}

if ($test_atomic)
{
    # Process each atomic
    foreach ($atomic in $atomics)
    {
        $name = $atomic.Name
        if ($remote)
        {
            # Run atomic tests remotely
            $sess = New-PSSession -ComputerName $target -Credential $psCred
            Invoke-AtomicTest $name -Session $sess -GetPrereqs -PathToAtomicsFolder "$ScriptDir\atomics"
            Invoke-AtomicTest -TimeoutSeconds 60 $name -Session $sess -PathToAtomicsFolder "$ScriptDir\atomics"
            Invoke-AtomicTest -TimeoutSeconds 60 $name -Session $sess -PathToAtomicsFolder "$ScriptDir\atomics" -Cleanup
            Remove-PSSession $sess
        }
        else
        {
            # Run the atomic test
            Invoke-AtomicTest -TimeoutSeconds 60 $name -PathToAtomicsFolder "$ScriptDir\atomics"
            # Cleanup the atomic test
            Invoke-AtomicTest -TimeoutSeconds 60 $name -PathToAtomicsFolder "$ScriptDir\atomics" -Cleanup
        }

        # Load the YAML file
        $yamlFilePath = "$ScriptDir/atomics/$name/$name.yaml"
        $yamlData = Load-Yaml -filePath $yamlFilePath

        # Add Sentinel Detection Rules to sentinel_rules hashtable
        foreach ($atomic_test in $yamlData.atomic_tests)
        {
            if ($atomic_test.detection_type -eq "sentinel")
            {
                foreach ($detection_rule in $atomic_test.detection_rules)
                {
                    $sentinel_rules.Add($detection_rule, $False)
                }
            }
        }
    }
    $sentinel_rules | Export-Clixml -Path "$ScriptDir/data/sentinel_rules.xml"
    # Now we sleep for an hour to allow the Sentinel Rules to trigger
    #Start-Sleep -Seconds 3600
}

if ($test_sentinel)
{
    $sentinel_rules = Import-Clixml -Path "$ScriptDir/data/sentinel_rules.xml"
    # Define the time range
    $startTime = (Get-Date).ToUniversalTime().AddHours(-2).ToString("yyyy-MM-ddTHH:mm:ssZ")
    $endTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    # Fetch all alerts from the last 24 hours
    $allAlerts = Get-SentinelAlerts -startTime $startTime -endTime $endTime -pageSize $pageSize -appId $appId -appSecret $appSecret -tenantId $tenantId

    # Update sentinel_rules based on alerts
    $updated_sentinel_rules = @{
    }
    foreach ($sentinel_rule in $sentinel_rules.keys)
    {
        foreach ($alert in $allAlerts)
        {
            if ($alert.title.StartsWith($sentinel_rule, 'CurrentCultureIgnoreCase') -and $alert.hostStates.netBiosName -eq $hostname)
            {
                $updated_sentinel_rules[$sentinel_rule] = $True
                break
            }
        }
        if (-not $updated_sentinel_rules.ContainsKey($sentinel_rule))
        {
            $updated_sentinel_rules[$sentinel_rule] = $sentinel_rules[$sentinel_rule]
        }
    }
    $sentinel_rules = $updated_sentinel_rules

    # Display the results
    foreach ($sentinel_rule in $sentinel_rules.keys)
    {
        if ($sentinel_rules[$sentinel_rule] -eq $False)
        {
            Write-Host "The Sentinel Rule '$sentinel_rule' did not trigger during Atomic Tests" -ForegroundColor Red
        }
        elseif ($sentinel_rules[$sentinel_rule] -eq $True)
        {
            Write-Host "The Sentinel Rule '$sentinel_rule' triggered during Atomic Tests" -ForegroundColor Green
        }
    }
    $sentinel_rules.keys | Select @{ l = 'Rule'; e = { $_ } }, @{ l = 'Triggered'; e = { $sentinel_rules.$_ } }
    return $sentinel_rules
}

