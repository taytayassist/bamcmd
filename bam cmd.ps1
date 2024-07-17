﻿Clear-Host

Write-Host @"
╔════╗╔═══╗╔╗  ╔╗╔╗   ╔═══╗╔═══╗    ╔═══╗╔══╗╔═══╗╔═╗ ╔╗╔═══╗╔════╗╔╗ ╔╗╔═══╗╔═══╗╔═══╗
║╔╗╔╗║║╔═╗║║╚╗╔╝║║║   ║╔═╗║║╔═╗║    ║╔═╗║╚╣╠╝║╔═╗║║║╚╗║║║╔═╗║║╔╗╔╗║║║ ║║║╔═╗║║╔══╝║╔═╗║
╚╝║║╚╝║║ ║║╚╗╚╝╔╝║║   ║║ ║║║╚═╝║    ║╚══╗ ║║ ║║ ╚╝║╔╗╚╝║║║ ║║╚╝║║╚╝║║ ║║║╚═╝║║╚══╗║╚══╗
  ║║  ║╚═╝║ ╚╗╔╝ ║║ ╔╗║║ ║║║╔╗╔╝    ╚══╗║ ║║ ║║╔═╗║║╚╗║║║╚═╝║  ║║  ║║ ║║║╔╗╔╝║╔══╝╚══╗║
 ╔╝╚╗ ║╔═╗║  ║║  ║╚═╝║║╚═╝║║║║╚╗    ║╚═╝║╔╣╠╗║╚╩═║║║ ║║║║╔═╗║ ╔╝╚╗ ║╚═╝║║║║╚╗║╚══╗║╚═╝║
 ╚══╝ ╚╝ ╚╝  ╚╝  ╚═══╝╚═══╝╚╝╚═╝    ╚═══╝╚══╝╚═══╝╚╝ ╚═╝╚╝ ╚╝ ╚══╝ ╚═══╝╚╝╚═╝╚═══╝╚═══╝
                                                                                       
                                                                                      
"@ -ForegroundColor Red
Write-Host ""
Write-Host "  - Hecho por @taylorcore00 - " -ForegroundColor red -NoNewline
Write-Host ""
function Test-Admin {;$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent());$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);}
if (!(Test-Admin)) {
    Write-Warning "Ejecutalo como administrador"
    Start-Sleep 10
    Exit
}

Start-Sleep -s 3

Clear-Host

$host.privatedata.ProgressForegroundColor = "red";
$host.privatedata.ProgressBackgroundColor = "black";

$pathsFilePath = "paths.txt"
if(-Not(Test-Path -Path $pathsFilePath)){
    Write-Warning "El archivo $pathsFilePath no existe."
    Start-Sleep 10
    Exit
}

$paths = Get-Content "paths.txt"
$stopwatch = [Diagnostics.Stopwatch]::StartNew()

$results = @()
$count = 0
$totalCount = $paths.Count
$progressID = 1

foreach ($path in $paths) {
    $progress = [int]($count / $totalCount * 100)
    Write-Progress -Activity "Escaneando paths..." -Status "$progress% Complete:" -PercentComplete $progress -Id $progressID
    $count++

    Try {
        $fileName = Split-Path $path -Leaf
        $signatureStatus = (Get-AuthenticodeSignature $path 2>$null).Status

        $fileDetails = New-Object PSObject
        $fileDetails | Add-Member Noteproperty Name $fileName
        $fileDetails | Add-Member Noteproperty Path $path
        $fileDetails | Add-Member Noteproperty SignatureStatus $signatureStatus

        $results += $fileDetails
    } Catch {
    }
}

$stopwatch.Stop()

$time = $stopwatch.Elapsed.Hours.ToString("00") + ":" + $stopwatch.Elapsed.Minutes.ToString("00") + ":" + $stopwatch.Elapsed.Seconds.ToString("00") + "." + $stopwatch.Elapsed.Milliseconds.ToString("000")

Write-Host ""
Write-Host "El scan fue terminado en $time ." -ForegroundColor Yellow

$results | Out-GridView -PassThru -Title 'Signatures resultados'