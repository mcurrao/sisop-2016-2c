<#
.SYNOPSIS
Ordena los archivos dentro de subdirectorios

.DESCRIPTION
Recorre los archivos de un directorio pasado por parámetro y crea una carpeta si 
cumple la longitud que se envía por parámetro y mueve los archivos dentro de ella

.EXAMPLE
./ejercicio3.ps1 test 3 ó
-/ejercicio3.ps1 -path test -x 3

.NOTES
Nombre del script: Ejercicio3.ps1
Trabajo práctico número 1
Ejercicio 3

Ambroso, Nahuel Oscar	   DNI:34.575.684
Currao, Martin             DNI:38.029.678
Martinez,Sebastian	   DNI:36.359.866
Rey,Juan Cruz		   DNI:36.921.336
Rodriguez, Gabriel Alfonso DNI:36.822.462

Entrega 6/09/2016
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