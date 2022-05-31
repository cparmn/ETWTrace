function start-trace([string]$Provider) {
$ProviderTest = $(logman query providers $Provider)
if (!($ProviderTest -clike "*The command completed successfully*"))
{
write-host "$Provider invalid ETW Provider"
return
}
if(!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    write-host "Run as Admin"
    return
    }
$time=$(get-date -UFormat %s -Millisecond 0)
if (!(Test-Path $env:USERPROFILE\ETW))
   {
    write-host "creating Directory $env:USERPROFILE\ETW"
    mkdir "$env:USERPROFILE/ETW"
   }
$Location = Get-Location
Set-location "$env:USERPROFILE\ETW"
logman start "ETWTrace" -p $Provider 0xFFFFFFFFFFFFFFFF 0xFF -o "$Provider.$time.etl" -ets
Write-Host -NoNewLine 'Press any key to continue...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
logman stop "ETWTrace" -ets
tracerpt "$Provider.$time.etl" -o "$Provider.$time.evtx" -of EVTX -lr
Write-Host "Created $env:USERPROFILE\ETW\$Provider.$time.evtx"
Set-Location $Location
eventvwr.exe /l:"$env:USERPROFILE\ETW\$Provider.$time.evtx"
}
start-trace $args[0]
