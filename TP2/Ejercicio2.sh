#!/bin/bash

#Nombre del Script: Ejercicio2.sh
#Trabajo práctico número 2
#Ejercicio 2
#
#Ambroso, Nahuel Oscar 	    DNI: 34.575.684
#Currao, Martin		    DNI: 38.029.678
#Martinez, Sebastian	    DNI: 36.359.866
#Rey, Juan Cruz		    DNI: 36.921.336
#Rodriguez, Gabriel Alfonso DNI: 36.822.462
#
#
#Entrega 27/9/2016

###################
#####FUNCIONES#####
###################

imprimirAyuda(){
	clear
	echo "Sintaxis de ejecución: ./$(basename "$0") -a | -u [usuario] | -c

	Descripcion: El script muestra las conexiones de un usuario o de todos, dependiendo del parametro ingresado.

	Parametros:

	-a: Muestra los usuarios con conexiones activas y la ultima conexion de los usuarios sin conexiones activas.

	-u: Muestra las conexiones activas de un usuario en particular ingresado como segundo parametro.
		Si no se indica el usuario se muestran las conexiones activas del usuario que ejecuto el script.
	
	-c: Muestra los usuarios y la cantidad de conexiones que tuvo cada uno.
	
	Si no se indica ningun parametro, por defecto, se ejecutara con la funcionalidad de -a.

	-h | -? | --help: Muestra por pantalla la ayuda del script"
	
	exit 0
}

mensajeError(){
	echo "$1"
	exit 0
}

verificarParametro(){
	if [[ ("$1" == '') || ("$1" == '\"') ||  ("$1" == '.') || ("$1" == '..') ]]
	then
		mensajeError "$1 no es un parametro valido."
	fi
}

#La funcion comprueba si esta activo o no el usuario
QueNoSeaActivo(){		
	who | cut -c1-8 >usuariosA
	user=0	
	while read -r lineal; do
		lin=($lineal)	
		usrCon=${lin[0]}		
		if [[ ($usrCon == $1) ]]
		then
			user=1
		fi 	
	done<usuariosA
	rm usuariosA
	echo "$user"	
	
}



mostrarTodosLosUsuarios(){
	who | awk 'BEGIN {printf "Usuario\t	Ultima conexion\t	Tiempo de Conexion\n"
			 }
			 {printf "%0.16s\t	Activo en %s\t	---\n",$1,$2
			 }'
		
	#Guardo la salida del comando last, moldeando una salida lo mas adecuadamente posible, en el archivo ConexionesDeUsuarios
  	last -a -F | grep -v reboot | grep -v ^$ | grep -v wtmp | grep -v log | sort -u -k1,1 1>ConexionesDeUsuarios	
	#Se recorre el archivo linea por linea
        while read -r line; do   
        #Se guarda la linea actual del archivo en el array linea
        linea=($line)
        #Se guardan los usuarios, fechas y el directorio
		usuario=${linea[0]}
		   #Se fija que el usuario no este activo
		   val=$(QueNoSeaActivo "$usuario")
	           directorio=${linea[1]}
	           if [[( "0" == $val )]]
		   then	 
		    fechadia=${linea[4]}
		    fechames=${linea[3]}	
		    fechaano=${linea[6]}
		    hora=${linea[5]}				    
		    #Tomo la fecha y la paso a formato epoch para despues darle otro format
		    fecvi=`date --date="$fechadia-$fechames-$fechaano" +%s`    				    
		    #Subdivido la cadena hora
		    IFS=':' read -r -a hm <<< "$hora"
		    hh=${hm[0]}
		    mm=${hm[1]}
		    #Moldeo la columna 13 con el fin de tener la salida solicitada
		    TDeConexion=${linea[13]:1:5}
		    #Si el usuario no esta activo, muestro su ultima conexion
		    echo -e "$usuario\t\t        `date -d @$fecvi +%d/%m/%Y `  $hh:$mm   \t\t  $TDeConexion hs "|column -t -s $'\t\t'
		  fi
	#Se toma el archivo ConexionesDeUsuarios como entrada para el while
    done<ConexionesDeUsuarios
    #Se elimina el archivo temporal
    rm ConexionesDeUsuarios
	exit 0
}

mostrarUnUsuario(){
	#Si no se ingreso un nombre de usuario por parametro
	if [[ ("$1" == "Actual") ]] 
	then
		#Guardo en un archivo las conexiones activas de los usuarios
		who>usuarioActual
		echo -e "Usuario\t	       Ultima conexion\t	       Tiempo de Conexion\n"|column -t -s $'\t\t'
		#Se recorre el archivo linea por linea
		while read -r line; do         
		    linea=($line)
		    usuarioAct=${linea[0]}
		    conexion=${linea[1]}
		    #Pregunto si mi usuario es igual a mi usuario actual y lo imprimo
		    if [[ ($usuarioAct == $(whoami)) ]]
		    then
		    	echo -e "$usuarioAct\t        Activo en $conexion\t        ---"|column -t -s $'\t'
		    fi
		#Se toma el archivo UsuarioActual como entrada para el while
	    done<usuarioActual
	    #Se elimina el archivo temporal
	    rm usuarioActual
		#Si se ingreso un nombre de usuario como segundo parametro
	else
		#Guardo en una variable el usuario ingresado por parametro y le agrego un espacio al final para obligarlo a que sea el nombre entero ingresado, el cual busco al comienzo del flujo con el grep
		NombreUsuario="$1 "
		#Busco las conexiones activas del usuario que coincida con el ingresado y lo guardo en un archivo
    	who|grep ^"$NombreUsuario">UsuarioEncontrado
    	#Si el archivo de usuario existe y no es vacio muestro las conexiones activas de ese usuario
	    if [[ (-s UsuarioEncontrado) ]]
	    then 
	    	echo -e "Usuario \t       Ultima conexion \t      Tiempo de Conexion"|column -t -s $'\t'
	    	#Se recorre el archivo linea por linea
	    	while read -r line; do
	      		linea=($line)	      		
			usuario=${linea[0]}
	      		conexion=${linea[1]}	
	      		echo -e "$NombreUsuario\t \t     Activo en $conexion        ---"|column -t -s $'\t'
				#Se toma el archivo UsuarioEncontrado como entrada para el while
	    	done<UsuarioEncontrado
	    	#Se elimina el archivo temporal
	    	rm UsuarioEncontrado
	    else
	    	#Se elimina el archivo temporal
	    	rm UsuarioEncontrado
	    	mensajeError "El usuario buscado no esta conectado o no existe."
    	fi
	fi
	exit 0
} 

mostrarUsrYCantConexiones(){
	
	awk 'BEGIN {printf "Usuario\t	Conexiones\t	Tiempo de Conexion\n" }'
		
	#Guardo la salida del comando last en el archivo ConexionesDeUsuarios1
  	last -a -F | sort -u |head -n -1 1>ConexionesDeUsuarios1
	#Se recorre el archivo linea por linea
        while read -r line; do   
        #Se guarda la linea actual del archivo en el array linea
        linea=($line)
        #Se guardan los usuarios, fechas y el directorio
		usuario=${linea[0]}
		directorio=${linea[1]}
		#Comprueba que el usuario no sea reboot del systema
		if [[ ($usuario != "reboot") ]]
		then
				    fechadia=${linea[4]}
				    fechames=${linea[3]}	
				    fechaano=${linea[6]}
				    hora=${linea[5]}
				    fecvi=`date --date="$fechadia-$fechames-$fechaano" +%s`    
				    IFS=':' read -r -a hm <<< "$hora"
				    hh=${hm[0]}
				    mm=${hm[1]}
				    TDeConexion=${linea[13]:1:5}
			    #Si el usuario no esta activo, muestro su ultima conexion filtrando el usuario wtmp si es que estuviese
			    if [[ ($usuario != "wtmp") && !(-z $linea) && ($TDeConexion != "")]]
			    then
			    	echo -e "$usuario\t        `date -d @$fecvi +%d/%m/%Y `  $hh:$mm   \t\t  $TDeConexion hs "|column -t -s $'\t'
			    fi
		fi			
	#Se toma el archivo ConexionesDeUsuarios1 como entrada para el while
    done<ConexionesDeUsuarios1
    #Se elimina el archivo temporal
    rm ConexionesDeUsuarios1

	exit 0
}

####################################
#####BLOQUE DE CODIGO PRINCIPAL#####
####################################

case "$#" in
	0) mostrarTodosLosUsuarios
	;;
	1) verificarParametro "$1"
		if [[ ("$1" == '-h') || ("$1" == '-help') || ("$1" == '-?') ]]
		then
			imprimirAyuda
		else 
			if [[ ("$1" == '-a') ]]
			then
	   			mostrarTodosLosUsuarios
	   		else
	   			if [[ ("$1" == '-u') ]]
	   			then
	   				mostrarUnUsuario "Actual"
	   			else
					if [[ ("$1" == '-c')]]
					then
						mostrarUsrYCantConexiones
					else
	   					mensajeError "$1 no es un parametro valido."
					fi
	   			fi
	   		fi
	   	fi
	;;
	2) verificarParametro "$1"
	   verificarParametro "$2"
	   if [[ ("$1" == '-u') ]]
	   then
	   		mostrarUnUsuario "$2"
	   else
	   		if [[ ("$1" == '-a') ]]
	   		then
	   			mensajeError "El parametro $1 no requiere otros parametros."
	   		else
	   			mensajeError "$1 no es un parametro valido."
	   		fi
	   fi
	;;
	*) mensajeError "Se ingresaron mas parametros de los esperados."
	;;
esac
