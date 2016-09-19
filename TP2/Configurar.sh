#!/bin/bash

if [ "$#" -lt 3 ]; then
    echo "Se deben pasar al menos 3 parametros"
    exit
fi
if [ ! -f "$1" ] ; then
    echo "$1 no es un archivo";
    exit;
fi
confirmation=0
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