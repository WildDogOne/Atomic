Clear-Host
. "config.ps1"
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)

$atomics = Get-Content C:\temp\atomics.txt
foreach ($atomic in $atomics)
{
    $t = $atomic.Split(" ")[0]
    if ($t -match "T1003.001")
    {
        $sess = New-PSSession -ComputerName $target -Credential $psCred
        Invoke-AtomicTest $t -Session $sess -GetPrereqs
        Invoke-AtomicTest $t -Session $sess -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath "c:\temp\execution\$t.json"
        Remove-PSSession $sess
    }
}

$sess = New-PSSession -ComputerName $target -Credential $psCred
#Invoke-AtomicTest T1003.001 -ShowDetailsBrief
#Invoke-AtomicTest T1003.001 -Session $sess -GetPrereqs -TestNumbers 7
#Invoke-AtomicTest T1003.001 -Session $sess -TestNumbers 7
Remove-PSSession $sess