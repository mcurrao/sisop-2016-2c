<#
.SYNOPSIS
Indica la relación de compresión de los contenidos de un archivo .zip

.DESCRIPTION
Recorre los contenidos del archivo .zip pasado por parámetro y por cada uno de ellos indica:
nombre, tamaño original, tamaño comprimido y la relación de compresión

.EXAMPLE
./ejercicio6.ps1 -archivo test.zip
Nombre archivo  Tamaño original Tamaño comprimido  Relación
Archivo1.txt    100             10                 0,1
Archivo2.jpg    2366            2254               0,95
#>
<#
Nombre del script: Ejercicio6.ps1
Trabajo práctico número 1
Ejercicio 6

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
    [string]$archivo
)

begin {
    # validaciones de existencia y tipo de archivo
    $existe = test-path $archivo
    if($existe -eq $false) {
        write-error "Archivo inexistente"
        exit
    }
    else {
        $ext = [System.IO.Path]::GetExtension($archivo)
        if($ext -ne ".zip") {
            write-error "Extensión inválida"
            exit
        }
    }
    
    #formateo de campos
    $campos = @{Label = "Nombre Archivo"; Expression = { $_.FullName }; },
    @{Label = "Tamaño original"; Expression = { [Math]::Round($_.Length/1MB,2) }; },
    @{Label = "Tamaño comprimido"; Expression = { [Math]::Round($_.CompressedLength/1MB,2) }; }, 
    @{Label = "Relación"; Expression = { [Math]::Round($_.CompressedLength/$_.Length,3) }; } 

    # importo la librería necesaria para el manejo de .zip
    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
}

process {
    # leo los contenidos del .zip
    $path = (Get-Location).Path + "\" + $archivo
    $files = [System.IO.Compression.ZipFile]::OpenRead($path).Entries

    # imprimo los resultados con el formato requerido
    Write-Output($files) | Format-Table $campos -AutoSize
}
