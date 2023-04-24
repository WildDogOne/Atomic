$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
. "$ScriptDir\config.ps1"
. "$ScriptDir\functions\functions.ps1"

$hostname = [System.Net.Dns]::GetHostName()
$atomics = Get-ChildItem "$ScriptDir\atomics"
$sentinel_rules = @{ }

# Process each atomic
foreach ($atomic in $atomics)
{
    if ($atomic.Name -ne "registry_events")
    {
        $name = $atomic.Name
        # Run the atomic test
        Invoke-AtomicTest -TimeoutSeconds 60 $name -PathToAtomicsFolder "$ScriptDir\atomics"
        # Cleanup the atomic test
        Invoke-AtomicTest -TimeoutSeconds 60 $name -PathToAtomicsFolder "$ScriptDir\atomics" -Cleanup
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
}
$sentinel_rules | Export-Clixml -Path "$ScriptDir/data/sentinel_rules.xml"