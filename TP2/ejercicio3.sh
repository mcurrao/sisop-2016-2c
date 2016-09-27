#!/bin/bash

# Nombre del script: reporte.sh
# Trabajo practico numero 2
# Ejercicio 3
# Ambroso, Nahuel Oscar	     DNI:34.575.684
# Currao, Martin             DNI:38.029.678
# Martinez,Sebastian	     DNI:36.359.866
# Rey,Juan Cruz		     DNI:36.921.336
# Rodriguez, Gabriel Alfonso DNI:36.822.462
# 1ra entrega - 27/09/2016

#flags
informar=0
recursivo=0

#ayuda del script
if [ "$1" == "-h" ]; then
  echo "Uso: `basename $0` genera un reporte de la cantidad de archivos ejecutables de un directorio.
	-d,		directorio a analizar
	-s,		archivo de salida
	-y,		cantidades clasificadas por año
	-r,		analizar subdirectorios"
  exit 0
fi

#validaciones de parámetros
if [ "$#" -gt 6 ]; then
    #debe tener como mucho 4 parametros
    echo "Cantidad de parámetros incorrecta, por favor lea la ayuda"
    exit 2;
fi

while getopts ":d:,:s:,y,r" opt; do
  case $opt in
    d) 
	directorio=$OPTARG ;; 
    s) 
	archivo=$OPTARG ;;
    y) 
	informar=1 ;;
    r) 
	recursivo=1 ;;
    :)
      echo "La opción -$OPTARG necesita un valor." >&2
      exit 1 ;;
  esac
done

if [ "$recursivo" = 0 ]; then
	rec="-maxdepth 1"
else
	rec=""
fi

#usuario actual
usuario=`whoami`
total=0

if [ "$directorio" = "" ]; then

#cuento la cantidad total de ejecutables en PATH
while IFS=':' read -ra ruta; do
      for i in "${ruta[@]}"; do
          ((total+=`find $i $rec -executable -type f | wc -l`))
      done
 done <<< "$PATH"

if [ "$archivo" = "" ]; then
printf "Usuario: $usuario - Directorios analizados de PATH.
Cantidad total de comandos disponibles: $total
Detalle de comandos disponibles por directorio: \n"
else
printf "Usuario: $usuario - Directorios analizados de PATH.
Cantidad total de comandos disponibles: $total
Detalle de comandos disponibles por directorio: \n" > $archivo
fi

#obtengo las rutas de PATH
while IFS=':' read -ra ruta; do
      for i in "${ruta[@]}"; do
	  #cuento el total de ejecutables por subdirectorio
	  comando=`find $i $rec -executable -type f | wc -l`
	  if [ $comando != 0 ]; then
		  if [ $informar = 0 ]; then 
			if [ "$archivo" = "" ]; then 	
		  	printf "%-20s %d \n" $i: $comando
			else 
			printf "%-20s %d \n" $i: $comando >> $archivo
			fi
		  else 
			cont=0
			#obtengo los distintos años de los ejecutables
			find $i $rec -executable -type f -printf '%TY\n' | sort | uniq | while read j; do 
				#cuento la cantidad de ejecutables por año
				if [ $cont = 0 ]; then
					if [ "$archivo" = "" ]; then
						printf "%-20s %-4s %d \n" $i: $j: `find $i $rec -executable -type f -ls | grep " $j " | wc -l`.
					else
						printf "%-20s %-4s %d \n" $i: $j: `find $i $rec -executable -type f -ls | grep " $j " | wc -l`. >> $archivo
					fi
				else 
					if [ "$archivo" = "" ]; then
						printf "%+26s %d \n" $j: `find $i $rec -executable -type f -ls | grep " $j " | wc -l`
					else 
						printf "%+26s %d \n" $j: `find $i $rec -executable -type f -ls | grep " $j " | wc -l` >> $archivo	
					fi
				fi			
				((cont++))
			done
		  fi
	fi
      done
done <<< "$PATH"

else

#cuento el total de ejecutables
total=`find $directorio $rec -executable -type f 2>/dev/null | wc -l`

if [ "$archivo" = "" ]; then
printf "Usuario: $usuario - Directorio analizado: $directorio.
Cantidad total de comandos disponibles: $total \n"
else
printf "Usuario: $usuario - Directorio analizado: $directorio.
Cantidad total de comandos disponibles: $total \n" > $archivo
fi

if [ "$recursivo" = 1 ]; then
	if [ "$archivo" = "" ]; then
		printf "Detalle de comandos disponibles por directorio: \n"
	else
		printf "Detalle de comandos disponibles por directorio: \n" >> $archivo
	fi
	#recorro los subdirectorios
	find $directorio -maxdepth 1 -type d | while read i; do 
		if [ "$i" != $directorio ]; then
			#cuento la cantidad de ejecutables por subdirectorio
			comando=`find $i -executable -type f 2>/dev/null | wc -l`
		else
			comando=`find $i -maxdepth 1 -executable -type f 2>/dev/null | wc -l`
		fi
		#si hay ejecutables imprimo el resultado
		if [ $comando != 0 ]; then
			if [ "$archivo" = "" ]; then
				printf "%-30s %d \n" $i: $comando
			else
				printf "%-30s %d \n" $i: $comando >> $archivo
			fi
		fi
	done
	
fi #fin de recursivo

fi #fin de directorio
