<#
.Synopsis
Ordena los objetos y los filtra según un determinado valor

.Description
Separa las propiedades indicadas de los objetos, y las ordena de forma descendente o ascendente. Luego filtra los objetos según su valor en la primera propiedad ingresada.
    
.Example
PS > Get-Service | .\Ejercicio4.ps1  -propiedad Status,name -filtro 'Stopped' -asc -print Status,Name
Toma las columnas Status y Name de Get-Service, las filtra en caso de tener el valor Stopped en Status, y las ordena de forma ascendente, primero Status y luego Name.
    
.Example
PS > Get-Service | .\Ejercicio4.ps1  -propiedad Status -filtro 'Stopped' -asc -print Status,Name
Toma las columnas Status y Name de Get-Service, las filtra en caso de tener el valor Stopped en Status, y las ordena de forma ascendente, primero Status y luego Name. 
Pero esta vez mostrando por pantalla las propiedades mandadas por parametro.
    
.NOTES
Nombre del script: Ejercicio4.ps1
Trabajo práctico número 1
Ejercicio 4
 
Ambroso, Nahuel Oscar	   DNI:34.575.684
Currao, Martin             	   DNI:38.029.678
Martinez,Sebastian	   	   DNI:36.359.866
Rey,Juan Cruz		   DNI:36.921.336
Rodriguez, Gabriel Alfonso 	   DNI:36.822.462

Entrega 25/09/2016
#>
   
[cmdletbinding()]
param(
    [Parameter(mandatory=$true, position=0, ValueFromPipeline=$true)]$InputObject,
    [Parameter(Mandatory=$true, 
        HelpMessage="Nombre de la propiedad sobre la que se va a operar")]
    [string] $propiedad,	
    [Parameter(Mandatory= $true, 
        HelpMessage="Valor que se debe buscar en la propiedad indicada con  -propiedad. 
                        El valor puede ser exacto o no serlo. En caso de no ser exacto , debe estar contenido en la misma")]
    [string] $filtro,
    [parameter(Mandatory=$false)][Switch] $asc,
    [parameter(Mandatory=$false)][switch] $desc,
    [Parameter(Mandatory= $false)][ValidateNotNullorEmpty()][string[]] $print
)


begin {
    if($asc -and $desc) {
        throw "No se puede ordenar ascendente y descendentemente a la vez"
    }
    $objects = @() 
}
process { 
    $objects += $InputObject
}
end {
    if ($filtro -ne $null) {
        $objects = $objects | Where-Object {$_.$propiedad -like "*$filtro*"}
    }
    if($desc)
    {
        $objects= $($objects | Sort-Object -Property $propiedad -Descending)
    }
    else{
        $objects= $($objects | Sort-Object -Property $propiedad)
    }
    if($print){
        $objects | Select-Object -Property $print -Unique
    }
    else{
        return $objects
    }
}