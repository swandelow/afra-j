#!/bin/bash

# Esta funcion tiene como fin verificar que el archivo recibido como parametro
# cumpla con los requisitos para ser un archivo de llamados valido

# Devuelve 0 si el archivo cumple con el formato establecido
# Devuelve 1 si el tipo de archivo es invalido
# Devuelve 2 si la fecha del archivo es invalida
# Devuelve 3 Si la fecha esta fuera de rango
# Devuelve 4 si la central es inexistente.

RUTAARCHIVOCENTRALES="$MAEDIR/CdC.mae"
################################################

function validarRegistroLlamados(){

	# Para empezar nos fijamos que el archivo sea un archivo de texto.
	esTexto=$(file "$1" | cut -d $' ' -f2)

	if [ $esTexto != "ASCII" ]; then
		return 1
	fi

	# Luego nos fijamos que el nombre del archivo tenga un guion bajo
	nombreArchivo=`echo "$1" | sed 's/^.*\/\(.*\)$/\1/'`

	cantOcurrencias=$(grep -o "_" <<< "$nombreArchivo" |wc -l)
	if [ ! "$cantOcurrencias" -eq 1 ]; then
		return 1
	fi


	#le saco la extension
	nombreArchivoSinExtension=`echo "$nombreArchivo" | cut -d'.' -f1`

	# Ya se que el archivo tiene un guion bajo en el nombre, ahora vamos a
	# verificar que cumpla con el formato pedido.
	codigoCentral=`echo "$nombreArchivoSinExtension" | cut -d'_' -f1`
	diaMesAnio=`echo "$nombreArchivoSinExtension" | cut -d'_' -f2`

	# Todas las centrales tienen 3 letras.
	longCodigoCentral=${#codigoCentral}
	if [ ! $longCodigoCentral -eq 3 ]; then
		return 4
	fi


	# Ahora tenemos que ver que el codigo de esta central exista en el archivo de centrales.
	##OJO, CAMBIAR ESTO, Es la ruta a mi archivo de centrales
	# rutaArchivoCentrales="/home/manuel/Desktop/sisop/afra-j/archivos/centrales.csv"

	existeCentral=`grep "$codigoCentral" -R "$RUTAARCHIVOCENTRALES"`
	if [ "$?" -eq 1 ]; then
		return 4
	fi

	# ahora queremos ver que onda con la fecha del archivo, que es la segunda parte.
	# en diaMesAnio viene todo junto y sin separar.
	if [ ! ${#diaMesAnio} -eq 8 ]; then
		return 2;
	fi

	# Los primeros 4 caracteres corresponden al anio.
	# El enunciado dice que deben tener como maximo 1 anio de antiguedad.

	# Validacion 0: ver que el anio, el mes y el dia sean validos.
	#a partir del char 4, agarro 2 caracteres.
	mes=${diaMesAnio:4:2}

	if ! esUnNumero $mes; then
 		return 2
 	fi

 	#Ver que sea menor que 12
	if [ $mes -ge 12 ]; then
		return 2
	fi


	# a partir del char 6, agarro 2 chars
	dia=${diaMesAnio:6:2}
	if ! esUnNumero $dia; then
 		return 2
 	fi

 	# ver que sea menor que 31
	if [ $mes -ge 31 ]; then
		return 2
	fi


	# agarro los primeros 4 digitos
	anio=${diaMesAnio::4}

	if ! esUnNumero $anio; then
		return 2
	fi

	# la fecha de hoy es 20151001
	# primer validacion: que cuando le reste la fecha del archivo sea un numero
	# positivo.
	obtenerFecha

	resultadoResta=$(($fechaHoy - $diaMesAnio))
	if [ "$resultadoResta" -lt 0 ]; then
		return 3
	fi

	# segunda validacion: no puede tener mas de un anio de antiguedad.
	# 20151001  (fecha hoy)
	# 20141001 es el limite
	# --------
	# 00010000
	# Por lo que la resta de la fecha actual menos la fecha del archivo debe ser mayor
	# o igual a 10k.
	if [ "$resultadoResta" -ge 10000 ]; then
		return 3
	fi

	# el archivo de novedades tiene nombre valido
	return 0
}


# Función para obtener la fecha actual.
# Deja el resultado en $fechaHoy para que sea utilizada despues.
function obtenerFecha {
	fechaHoy=`date +%Y%m%d`
}

# recibe un numero en $1 y devuelve
# 0 si es un numero
# 1 si no es un numero
function esUnNumero(){
	regexNum='^[0-9]+$'
	if [[ $1 =~ $regexNum ]]; then
		return 0
	else
		return 1
	fi
}
