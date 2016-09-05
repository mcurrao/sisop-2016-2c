<#
Nombre del script: Ejercicio2.ps1
Trabajo práctico número 1
Ejercicio 2

Ambroso, Nahuel Oscar	   DNI:34.575.684
Currao, Martin             DNI:38.029.678
Martinez,Sebastian	   DNI:36.359.866
Rey,Juan Cruz		   DNI:36.921.336
Rodriguez, Gabriel Alfonso DNI:36.822.462

Entrega 6/09/2016
#>


<#
.SYNOPSIS
    El script muestra el porcentaje de ocurrencia de cada carácter del archivo indicado por parámetro.
.DESCRIPTION
    El script muestra el porcentaje de ocurrencia de cada carácter del archivo indicado por parámetro.
.PARAMETER path_de_archivo
    Archivo a leer
.EXAMPLES
    Ejercicio2.ps1 C:\Archivo.txt
#>


#Paramentros de entradad al script

Param(
  [Parameter(mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  
  $path_de_archivo
)


$existe_archivo = Test-Path $path_de_archivo   #Se evalua la existencia del archivo de texto...

if( $existe_archivo -eq $true)  #Si existe el archivo...
{
    

    $contenido_del_archivo = Get-Content -Raw $path_de_archivo

    if($contenido_del_archivo)   #Si el archivo no esta vacío...
    {
        $cant_por_char = @{} #Crear un hash array...
        
   
        foreach($linea in $contenido_del_archivo)   #Por cada linea...
        {
            
            $array_de_caracteres = [char[]]$linea  #Se crea un array de caracteres a partir de la linea...
            
            foreach( $caracter in $array_de_caracteres)
            {
            
                $valor_en_ascii = [int][char]$caracter  #Se convierte el caracter en ascii...

                if($valor_en_ascii -le 32)
                {
                    $caracter = "[$valor_en_ascii]" #Si es un caracter especial o no imprimible, se guarda el valor en ascii...
                }

       
                    
                    $porcentaje_de_caracter = $cant_por_char.Get_Item($caracter)

                    if(!$porcentaje_de_caracter)
                    {
                        $porcentaje_de_caracter = 0
                    }
   
                    $cant_por_char.Set_Item($caracter, $porcentaje_de_caracter + 1)
                
            }

        }

        $formato = @{Expression = {$_.Name}; Label = "Caracter"; Width = 10}, `
                    @{Expression={[string]'{0:0.#}'-f(($_.Value*100)/$cant_por_char.Count) + "%"}; Label = "Ocurrencia"; Width = 10}

        
        
        $cant_por_char.GetEnumerator() | Sort-Object Name | Format-Table $formato
        
        echo "Nota: los caracteres especiales se indican con su valor en ascii"

    }else  #Si el archivo esta vacio...
    {
        Write-Error -Message "El archivo esta vació"


    }
    
    

}else  #Si el archivo no existe...
{
    Write-Error -Message "El archivo no existe"

}
