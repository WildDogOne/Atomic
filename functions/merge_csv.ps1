$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

# Set the path to the folder containing the JSON files you want to merge
$folderPath = $ScriptDir + "\execution"

# Get all CSV files in the folder
$csvFiles = Get-ChildItem -Path $folderPath -Filter *.csv

# Initialize an empty array to store the merged content
$mergedCsv = @()

# Iterate over each CSV file
foreach ($file in $csvFiles)
{
    if ( $file.Name.StartsWith("T"))
    {
        $content = Import-Csv -Path $file.FullName
        $mergedCsv += $content
    }
}

# Write the merged content to a new file, 'merged.csv', in the target directory
$mergedCsv | Export-Csv -Path (Join-Path $folderPath "merged.csv") -NoTypeInformation
