#!/bin/bash


#NOTA AL DOCENTE: Estuvimos viendo varias implementaciones de cuatrimetres anteriores sobre este ejercicio. 
# Con lo que hemos visto que se calcula la diferencia por tamaÃ±os o se usa Message-Digest Algorithm (MD5) para verificar si hubo cambios o no.
# Ya que en 2006 Peter Selinger publico un paper sobre una implementacion de este metodo que permite generar dos ficheros ejecutables con el mismo valor de hash md5 y distinto comportamiento. Asumimos que la mejor opcion es usar SHa256.

CARPETA=$1
RUTA_SALIDA=$2

# Archivo que debe borrarse al terminar el script.
ARCHIVO_A_BORRAR=$3

TIEMPO_SLEEP=30

# Declaro el array asociativo donde se guardan extensiÃ³n -> tamaÃ±o.
declare -A HASH_EXTENSIONES

# Y el array donde se guardan los hashes de los archivos.
declare -A HASH_SHA256

IFS=$'\n'

#Segun el enunciado: "Este proceso deberÃ¡ finalizar cuando se le envÃ­e una seÃ±al SIGUSR1"
trap 'rm $ARCHIVO_A_BORRAR; exit' SIGUSR1
#Segun el enunciado: "no deberÃ¡ finalizar con SIGINT"
trap "" SIGINT


# Obtengo una lista con todos los archivos.
LISTA_ARCHIVOS=$( find "$CARPETA" -type f)

for ARCHIVO in $LISTA_ARCHIVOS
do
  # Por cada archivo, obtengo extensiÃ³n y tamaÃ±o.
  NOMBRE_ARCHIVO=$(grep -o "/[^/]*$" <<< $ARCHIVO)
  NOMBRE_ARCHIVO=${NOMBRE_ARCHIVO:1}
  EXTENSION=$(cut -d'.' -f2- <<< $NOMBRE_ARCHIVO)
  SIZE=$(stat -c %s "$ARCHIVO" 2> /dev/null)

  if [ -z "${HASH_EXTENSIONES[$EXTENSION]+isset}" ]
  then
    # Si no estÃ¡ en el mapa, lo agregamos.
    HASH_EXTENSIONES[$EXTENSION]=$SIZE
  else
    # Si estÃ¡, sumamos el tamaÃ±o a lo que ya habÃ­a.
    (( HASH_EXTENSIONES[$EXTENSION] = ${HASH_EXTENSIONES[$EXTENSION]} + $SIZE ))
  fi

  HASH_SHA256[$ARCHIVO]=$(sha1sum $ARCHIVO | cut -d" " -f1)
done

SALIDA=""
for EXTENSION in ${!HASH_EXTENSIONES[@]}
do
  	FECHA=`date "+%d/%m/%y %H:%M:%S"`

  	SALIDA=$SALIDA$(printf "%s %s %-26s %-26s\\\\n" "$$" "$FECHA" "$EXTENSION" "${NUEVO_HASH_EXTENSIONES[$EXTENSION]}")
done
echo -en $SALIDA >> $RUTA_SALIDA


# Bucle en el que buscamos cambios.
while true
do
  sleep $TIEMPO_SLEEP

  HUBO_CAMBIOS=false

  # Buscamos cambios en el hash.
  unset NUEVO_HASH_SHA256
  declare -A NUEVO_HASH_SHA256

  # Obtengo una lista con todos los archivos.
  LISTA_ARCHIVOS=$( find "$CARPETA" -type f)

  for ARCHIVO in $LISTA_ARCHIVOS
  do
    NUEVO_HASH_SHA256[$ARCHIVO]=$(sha1sum  $ARCHIVO | cut -d" " -f1)
  done

  if [[ ${#NUEVO_HASH_SHA256[@]} != ${#HASH_SHA256[@]} ]]
  then
    HUBO_CAMBIOS=true
  else
    for ARCHIVO in ${!NUEVO_HASH_SHA256[@]}
    do
      if [[ ${NUEVO_HASH_SHA256[$ARCHIVO]} != ${HASH_SHA256[$ARCHIVO]} ]]
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

    # Hacemos lo mismo pero verificando si hay cambios

    for ARCHIVO in ${!NUEVO_HASH_SHA256[@]}
    do
      # Por cada archivo, obtengo extensiÃ³n y tamaÃ±o.
      NOMBRE_ARCHIVO=$(grep -o "/[^/]*$" <<< $ARCHIVO)
      NOMBRE_ARCHIVO=${NOMBRE_ARCHIVO:1}
      EXTENSION=$(cut -d'.' -f2- <<< $NOMBRE_ARCHIVO)
#stat no me devuelve en mb, entonces lo transformo
      SIZE=$(stat -c %s "$ARCHIVO" 2> /dev/null)

      if [ -z "${NUEVO_HASH_EXTENSIONES[$EXTENSION]+isset}" ]
      then
        # Si no estÃ¡ en el mapa, lo agregamos.

        NUEVO_HASH_EXTENSIONES[$EXTENSION]=$SIZE
      else
        # Si estÃ¡, sumamos el tamaÃ±o a lo que ya habÃ­a.
        (( NUEVO_HASH_EXTENSIONES[$EXTENSION] = ${NUEVO_HASH_EXTENSIONES[$EXTENSION]} + $SIZE ))
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
          DIFERENCIA="(nueva extensiÃ³n)"
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
        SALIDA=$SALIDA$(printf "%s %s %-26s %-26s %-26s\\\\n" "$$" "$FECHA" "$EXTENSION" "0" "(Eliminada)")
      fi
    done

    echo -en $SALIDA >> $RUTA_SALIDA

    # Limpio el hash de SHA256
    unset HASH_SHA256
    declare -A HASH_SHA256
    for ARCHIVO in ${!NUEVO_HASH_SHA256[@]}
    do
      HASH_SHA256[$ARCHIVO]=${NUEVO_HASH_SHA256[$ARCHIVO]}
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
