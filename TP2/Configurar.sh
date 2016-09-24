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
OPTIND=4
while getopts ":c:y" opt; do
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
      read -p "Ingrese un comentario: " comment
      ;;
  esac
done
addedBy=`whoami`
addedAt=`date`
foundInFile=`grep -x -c -m 1 "$2=.*" $1`
if [ "$foundInFile" -eq 0 ] ; then
if [ ! -z "$comment" ] ; then
commentOnNewLine="
# $comment"
fi
#La linea de debajo del cat no esta comentada, es para documentar
cat <<EOT >> $1
# Agregado por $addedBy el $addedAt. $commentOnNewLine
$2=$3
EOT
echo "Se agrega $2=$3 al archivo"
else
if [ "$confirmation" -eq 0 ] ; then
while true; do
    read -p "Esta clave ya se encuentra presente. Sobreescribir? Y/N : " yn
    case $yn in
        [YySs]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Responda y o n: ";;
    esac
done
fi
previousValue=`grep -x -m 1 "$2=.*" $1 | cut -d = -f 2`
if [ ! -z "$comment" ] ; then
commentOnNewLine="\\
# $comment"
fi
replacementLine="/$2=.*/c\
# Editado por $addedBy el $addedAt. Valor anterior: $previousValue.$commentOnNewLine\\
$2=$3"
sed -i "$replacementLine" $1
echo Se actualizo el valor de $2 a $3
fi