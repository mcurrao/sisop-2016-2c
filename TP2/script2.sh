#!/bin/bash

# Nombre del script: script2.sh
# Trabajo practico numero 2
# Ejercicio 1
# Ambroso, Nahuel Oscar	     DNI:34.575.684
# Currao, Martin             DNI:38.029.678
# Martinez,Sebastian	     DNI:36.359.866
# Rey,Juan Cruz		     DNI:36.921.336
# Rodriguez, Gabriel Alfonso DNI:36.822.462
# 1ra entrega - 27/09/2016

./script1.sh 10
echo "Resultado $variable"
. script1.sh 15
echo "Resultado $variable"
./script1.sh $$
echo 'Resultado $variable'
script1.sh 35
echo "Resultado $variable"

# --- RESPUESTAS ---

# a. Tuve que usar el comando chmod para dar permisos de ejecucion a los archivos
# chmod u+x script*.sh

# b. Si, se presento un error. No se reconoce script1.sh como comando global. Para solucionar esto se puede:
# i) Usar el comando dot (.) para ejecutar el script, igual que en la linea 4 de este mismo script
# ii) Ejecutarlo en base al directorio actual como ./script1.sh igual que en la linea 2 de este script
# iii) Agregar el script al $path o moverlo a alguno de los directorios incluidos en el

# c. Los parametros se pasan a continuacion del script ejecutable, separados por un espacio
# Para utilizar los parametros dentro del script se pueden usar las variables especiales de bash
# $1 a $9 para los primeros 9 parametros del script
# ${10} en adelante para los demas parametros

# d. Resulta particular que $variable no se encuentre definida dentro de script2.sh, ni se realize ninguna asignacion de dicha variable.
# Y aun asi, su valor cambia. Es decir, que la ejecucion de otros scripts agrega o modifica variables dentro del script que estoy ejecutando.

# e. '#!' se conoce como MagicNumber e indica al sistema operativo que el archivo es un script ejecutable
# '/bin/bash' es la ruta al interprete de bash, e indica al sistema donde hallar el mismo.
# Un script puede ser ejecutado en tantos lenguajes como interpretes se tengan instalados en el sistema.
# Especificar /bin/sh como interprete llamara al interprete por defecto, que en la mayor parte de los sistemas Linux actuales deriva en Bash.
# Si no se especifica un interprete (se omite el MagicNumber y el path al interpreter, entonces el script solamente podra ejecutar directivas propias del sistema, que no utilizen comandos internos del shell.

# f. La variable $$ contiene el PID (Process ID) del script que se esta ejecutando
# Otras variables especiales son:
# '$#' : Cantidad de argumentos que fueron suministrados al script al momento de ejecutar
# '$0' : Nombre del script que se está ejecutando actualmente
# '$*' : Todos los argumentos suministrados al momento de ejecutar, vistos como una sola palabra
# '$@' : Todos los argumentos suministrados al script al momento de ejecutar, vistos como una lista
# '#?' : Valor de retorno del ultimo script ejecutado

# g. Existen 3 tipos principales de comillas utilizados en la catedra:
#
# " o comilla suave : Todo lo que se encuentre encerrado entre comillas suaves sera evaluado en busca de expresiones
# Ejemplo :
# echo "$valor"
# Mostrara por resultado el contenido de la variable valor
#
# ' o comilla dura : El contenido de lo encerrado en estas comillas sera mostrado literal
# Ejemplo : 
# echo '$valor'
# Mostrara literalmente $valor por la salida
#
# ` o comilla de ejecucion : Todo lo contenido por estas comillas sera evaluado como un comando, comportandose de manera similar a $(comando)
# Ejemplo :
# foo=`date`
# Ejecutara el comando date y guardara su resultado en la variable foo