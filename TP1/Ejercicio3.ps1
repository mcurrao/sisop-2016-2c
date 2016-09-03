<#
.SYNOPSIS
Ordena los archivos dentro de subdirectorios

.DESCRIPTION
Recorre los archivos de un directorio pasado por parámetro y crea una carpeta si 
cumple la longitud que se envía por parámetro y mueve los archivos dentro de ella

.EXAMPLE
./ejercicio3.ps1 test 3 ó
-/ejercicio3.ps1 -path test -x 3
#>

Param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$path,
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [int]$x
)

# validaciones de existencia y valores
begin {
    $existe = test-path $path
    if($existe -eq $false) {
        write-error "Ruta inexistente"
        exit
    }
    if($x -lt 0) {
        write-error "No se puede ingresar un valor negativo"
        exit
    }
}

process {
    $archivos = Get-ChildItem -File $path

    foreach($file in $archivos) {
        $nombre = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $longitud = $($nombre).Length
        if($longitud -gt $x) {
            $indice = $nombre.Substring(0,$x)
            if($indice -ne "") { 
                mkdir("$path/$indice") -ErrorAction SilentlyContinue
                Move-Item "$path/$file" "$path/$indice"
            }
        }
    }
}