#!/bin/sh

#------------------------------------------#
#Nombre del script: Ejercicio4.sh	   #
#Trabajo práctico número 2		   #
#Ejercicio 4				   #
#					   #
#Ambroso, Nahuel Oscar	   DNI:34.575.684  #
#Currao, Martin             DNI:38.029.678 #
#Martinez,Sebastian	   DNI:36.359.866  #
#Rey,Juan Cruz		   DNI:36.921.336  #
#Rodriguez, Gabriel Alfonso DNI:36.822.462 #
#					   #
#1ra Entrega 27/09/2016 		   #
#------------------------------------------#


error=0


mostrarError(){		#Muestra el msj de error, dependiendo del error obtenido

case $1 in
	1)	echo
		echo "ERROR: Número de vendedor inexistente. Ingrese un valor entero positivo luego del \"-c\". Si desea ver la ayuda, ingrese \"-?\" o \"-h\"."	
		;;

	2)	echo
		echo "ERROR: Fecha no válida. Ingrese una fecha no superior a la del día, y en formato \"MM-AAAA\" luego del \"-m\". Si desea ver la ayuda, ingrese \"-?\" o \"-h\"."
		;;

	3) 	echo
		echo "ERROR: Opción no válida. Ingrese \"-c\" junto con el número de vendedor si desea filtrar por vendedor, o \"-m\" junto con una fecha no superior a la del dia en formato \"MM-AAAA\", si desea filtrar por mes y año. Si desea ver la ayuda, ingrese \"-?\" o \"-h\"."
		;;

	4)	echo
		echo "ERROR: Opciones inválidas. Ingrese \"-c\" junto con el número de vendedor si desea filtrar por vendedor, y \"-m\" junto con una fecha no superior a la del dia en formato \"MM-AAAA\", si desea filtrar por mes y año. Se puede invertir el orden de las opciones. Si desea ver la ayuda, ingrese \"-?\" o \"-h\"."
		;;
		
	5)	echo
		echo "ERROR: Número de vendedor inexistente y/o fecha no válida. Ingrese un valor entero positivo para el vendedor y/o una fecha no superior a la del día, en formato \"MM-AAAA\". Si desea ver la ayuda, ingrese \"-?\" o \"-h\"."
		;;
	
	6)	echo
		echo "ERROR: Cantidad de opciones no válida. Puede solo puede ingresar \"-c\" para filtrar por vendedor y/o \"-m\" para filtrar por mes y año. Si desea ver la ayuda, ingrese \"-?\" o \"-h\"."
		;;

esac

}

mostrarAyuda(){
	echo "\n\nAyuda del ejercicio 4 del TP2"
	echo "\n\nModo de Empleo: $0 [OPCION]...\n "
	echo "\nScript que filtra las ventas realizadas en un determinado mes y año, o por cliente. Las opciones a ingresar son:"
	echo "\n'-c <Numero de cliente>' Se muestran todas las ventas hechas a un determinado cliente en el mes actual."
	echo "\n'-m <Mes y año>' Se muestran todas las ventas realizadas en un determinado mes y año. El formato de la fecha es 'MM-AAAA'."
	echo "\n\nSe puede ingresar una o ambas opciones al script. En caso de no ingresar ninguna opcion, el scrito muestra las ventas del mes y año actual."
}

correrAWK(){
		
	
	
	patron="ventas-[0-9][0-9]\.$2\.$3$" 	#Creo el patron de busqueda de la expresion regular
	lista=$(ls -1 | grep -e $patron | sort )   #Obtengo una lista de todos los archivos obtenidos a partir de la expresion regular
		
	comando="cat $lista >> arch_temporal.txt"	
	eval $comando					#Ejecuto el comando para crear un unico archivo, con el contenido de los obtenidos
	
	

	#Inicializo las variables que voy a utilizar en el awk	
	awk -F "|" -v cliente=$1 -v mes=$2 -v anio=$3 -v cant_registros=$lineas_total '
	
	

	BEGIN{  
			
			if(cliente != "0")
				printf("\nReporte del mes %s del %s del cliente %s: \n\n", mes, anio, cliente)
			else
		
				printf("\nReporte del mes %s del %s: \n\n", mes, anio)
	
			printf("%s %18s %15s %15s %10s\n\n", "Hora", "Cod_de_factura", "Cod_de_cliente", "Razon_social", "Importe")
			
				
	
			
	}
		

	(NF==5 && cliente==$3){ printf("%s %8s %15s %19s %10s \n", $1, $2, $3, $4, $5); cantidad++ }

	(NF==5 && cliente=="0") { printf("%s %8s %15s %19s %10s \n", $1, $2, $3, $4, $5); cantidad++ }



	


	' arch_temporal.txt > salida.txt

	tam_salida=$(wc -l < salida.txt)

	if [ $tam_salida -eq 5 ];
	then
		if [ $1 -eq 0 ];
		then
			echo "\nNo se realizo ninguna venta en el mes $2 del $3.\n"
		else
			echo "\nNo se realizo ninguna venta al cliente $1.\n"
		fi
	else
		cat salida.txt		
	fi
	
	rm salida.txt
	rm arch_temporal.txt		#Elimino el archivo temporal
}	



case $# in
	0)	#Si no se ingresa ninguna opcion, se mostraran las ventas del mes
		cliente="0"
		mes=$(date +%m)
		anio=$(date +%Y)
		correrAWK $cliente $mes $anio
		;;

	1)
		if [ $1 = "-?" ] || [ $1 = "-h" ]; #Si se ingreso -? o -h...
		then
			mostrarAyuda	#Se muestra la ayuda del script...
		else
			error=3
		fi
		;;

	2)	#Si ingreso -c o -m...
		if [ $1 = "-c" ] || [ $1 = "-m" ];
		then		
			if [ $1 = "-c" ];	#Si ingreso -c...
			then
				
				if [ $2 -gt 0 ]; #Valido que sea un numero positivo el Cod de cliente
				then
					cliente=$2
					mes=$(date +%m)
					anio=$(date +%Y)
					correrAWK $cliente $mes $anio
				else
					error=1  #Sino, "error"...
				fi
			 
			elif [ $1 = "-m" ]; #Si ingreso -m...
			then
				
				mes=$(echo $2 | cut -f1 -d- ) 
				anio=$(echo $2 | cut -f2 -d- )
				#Verifico que se haya ingresado un mes y año valido...
				echo
				if ([ $mes -ge 1 ] && [ $mes -le 12 ] && [ $mes -le $(date +%m) ]) && ([ $anio -ge 1900 ] && [ $anio -le $(date +%Y) ]); 					then				
					cliente="0"
					
					correrAWK $cliente $mes $anio 
				else
					error=2 #Sino, "error"...
				fi
			
			fi			
		else
							
			error=3 #Sino, "error"...
		
		fi		
		;;

	4)	#Si ingreso tanto -c como -m...
		if ([ $1 = "-c" ] && [ $3 = "-m" ]) || ([ $1 = "-m" ] && [ $3 = "-c" ]);
		then
			if [ $1 = "-c" ] && [ $3 = "-m" ]; #Si ingrese primero el -c y despues el -m...
			then
				mes=$(echo $4 | cut -f1 -d- )
				anio=$(echo $4 | cut -f2 -d- )
				#Verifico que el cliente y la fecha ingresada sea valida...
				if ([ $mes -ge 1 ] && [ $mes -le 12 ]) && ([ $anio -ge 1900 ] && [ $anio -le $(date +%Y) ]) && [ $2 -gt 0 ]; 
				then
					cliente=$2				
					correrAWK $cliente $mes $anio
				else
					error=5 #Sino, "error"...
				fi
			else 	#Sino... si lo ingrese al revez...
				mes=$(echo $2 | cut -f1 -d- )
				anio=$(echo $2 | cut -f2 -d- )
				#Verifico que el cliente y la fecha ingresada sea valida...
				if ([ $mes -ge 1 ] && [ $mes -le 12 ]) && ([ $anio -ge 1900 ] && [ $anio -le $(date +%Y) ]) && [ $4 -gt 0 ];
				then				
					cliente=$4
					correrAWK $cliente $mes $anio
				else
					error=5 #Sino, "error"...
				fi			
			fi
			
		else
			error=4 #Si se ingresaron mal las opciones...
		fi
		;;

	

	*)	#Si se ingresan opciones que no son validas...
		error=6
		;;

esac


if [ $error -ne 0 ];	#En caso de que haya surgido alguno error...
then
	mostrarError $error
fi

