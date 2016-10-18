Performance de procesos pesados y livianos
==========================================

Implemente el siguiente algoritmo y responda las preguntas sobre performance:

 - Un proceso que reciba por parámetro la cantidad de posiciones de un
   array y actúe en base a esta cantidad. Se deberá ejecutar cada
   proceso al menos tres veces con los valores 25000, 50000, 75000
   
 - Crear un array de enteros de X (el parámetro) posiciones e
   inicializarlo con números random
 - Tomar estructura de estadísticas del proceso iniciales o Usar syscall getrusage()
 - Tomar tiempo reloj
   de inicio o Usar clock_gettime() con el timer CLOCK_MONOTONIC_RAW
 - Generar un número random único, que será utilizado posteriormente por
   las unidades de procesamiento, que no sea ni 0 y 1
 - Lanzar 1000 unidades de procesamiento de a una por vez (el proceso principal debe crear la unidad de procesamiento y esperar a que finalice su trabajo)
 - El objetivo de cada unidad de procesamiento será operar sobre el
   array definido e inicializado por el proceso principal
 - Se deberán generar los siguientes casos:
  1. Caso 1: 
    - Unidad de procesamiento: Proceso pesado
    - Acceso a datos: Lectura
  2. Caso 2:
    - Unidad de procesamiento: Proceso pesado
    - Acceso a datos: Escritura
  3. Caso 3: 
    - Unidad de procesamiento: Proceso liviano
    - Acceso a datos: Lectura
  4. Caso 4:
    - Unidad de procesamiento: Proceso liviano
    - Acceso a datos: Escritura
 - Tomar estructura de estadísticas del proceso hijo o Usar el syscall
   wait3() o ~~wait34()~~ wait4() que devuelve la estructura rusage con los datos estadísticos del proceso
 - Tomar tiempo reloj de fin Calcular las
   estadísticas finales, para poder sumarizar los parciales y obtener
   los valores promedios por cada ejecución
 - Imprimir todas las
   estructuras de datos utilizadas para calcular las estadísticas (no el
   array)

El acceso a datos define el tipo de operación que se realizará en cada uno de los casos:

 - Lectura: Realiza la sumatoria de las X posiciones del array en una variable
 - Escritura: Multiplica cada posición del array por el número random único
generado inicialmente, y guardarlo en la misma posición

Aclaraciones generales:
-----------------------

 - No se evaluará el código fuente ni la forma en el que se encuentra programado. Solo se analizará que esté cumpliendo con el objetivo funcional
 - No se debe realizar ningún tipo de salida de los datos manipulados en el array. El objetivo es evaluar el uso de recursos y no las operaciones aritméticas realizadas
 - Las estadísticas de procesos son calculadas por el sistema operativo para cada proceso pesado. Al ejecutar un proceso hijo se deberán obtener las estadísticas del proceso hijo y no las del padre que lo lanzó (ver syscall wait3 y wait4)

Entregables:
-----------------

 - Código fuente utilizado para evaluar cada uno de los casos
 - Estructura de datos que se imprime como resultados de cada procesamiento
 - Completar la siguiente tabla:
*Ver tabla*

Conclusiones:
------------------

 - Analice el comportamiento y los datos obtenidos en cada uno de los casos, compare los resultados entre los mismos y explique a qué se deben las diferencias y similitudes en los comportamientos observados
 - Indique qué conceptos teóricos se ven reflejados
