#!/bin/bash

# Constantes
EXIT_SUCCESS=0
EXIT_ERROR=1
ERROR_DE_ALGUN_TIPO=1

TRUE=1
FALSE=0


# La ruta en la que estÃ¡n los archivos con los PIDs y carpetas de los procesos.
RUTA_ARCHIVOS=/var/tmp/demonio

# La ruta a los buffers (los archivos de salida) de los procesos.
RUTA_BUFFERS=/var/tmp/demonio_buffers

error_y_salir() {
  echo $1
  ayuda
  exit $EXIT_ERROR
}

ayuda() {
  echo "ej6: administra procesos que controlan el tamaÃ±o de archivos."
  echo "                                                                    "
  echo "			USO:                                         "
  echo "                                                                    "
  echo "  ej6 start RUTA                                                    "
  echo "  ej6 status                                                        "
  echo "  ej6 stop ID_proceso                                               "
  echo "  ej6 Escuchar ID_proceso                                           "
  echo "                                                                    "
  echo "			COMANDOS:				"
  echo "                                                                    "
  echo "  start      Arranca un procesos en la RUTA dada.                   "
  echo "  Estado     Muestra informaciÃ³n de los procesos activos.           "
  echo "  stop       Detiene al procesos con ID_proceso (consultar Estado)  "
  echo "  Escuchar   Imprime en pantalla cambios en los archivos del procesos"
  echo "             ID_proceso.                                                "
  echo "En caso de que no se envie parametro se escuchara el estado del directorio"
 echo "                                                       "
  echo "Nota adicional: En caso de un error similar a \"bc: no se encontrÃ³ la orden\" "
echo "Debido a que el Script usa Package: bc (El lenguaje "
  echo "calculador de precisiÃ³n arbitraria bc de GNU) es necesario tenerlo"
  echo "instalado en su sistema."
}

# Verifica la existencia del proceso dado y sale con un mensaje de error si no
# existe.
verificar_existencia_procesos() {
  stat "$RUTA_ARCHIVOS/$1" &> /dev/null
  if [[ $? != 0 ]]
  then  # Si el archivo no existe, por lo tanto el procesos tampoco.
    echo "El proceso $1 no existe"
    exit $ERROR_DE_ALGUN_TIPO
  fi
}

# Arranca el demonio. Recibe como parÃ¡metro la carpeta que debe inspeccionar.
Empezar() {
# si la carpeta no existe, entonces no puede Empezar
  if [[ ! -d $1 ]]
  then
    error_y_salir "La carpeta dada no existe"
  fi

  # Si la ruta es relativa , la hacemos absoluta.
  CARPETA_NUEVO_DEMONIO=$(realpath $1)

  # Creamos la carpeta si es que no existe.
  mkdir $RUTA_ARCHIVOS &> /dev/null

  # Verifico que la carpeta no estÃ© ya siendo cubierta por otro demonio activo.
  for ARCHIVO in `ls $RUTA_ARCHIVOS`
  do
    LINEA=`cat $RUTA_ARCHIVOS/$ARCHIVO`
    CARPETA=`grep -o :.* <<< $LINEA`

    # Ignoro el :
    CARPETA=${CARPETA:1}

    if [[ $CARPETA = $CARPETA_NUEVO_DEMONIO ]]
    then
      echo "La carpeta $CARPETA ya estÃ¡ siendo cubierta por la tarea $ARCHIVO"
      exit $ERROR_DE_ALGUN_TIPO
    fi

    if [[ $CARPETA =~ ^$CARPETA_NUEVO_DEMONIO ]]
    then
      echo "La carpeta $CARPETA, incluÃ­da en $CARPETA_NUEVO_DEMONIO, ya estÃ¡ siendo cubierta por el proceso $ARCHIVO"
      exit $ERROR_DE_ALGUN_TIPO
    fi

    if [[ $CARPETA_NUEVO_DEMONIO =~ ^$CARPETA ]]
    then
      echo "La carpeta $CARPETA_NUEVO_DEMONIO ya estÃ¡ siendo cubierta por la tarea $ARCHIVO"
      exit $ERROR_DE_ALGUN_TIPO
    fi
  done

  # Podemos crear el demonio.
  # Nos fijamos cuÃ¡l es el ID del demonio mÃ¡s pequeÃ±o disponible.
  ID_NUEVO_DEMONIO=1
  stat "$RUTA_ARCHIVOS/$ID_NUEVO_DEMONIO" &> /dev/null
  while [[ $? = 0 ]]
  do
    (( ID_NUEVO_DEMONIO=ID_NUEVO_DEMONIO + 1 ))
    stat "$RUTA_ARCHIVOS/$ID_NUEVO_DEMONIO" &> /dev/null
  done

  # Arrancamos el demonio.
  mkdir $RUTA_BUFFERS &> /dev/null
  echo "" > $RUTA_BUFFERS/$ID_NUEVO_DEMONIO
  bash ./demonio.sh "$CARPETA_NUEVO_DEMONIO" "$RUTA_BUFFERS/$ID_NUEVO_DEMONIO" "$RUTA_ARCHIVOS/$ID_NUEVO_DEMONIO" &

  PID_DEMONIO=$!

  echo "Arrancado procesos en carpeta $CARPETA_NUEVO_DEMONIO con ID $ID_NUEVO_DEMONIO"
  echo "Para finalizarlo manualmente (no recomendado), usar SIGUSR1 en $PID_DEMONIO"

  # Guardamos los datos del demonio en su archivo temporal.
  echo $PID_DEMONIO:$CARPETA_NUEVO_DEMONIO > $RUTA_ARCHIVOS/$ID_NUEVO_DEMONIO
}

# Consulta el estado de los demonios.
consultar_Estado() {

  #   ls lanza error si pregunto por una carpeta que no esta creada, entonces intento crearla antes
  mkdir $RUTA_ARCHIVOS &> /dev/null

  #si esta vacio el directorio significa que no hay procesos en ejecuciÃ³n
  if [[ `ls $RUTA_ARCHIVOS` = "" ]]
  then
    echo "No hay procesos en ejecuciÃ³n"
    exit $EXIT_SUCCESS
  fi

  for ARCHIVO in `ls $RUTA_ARCHIVOS`
  do
    LINEA=`cat $RUTA_ARCHIVOS/$ARCHIVO`
    PID=`grep -o ^[0-9]* <<< $LINEA`
    CARPETA=`grep -o :.* <<< $LINEA`

    # Ignoro el :
    CARPETA=${CARPETA:1}
    echo "Proceso $ARCHIVO: carpeta $CARPETA"
  done
}

# Detiene un demonio, recibiendo su ID como parÃ¡metro.
detener() {
  verificar_existencia_procesos $1

  LINEA=`cat $RUTA_ARCHIVOS/$1`
  PID=`grep -o ^[0-9]* <<< $LINEA`

  kill -SIGUSR1 $PID

  echo "procesos $1 detenido"
}

# Escucha al procesos dado.
Escuchar_proceso() {
  echo "Escuchando al procesos $1. Si desea salir presione Ctrl + C para salir (el procesos seguirÃ¡ corriendo)."

  verificar_existencia_procesos $1
	echo "PID   FECHA   HORA   FORMATO   PESO(en kb) Cambios"
  tail -n +0 -f $RUTA_BUFFERS/$1
}

# ValidaciÃ³n de parÃ¡metros y delegaciÃ³n a funciones.
case $1 in
  start)
     if [[ $2 = "" ]]
     then
       error_y_salir "Falta la ruta"
     fi
     Empezar $2
     ;;
  Estado)
    consultar_Estado
    ;;
  stop)
     if [[ $2 = "" ]]
     then
       error_y_salir "Falta el ID de procesos. Consultar Estado ."
     fi
     detener $2
     ;;
  Escuchar)
  
     if [[ $2 = "" ]]
     then
       error_y_salir "Falta el ID de procesos. Consultar Estado."
     fi
    Escuchar_proceso $2
    ;;
  *)
    if [[ $1 == "-?" ]]
    then
      ayuda
      exit $EXIT_SUCCESS
    fi
    if [[ $1 == "" ]]
    then
      echo "Falta el comando"
    else
      echo "Comando $1 desconocido"
    fi

		ayuda
		exit $EXIT_ERROR
esac
