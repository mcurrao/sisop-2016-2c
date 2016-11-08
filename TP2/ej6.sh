#!/bin/bash

# Constantes
EXIT_SUCCESS=0
EXIT_ERROR=1

TRUE=1
FALSE=0

# La ruta en la que están los archivos con los PIDs y carpetas de los trabajos.
RUTA_ARCHIVOS=/var/tmp/demonio

# La ruta a los buffers (los archivos de salida) de los trabajos.
RUTA_BUFFERS=/var/tmp/buffers

RUTA_REFERENCIAS=/var/tmp/demonio_referencias

error_y_salir() {
  echo $1
  ayuda
  exit $EXIT_ERROR
}

ayuda() {
  echo "ejercicio6: administra trabajos que controlan el tamaño de archivos.     "
  echo "                                                                         "
  echo "USO                                                                      "
  echo "  Para iniciar: ej6.sh RUTA_ARCHIVO/ARCHIVO_A_GUARDAR                                  "

  echo "  Para ver proceso: ej6.sh                                                            "
echo "  Para ver ayuda: ej6.sh -? -?                                                                       "
}

# Verifica la existencia del trabajo dado y sale con un mensaje de error si no
# existe.
verificar_existencia_trabajo() {
  stat "$RUTA_ARCHIVOS/$1" &> /dev/null
  if [[ $? != 0 ]]
  then  # El archivo no existe, por lo tanto el trabajo tampoco.
    echo "El trabajo $1 no existe"
    exit $EXIT_FAILURE
  fi
}

# Arranca el demonio. Recibe como parámetro la carpeta que debe inspeccionar.
arrancar() {
  if [[ ! -d $1 ]]
  then
    error_y_salir "La carpeta dada no existe"
  fi

  # Absolutizamos la ruta.
  CARPETA_NUEVO_DEMONIO=$(realpath $1)
#absolutizamos arhivo
ARCHIVO_BUFFER=$(realpath $2)

  # Creamos la carpeta si es que no existe.
  mkdir $RUTA_ARCHIVOS &> /dev/null

  # Verifico que la carpeta no esté ya siendo cubierta por otro demonio activo.
  for ARCHIVO in `ls $RUTA_ARCHIVOS`
  do
    LINEA=`cat $RUTA_ARCHIVOS/$ARCHIVO`
    CARPETA=`grep -o :.* <<< $LINEA`

    # Ignoro el :
    CARPETA=${CARPETA:1}

    if [[ $CARPETA = $CARPETA_NUEVO_DEMONIO ]]
    then
      echo "La carpeta $CARPETA ya está siendo cubierta por la tarea $ARCHIVO"
      exit $EXIT_FAILURE
    fi

    if [[ $CARPETA =~ ^$CARPETA_NUEVO_DEMONIO ]]
    then
      echo "La carpeta $CARPETA, incluída en $CARPETA_NUEVO_DEMONIO, ya está siendo cubierta por la tarea $ARCHIVO"
      exit $EXIT_FAILURE
    fi

    if [[ $CARPETA_NUEVO_DEMONIO =~ ^$CARPETA ]]
    then
      echo "La carpeta $CARPETA_NUEVO_DEMONIO ya está siendo cubierta por la tarea $ARCHIVO"
      exit $EXIT_FAILURE
    fi
  done

  # Podemos crear el demonio.
  # Nos fijamos cuál es el ID del demonio más pequeño disponible.
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
  #bash ./ej6_demonio.sh "$CARPETA_NUEVO_DEMONIO" "$RUTA_BUFFERS/$ID_NUEVO_DEMONIO" "$RUTA_ARCHIVOS/$ID_NUEVO_DEMONIO" &

  bash ./ej6_demonio.sh "$CARPETA_NUEVO_DEMONIO" "$ARCHIVO_BUFFER" "$RUTA_ARCHIVOS/$ID_NUEVO_DEMONIO" &

  PID_DEMONIO=$!

  echo "Arrancado trabajo en carpeta $CARPETA_NUEVO_DEMONIO con ID $ID_NUEVO_DEMONIO"
  echo "Para finalizarlo manualmente (no recomendado), usar SIGUSR en $PID_DEMONIO"

  # Guardamos los datos del demonio en su archivo temporal.
  echo $PID_DEMONIO:$CARPETA_NUEVO_DEMONIO > $RUTA_ARCHIVOS/$ID_NUEVO_DEMONIO
#guardamos su relacion: Path_a revisar : path donde guardar archivos administrativos 
mkdir $RUTA_REFERENCIAS &> /dev/null
echo $CARPETA_NUEVO_DEMONIO:$ARCHIVO_BUFFER > $RUTA_REFERENCIAS/$ID_NUEVO_DEMONIO
}

# Consulta el estado de los demonios.
consultar_status() {
  # ls se queja si la carpeta no existe. Oculto el error creándola primero :).
  mkdir $RUTA_ARCHIVOS &> /dev/null

  if [[ `ls $RUTA_ARCHIVOS` = "" ]]
  then
    echo "No hay trabajos en ejecución"
    exit $EXIT_SUCCESS
  fi

  for ARCHIVO in `ls $RUTA_ARCHIVOS`
  do
    LINEA=`cat $RUTA_ARCHIVOS/$ARCHIVO`
    PID=`grep -o ^[0-9]* <<< $LINEA`
    CARPETA=`grep -o :.* <<< $LINEA`

    # Ignoro el :
    CARPETA=${CARPETA:1}
    echo "Trabajo $ARCHIVO: carpeta $CARPETA"
  done
}

# Detiene un demonio, recibiendo su ID como parámetro.
detener() {
  verificar_existencia_trabajo $1

  LINEA=`cat $RUTA_ARCHIVOS/$1`
  PID=`grep -o ^[0-9]* <<< $LINEA`

  kill -SIGUSR1 $PID

  echo "Trabajo $1 detenido"
}

# Escucha al trabajo dado.
listen() {
  echo "Escuchando al trabajo $1. Ctrl + C para salir (el trabajo seguirá corriendo)."

  verificar_existencia_trabajo $1

  tail -n +0 -f $RUTA_BUFFERS/$1
}

# Consulta el estado de los demonios.
consultar_estados() {
  # ls se queja si la carpeta no existe. Oculto el error creándola primero :).
  mkdir $RUTA_REFERENCIAS &> /dev/null

  if [[ `ls $RUTA_REFERENCIAS` = "" ]]
  then
    error_y_salir "No hay trabajos en ejecución. Mostrando ayuda:"
    exit $EXIT_SUCCESS
  fi

  for ARCHIVO in `ls $RUTA_REFERENCIAS`
  do
	
    LINEA=`cat $RUTA_REFERENCIAS/$ARCHIVO`
    PATH1=`grep -o .*: <<< $LINEA`
    PATH2=`grep -o :.* <<< $LINEA`
    # Ignoro el :
	#elimino ultimo caracter
	PATH1=`echo $PATH1 | sed -e 's/.$//'`
	#elimino primer caracter
	PATH2=`echo $PATH2 | sed -e 's/^.//'`

	tail -n +0 -f "$PATH2"
	
  done

}

# Validación de parámetros y delegación a funciones.
if [[ $1 == "-?" ]]
    then
      ayuda
      exit $EXIT_SUCCESS
 fi

if [[ $# -gt 1 ]]
    then
      echo "Cantidad de parametros incorrecta"
      ayuda
	exit $EXIT_SUCCESS
 fi



if [[ $1 == "" ]]
    then
      consultar_estados
fi

if [[ $2 = "" ]]
then
	arrancar $PWD $1
fi

