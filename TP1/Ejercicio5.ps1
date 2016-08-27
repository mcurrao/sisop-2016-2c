<#
.SYNOPSIS
Escribe en un archivo un listado de los procesos que más utilización de memoria tienen
.DESCRIPTION
Escribe en un archivo, cada N segundos, un listado de los M procesos que más utilización de memoria tienen

Especificando por cada uno de ellos la siguiente información:
Identificador (PID) – Path del ejecutable – Memoria (Working Set).
.PARAMETER N
Segundos entre actualizacion del archivo
Si N es igual a 0, entonces la información se guardará sólo una vez. En caso de N mayor a cero, la información se actualizará cada N segundos.
.PARAMETER M
Cantidad de procesos a mostrar
#>

function List-process() {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)][int]$M,
        [int]$N
    )
    $saveFile = "c:\process-running.txt";
    $action = {
        Get-WmiObject -Class Win32_Process | sort -Descending WorkingSetSize | select -first $M ProcessId, ExecutablePath, WorkingSetSize | Out-File $saveFile
    }
    if($N -gt 0) {
        $timer = New-Object System.Timers.Timer
        $timer.Interval = ($N * 1000)
        Unregister-Event -ErrorAction SilentlyContinue listProcessTimerIntervalElapsed
        Register-ObjectEvent -InputObject $timer -EventName elapsed -SourceIdentifier listProcessTimerIntervalElapsed -Action $action
        $timer.Start()
    } else {
        Invoke-Command -scriptblock  $action
        Write-Host "Procesos corriendo salvados en $saveFile"
    }
}
