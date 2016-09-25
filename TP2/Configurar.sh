#!/bin/bash

if [ "$#" -lt 3 ]; then
    # Debe tener al menos 3 parametros
    echo "Uso: Configurar.sh archivo clave valor [-y][-c comentario]"
    exit 2;
fi
if [ ! -f "$1" ] ; then
    # Validaciones al archivo
    echo "$1 no es un archivo";
    exit 2;
fi
if [ ! -w "$1" ] ; then
    # Validaciones de permisos
    echo "No se tienen permisos de escritura sobre $1";
    exit 126;
fi

# Inicializacion de la variable de sobreescritura silenciosa
confirmation=0
# Se cambia la propiedad OPTIND para que getops tome los parametros
# luego de mis parametros iniciales
OPTIND=4
# Se buscan parametros del tipo -y o -c "Comment"
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
      # Se pide un comentario si no lo ingreso inline
      read -p "Ingrese un comentario: " comment
      ;;
  esac
done

#Se obtienen usuario actual y fecha
addedBy=`whoami`
addedAt=`date`
# Se averigua si la clave ya existe en el archivo
foundInFile=`grep -x -c -m 1 "$2=.*" $1`
if [ "$foundInFile" -eq 0 ] ; then
if [ ! -z "$comment" ] ; then
# Se pasa al comentario a una nueva linea, con el formato de <<EOT
commentOnNewLine="
# $comment"
fi
# La linea de debajo del cat no esta comentada, es para documentar
# Todo a partir del <<EOT se introduce al comando textual,
# luego de los reemplazos. Esto hasta el literal EOT
cat <<EOT >> $1
# Agregado por $addedBy el $addedAt. $commentOnNewLine
$2=$3
EOT
# Finalizado el EOT
echo "Se agrega $2=$3 al archivo"
else
if [ "$confirmation" -eq 0 ] ; then
# Si no se paso el parametro silencioso -y, entonces
# pido confirmacion de escritura
while true; do
    read -p "Esta clave ya se encuentra presente. Sobreescribir? Y/N : " yn
    case $yn in
        [YySs]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Responda y o n: ";;
    esac
done
fi
# Obtengo el valor anterior de la clave, para documentar
previousValue=`grep -x -m 1 "$2=.*" $1 | cut -d = -f 2`
if [ ! -z "$comment" ] ; then
# Se pasa al comentario a una nueva linea, con el formato de sed (\\)
commentOnNewLine="\\
# $comment"
fi
replacementLine="/$2=.*/c\
# Editado por $addedBy el $addedAt. Valor anterior: $previousValue.$commentOnNewLine\\
$2=$3"
# Se reemplaza la linea actual de key=valor en el archivo por una linea
# documentando, una linea con los comentarios (si los hay), y una linea
# con el nuevo valor
sed -i "$replacementLine" $1
echo Se actualizo el valor de $2 a $3
fi