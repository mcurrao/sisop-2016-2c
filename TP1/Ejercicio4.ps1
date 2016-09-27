
function Show-Objects {

    <#
    .Synopsis
    Ordena los objetos y los filtra según un determinado valor

    .Description
    Separa las propiedades indicadas de los objetos, y las ordena de forma descendente o ascendente. Luego filtra los objetos según su valor en la primera propiedad ingresada.
    
    .Example
    Get-Service | Show-Objects -asc -propiedad "Status,Name" -filtro "Stopped"
    Toma las columnas Status y Name de Get-Service, las filtra en caso de tener el valor Stopped en Status, y las ordena de forma ascendente, primero Status y luego Name.
    
    .Example
    Get-Service | Show-Objects -asc -propiedad "Status,Name" -filtro "Stopped" -print
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

    Entrega 6/09/2016
    #>
    
    [CmdletBinding()]
    param(
        # Objetos pasados por pipe
        [Parameter(
            Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true
        )]
        [array]$objeto,

        # Descendente (default)
        [switch]$desc,
        # O Ascendente
        [switch]$asc,

        # Propiedades por las que se ordenan los objetos, separadas por coma
        [Parameter(Mandatory=$true)]
        [string]$propiedad,
		[switch]$print,
        # Valores a filtrar de la propiedad indicada en -propiedad (exacto o parcial)
        [string]$filtro
    )

    Begin{
        $error = 0

        # Se verifica que no se hayan ingresado ambas opciones de ordenamiento
        if($desc -and $asc) {
            $error = 1
        }
        
        # Se separan las propiedades y se las guarda en un array
        $propiedades = @()
        $propiedades += $propiedad.Split(",")

        # Se crea un array para almacenar los objetos ingresados por pipeline
        $objetos = @()
    }

    Process{
        if ($error -eq 0) {
            # Se agregan los objetos al array uno por uno
            $objetos += $objeto
        }
    }

    End{

            if ($print) {

                echo "----------------------------------"
                echo "Propiedades:"

                foreach($pro in $propiedades) {
                echo $pro
                }

                echo "----------------------------------"
            }

        if ($error -eq 0) {
            # Se filtran los objetos con determinado valor en caso de que se haya dado un filtro
            if ($filtro -ne $null) {
                $propiedad_a_filtrar = $propiedades[0]
                $objetos = $objetos | Where-Object {$_.$propiedad_a_filtrar -like "*$filtro*"}
            }

            # Se toman solo las propiedades solicitadas
            $objetos = $objetos | Select-Object -Property $propiedades

            # Se ordenan los objetos según el orden solicitado
            if ($asc) {
                $objetos = $objetos | Sort-Object -Property $propiedades
            }
            else {
                $objetos = $objetos | Sort-Object -Property $propiedades -Descending
            }

            # Finalmente se imprimen en pantalla los objetos uno por uno
            foreach($objeto in $objetos) {
                echo $objeto
            }
        }
        else {
            if ($error -eq 1) {
                echo "Parámetros inválidos: Sólo puede haber una opción de ordenamiento."
            }
        }
    }
}
