function Load-Yaml
{
    param (
        [string]$filePath
    )

    # Import the PowerShellYaml module if it's not already loaded
    if (-not(Get-Module -Name "powershell-yaml"))
    {
        Import-Module -Name "powershell-yaml"
    }

    # Read the YAML file and convert its contents to a PowerShell object
    $yamlContent = Get-Content -Path $filePath -Raw
    $yamlObject = ConvertFrom-Yaml -Yaml $yamlContent

    return $yamlObject
}

function Get-SentinelAlerts
{
    param (
        [string]$startTime,
        [string]$endTime,
        [int]$pageSize,
        [string]$appId,
        [string]$appSecret,
        [string]$tenantId
    )
    # Get an access token for Microsoft Graph API
    $body = @{
        "grant_type" = "client_credentials"
        "client_id" = $appId
        "client_secret" = $appSecret
        "scope" = "https://graph.microsoft.com/.default"
    }
    $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $body -ContentType "application/x-www-form-urlencoded"
    $accessToken = $tokenResponse.access_token


    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }

    $alertsUrl = "https://graph.microsoft.com/v1.0/security/alerts?`$filter=createdDateTime ge $startTime and createdDateTime le $endTime&`$top=$pageSize"
    $alertsResponse = Invoke-RestMethod -Uri $alertsUrl -Method GET -Headers $headers

    $allAlerts = @()
    $allAlerts += $alertsResponse.value

    while ($alertsResponse.'@odata.nextLink')
    {
        $alertsUrl = $alertsResponse.'@odata.nextLink'
        $alertsResponse = Invoke-RestMethod -Uri $alertsUrl -Method GET -Headers $headers
        $allAlerts += $alertsResponse.value
        if ($alertsResponse.value.Length -le 0)
        {
            write-host "No more alerts"
            break
        }
    }
    return $allAlerts
}
