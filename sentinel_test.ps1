$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
. "$ScriptDir\config.ps1"
. "$ScriptDir\functions\functions.ps1"

$hostname = [System.Net.Dns]::GetHostName()

$sentinel_rules = Import-Clixml -Path "$ScriptDir/data/sentinel_rules.xml"
# Now we sleep for an hour to allow the Sentinel Rules to trigger
#Start-Sleep -Seconds 3600

# Define the time range
$startTime = (Get-Date).ToUniversalTime().AddHours(-2).ToString("yyyy-MM-ddTHH:mm:ssZ")
$endTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Fetch all alerts from the last 24 hours
$allAlerts = Get-SentinelAlerts -startTime $startTime -endTime $endTime -pageSize $pageSize -appId $appId -appSecret $appSecret -tenantId $tenantId

# Update sentinel_rules based on alerts
$updated_sentinel_rules = @{ }
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