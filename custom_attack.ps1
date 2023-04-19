$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
. ".\config.ps1"
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)
$sess = New-PSSession -ComputerName $target -Credential $psCred
#Invoke-AtomicTest All -PathToAtomicsFolder $ScriptDir\atomics -ShowDetailsBrief
#Invoke-AtomicTest All -PathToAtomicsFolder .\atomics -ShowDetailsBrief
Invoke-AtomicTest -TimeoutSeconds 60 test -Session $sess -PathToAtomicsFolder .\atomics
Remove-PSSession $sess