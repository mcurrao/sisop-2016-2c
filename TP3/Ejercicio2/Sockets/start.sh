#!/bin/bash

gcc -I.. client.c ../utils.c ../utils.h -o client

xterm -hold -T "Cliente" -e "./client"

rm "./server"
