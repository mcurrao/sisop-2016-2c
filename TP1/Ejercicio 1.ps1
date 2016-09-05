<#
Nombre del script: Ejercicio1.ps1
Trabajo práctico número 1
Ejercicio 1

Ambroso, Nahuel Oscar	   DNI:34.575.684
Currao, Martin             DNI:38.029.678
Martinez,Sebastian	   DNI:36.359.866
Rey,Juan Cruz		   DNI:36.921.336
Rodriguez, Gabriel Alfonso DNI:36.822.462

Entrega 6/09/2016
#>

Param($pathsalida)  #define que el parámetro ingresado se llame pathsalida 

$existe = Test-Path $pathsalida  #hace la validación del parametro pathsalida
if ($existe -eq $true)  #evalúa si es verdadera la validación del path.
{
    $lista = Get-ChildItem -File  #Toma una lista de archivos del directorio actual 
    
    foreach ($item in $lista)
    {
        Write-Host "$($item.Name) $($item.Length)" #Evalúa cada item en la lista dada, mostrando por pantalla nombre y tamaño
    }
}
else
{
    write-Error "El path no existe"  #Imprime en el caso de no ser válido el path, que el mismo no existe.
}

<#

A:

El objetivo del script es tomar un path pasado por parámetro, 
validar si es correcto, de no serlo se procede a imprimir 
por pantalla que no existe el path ingresado, en el caso de ser válido
se lista en pantalla el nombre y el tamaño en bits de todos aquellos 
archivos que se encuentran dentro del directorio donde se encuentra el script.

B:

Agregaría una validación para que exija ingresar un path obligatoriamente
Ej: param(
            [$pathsalida (position = 1, Mandatory = $true)]
         )


c:

La misma podría ser reemplazada por:

get-childitem -File 

puesto que no utiliza el path ingresado para extraer la lista, la extrae del directorio donde se ejecuta el script.

#>