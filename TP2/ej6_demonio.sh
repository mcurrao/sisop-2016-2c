#!/bin/bash

# Carga inicial de tama�os e impresi�n.

CARPETA=$1
RUTA_SALIDA=$2

# Archivo que debe borrarse al terminar el script.
ARCHIVO_LOCK=$3

TIEMPO_SLEEP=30

# Declaro el array asociativo donde se guardan extensi�n -> tama�o.
declare -A HASH_EXTENSIONES

# Y el array donde se guardan los hashes de los archivos.
declare -A HASH_MD5

# Este pedacito m�gico nos permite separar en el for por \n y no espacios.
IFS=$'\n'

#trap "rm $ARCHIVO_LOCK" EXIT
#Segun el enunciado este proceso debera finalizar cuando se le envia la se�al SIGUSR1
trap 'rm "$ARCHIVO_LOCK" &> /dev/null ;
	rm -rf "/var/tmp/demonio_referencias/${ARCHIVO_LOCK: -1}";
	rm -rf "/var/tmp/demonio/${ARCHIVO_LOCK: -1}";
	rm -rf "/var/tmp/buffers/${ARCHIVO_LOCK: -1}";
	exit;
' SIGUSR1
trap ""  SIGINT
# Obtengo una lista con todos los archivos.
LISTA_ARCHIVOS=$( find "$CARPETA" -type f)

for ARCHIVO in $LISTA_ARCHIVOS
do
  # Por cada archivo, obtengo extensi�n y tama�o.
  NOMBRE_ARCHIVO=$(grep -o "/[^/]*$" <<< $ARCHIVO)
  NOMBRE_ARCHIVO=${NOMBRE_ARCHIVO:1}
  EXTENSION=$(cut -d'.' -f2- <<< $NOMBRE_ARCHIVO)
  SIZE=$(stat -c %s "$ARCHIVO" 2> /dev/null)

  if [ -z "${HASH_EXTENSIONES[$EXTENSION]+isset}" ]
  then
    # Si no est� en el mapa, lo agregamos.
    HASH_EXTENSIONES[$EXTENSION]=$SIZE
  else
    # Si est�, sumamos el tama�o a lo que ya hab�a.
    (( HASH_EXTENSIONES[$EXTENSION] = ${HASH_EXTENSIONES[$EXTENSION]} + $SIZE ))
  fi

  HASH_MD5[$ARCHIVO]=$(md5sum $ARCHIVO | cut -d" " -f1)
done

SALIDA=""
for EXTENSION in ${!HASH_EXTENSIONES[@]}
do
  FECHA=`date "+%d/%m/%y %H:%M:%S"`
  SALIDA=$SALIDA$(printf "%s %s %s %-26s %-26s\\\\n" "$$" "$FECHA" "$EXTENSION" "${HASH_EXTENSIONES[$EXTENSION]}")
done
echo -en $SALIDA >> $RUTA_SALIDA


# Bucle en el que buscamos cambios.
while true
do
  sleep $TIEMPO_SLEEP

  HUBO_CAMBIOS=false

  # Buscamos cambios en el hash.
  unset NUEVO_HASH_MD5
  declare -A NUEVO_HASH_MD5

  # Obtengo una lista con todos los archivos.
  LISTA_ARCHIVOS=$( find "$CARPETA" -type f)

  for ARCHIVO in $LISTA_ARCHIVOS
  do
    NUEVO_HASH_MD5[$ARCHIVO]=$(md5sum $ARCHIVO | cut -d" " -f1)
  done

  if [[ ${#NUEVO_HASH_MD5[@]} != ${#HASH_MD5[@]} ]]
  then
    HUBO_CAMBIOS=true
  else
    for ARCHIVO in ${!NUEVO_HASH_MD5[@]}
    do
      if [[ ${NUEVO_HASH_MD5[$ARCHIVO]} != ${HASH_MD5[$ARCHIVO]} ]]
      then
        HUBO_CAMBIOS=true
        break
      fi
    done
  fi

  if [ $HUBO_CAMBIOS = true ]
  then
    unset NUEVO_HASH_EXTENSIONES
    declare -A NUEVO_HASH_EXTENSIONES

    # Copy paste del c�digo de arriba porque no se pueden pasar arrays
    # asociativos por referencia en bash.
    # Al menos ya tenemos los archivos en el hash de md5 nuevo :)
    for ARCHIVO in ${!NUEVO_HASH_MD5[@]}
    do
      # Por cada archivo, obtengo extensi�n y tama�o.
      NOMBRE_ARCHIVO=$(grep -o "/[^/]*$" <<< $ARCHIVO)
      NOMBRE_ARCHIVO=${NOMBRE_ARCHIVO:1}
      EXTENSION=$(cut -d'.' -f2- <<< $NOMBRE_ARCHIVO)
      SIZE=$(stat -c %s "$ARCHIVO" 2> /dev/null)

      if [ -z "${NUEVO_HASH_EXTENSIONES[$EXTENSION]+isset}" ]
      then
        # Si no est� en el mapa, lo agregamos.
        NUEVO_HASH_EXTENSIONES[$EXTENSION]=$SIZE
      else
        # Si est�, sumamos el tama�o a lo que ya hab�a.
        (( NUEVO_HASH_EXTENSIONES[$EXTENSION] = ${NUEVO_HASH_EXTENSIONES[$EXTENSION]} + $SIZE )) &> /dev/null
      fi
    done

    SALIDA=""
    for EXTENSION in ${!NUEVO_HASH_EXTENSIONES[@]}
    do
      FECHA=`date "+%d/%m/%y %H:%M:%S"`
      if [[ ! ${HASH_EXTENSIONES[$EXTENSION]} = ${NUEVO_HASH_EXTENSIONES[$EXTENSION]} ]]
      then
        if [ -z ${HASH_EXTENSIONES[$EXTENSION]+isset} ]
        then
          DIFERENCIA="(NUEVA)"
        else
          DIFERENCIA=$(bc <<< "scale=2; (${NUEVO_HASH_EXTENSIONES[$EXTENSION]} - ${HASH_EXTENSIONES[$EXTENSION]}) * 100 / ${HASH_EXTENSIONES[$EXTENSION]}")
          # Si no arranca con -, le agregamos un +.
          if [[ ! ${DIFERENCIA:0:1} = "-" ]]
          then
            DIFERENCIA=+$DIFERENCIA
          fi
          DIFERENCIA="($DIFERENCIA%)"
        fi
	SALIDA=$SALIDA$(printf "%s %s %-26s %-26s %-26s\\\\n" "$$" "$FECHA" "$EXTENSION" "${NUEVO_HASH_EXTENSIONES[$EXTENSION]}" "$DIFERENCIA")
      fi
    done

    for EXTENSION in ${!HASH_EXTENSIONES[@]}
    do
      if [ -z ${NUEVO_HASH_EXTENSIONES[$EXTENSION]+isset} ]
      then
        SALIDA=$SALIDA$(printf "%s %s %-26s %-26s %-26s\\\\n" "$$" "$FECHA" "$EXTENSION" "0" "(ELIMINADA)")

      fi
    done

    echo -en $SALIDA >> $RUTA_SALIDA

    # Limpio el hash de MD5s.
    unset HASH_MD5
    declare -A HASH_MD5
    for ARCHIVO in ${!NUEVO_HASH_MD5[@]}
    do
      HASH_MD5[$ARCHIVO]=${NUEVO_HASH_MD5[$ARCHIVO]}
    done

    # Limpio el hash de extensiones.
    unset HASH_EXTENSIONES
    declare -A HASH_EXTENSIONES
    for EXTENSION in ${!NUEVO_HASH_EXTENSIONES[@]}
    do
      HASH_EXTENSIONES[$EXTENSION]=${NUEVO_HASH_EXTENSIONES[$EXTENSION]}
    done
  fi
done
