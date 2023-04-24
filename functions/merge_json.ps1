$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

# Set the path to the folder containing the JSON files you want to merge
$folderPath = $ScriptDir + "\execution"

# Get all JSON files in the folder
$jsonFiles = Get-ChildItem -Path $folderPath -Filter *.json

# Initialize an empty array to store the merged content
$mergedJson = @()

# Iterate over each JSON file
foreach ($file in $jsonFiles) {
    if ($file.Name.StartsWith("T")) {
        $content = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        $mergedJson += $content
    }
}

# Convert the merged content back to JSON and write it to a new file, 'merged.json', in the target directory
$mergedJson | ConvertTo-Json | Set-Content -Path (Join-Path $folderPath "merged.json")
