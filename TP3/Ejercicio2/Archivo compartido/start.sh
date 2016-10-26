#!/bin/bash

gcc -I.. procesoA.c ../utils.c ../utils.h -o pa
gcc -I.. procesoB.c ../utils.c ../utils.h -o pb

xterm -hold -T "Proceso A" -e "./pa" &
sleep 2
xterm -hold -T "Proceso B" -e "./pb"

rm "./pa"
rm "./pb"
