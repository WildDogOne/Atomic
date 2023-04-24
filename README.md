# Sentinel Alert Test Script

This script is designed to test Microsoft Sentinel alerts by simulating events using Atomic Red Team tests.
It checks whether specific Sentinel analytics rules are triggered during the tests and provides a summary of the
results.

## Prerequisites

- PowerShell 5.1 or later
- PowerShellYaml module installed
  ```
  Install-Module -Name "PowerShellYaml" -Scope CurrentUser
  ```

## Usage

1. Clone the repository or download the script files.
2. Place the scripts in the desired folder, maintaining the folder structure as follows:
   ```
   .
   ├── config.ps1
   ├── functions
   │   └── functions.ps1
   ├── atomics
   │   └── test
   │       └── test.yaml
   └── sentinel-alert-test.ps1
   ```
3. Configure the `config.ps1` file with the necessary values for the Azure AD App:
   ```
   $appId = "your_app_id"
   $appSecret = "your_app_secret"
   $tenantId = "your_tenant_id"
   $pageSize = 500 # This value can be adjusted based on your needs.
   ```
4. Run the `sentinel-alert-test.ps1` script in PowerShell:
   ```
   .\sentinel-alert-test.ps1
   ```

The script will perform the following steps:

1. Load the necessary functions and configuration.
2. Retrieve the host's name.
3. Iterate through the "atomics" folder, looking for specific atomic tests (in this case, it's set to look for a folder
   named "test").
4. Load the YAML file for the atomic test and extract the Sentinel detection rules.
5. Define a time range to fetch alerts from the last 24 hours.
6. Fetch all alerts for the specified time range.
7. Iterate through the alerts and update the Sentinel rules hashtable based on the alerts.
8. Display the results, indicating which Sentinel rules were triggered during the Atomic tests.

Alternatively you can use the atomic_test.ps1 to only run the atomic tests.
And at a later time sentinel_test.ps1 to only check the sentinel rules.
The state of the atomic tests will be written into data/sentinel_rules.xml