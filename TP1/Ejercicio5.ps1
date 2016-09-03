<#
.SYNOPSIS
Escribe en un archivo un listado de los procesos que más utilización de memoria tienen
.DESCRIPTION
Escribe en c:\process-running.txt, cada N segundos, un listado de los M procesos que más utilización de memoria tienen

Especificando por cada uno de ellos la siguiente información:
Identificador (PID) – Path del ejecutable – Memoria (Working Set).
.PARAMETER N
Segundos entre actualizacion del archivo
Si N es igual a 0, entonces la información se guardará sólo una vez. En caso de N mayor a cero, la información se actualizará cada N segundos.
.PARAMETER M
Cantidad de procesos a mostrar
.EXAMPLE
Ejercicio5.ps1 -M 10 -N 5
#>

[Cmdletbinding()]
param(
    [Parameter(Mandatory=$true)][int]$M,
    [Parameter(Mandatory=$false)][int]$N
)
$saveFile = "c:\process-running.txt";
$action = {
    # Get all processes > sort them by WorkingSize > Get M first of them > Save result table to file
    Get-WmiObject -Class Win32_Process | sort -Descending WorkingSetSize | select -first $M ProcessId, ExecutablePath, WorkingSetSize | Out-File $saveFile
}
$timer
if($N -gt 0) {
    $timer = New-Object System.Timers.Timer
    $timer.Interval = ($N * 1000)
    # Removing previous handler (if present)
    Unregister-Event -ErrorAction SilentlyContinue listProcessTimerIntervalElapsed
    # Attaching new handler and starting timer
    Register-ObjectEvent -InputObject $timer -EventName elapsed -SourceIdentifier listProcessTimerIntervalElapsed -Action $action
    $timer.Start()
} else {
    # Single run
    # Immediate invocation of saved script
    Invoke-Command -scriptblock  $action
    Write-Host "Procesos corriendo salvados en $saveFile"
}
