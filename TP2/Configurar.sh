#!/bin/bash

if [ "$#" -lt 3 ]; then
    echo "Uso: Configurar.sh archivo clave valor [-y][-c comentario]"
    exit
fi
if [ ! -f "$1" ] ; then
    echo "$1 no es un archivo";
    exit;
fi
if [ ! -w "$1" ] ; then
    echo "No se tienen permisos de escritura sobre $1";
    exit;
fi
confirmation=0
comment=
while getopts ":yc:" opt; do
  case $opt in
    y)
      confirmation=1
      ;;
    c)
      comment=$OPTARG
      ;;
    \?)
      echo "-$OPTARG no es un parametro valido" >&2
      ;;
    :)
      read -p -s "Ingrese un comentario" comment
      ;;
  esac
done
addedBy=`whoami`
addedAt=`date`
foundInFile=`grep -x -c -m 1 "$2=.*" $1`
echo F : $foundInFile
if [ "$foundInFile" -eq 0 ] ; then
echo $comment
#La linea de debajo no esta comentada, es para documentar
cat <<EOT >> $1
# Agregado por $addedBy el $addedAt - $comment
$2=$3
EOT
echo "Se agrega $2=$3 al archivo"
fi