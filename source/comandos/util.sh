# Verifica que el proceso pasado en el parametro $1 se esta ejecutando.
function estaEjecutandose(){
	res=$(ps -C $1)
	return $?
}

##
# Valida que un proceso que se pasa por parametro, se este ejecutando una sola vez.
#
function estoyEjecutandome(){
	res=$(ps -A | grep $1 | wc -l)
	if [ $res -gt 1 ]
	then
		return 1 
	else
		return 0
	fi
}


#Devuelve la cantidad de archivos de un directorio
function cantidadArchivos(){
	directorio="."

	if [ $# <> 0 ]
	then
		directorio=$1
	fi

	resultado=$(ls -1 $directorio | wc -l)
	return $resultado
}

#Función propia para salida a consola.
function eko {
	echo "$1"
}

# Función para comparar fechas.
# Devuelve:
# 	-1 si la primer fecha es menor.
#	0 si son iguales.
#	1 si la primera es mayor.
function compararFechas {
	fechaSimple1=`echo $1 | sed 's/\-//g'`
	fechaSimple2=`echo $2 | sed 's/\-//g'`
	if [ $((fechaSimple1)) -lt $((fechaSimple2)) ]
	then
		echo "-1"
	elif [ $((fechaSimple1)) -eq $((fechaSimple2)) ]
	then
		echo "0"
	else
		echo "1"
	fi
}

# Función para tener la fecha actual.
# Modifica la variable $hoy que tiene que estar declarada de antemano.
function fechaHoy {
	hoy=`date +%Y-%m-%d`
}

# Esta funcion va a recibir un string "doble" por parametro y va a decir si la fecha
# es valida o no.
# El formato de las fechas a utilizarse es el siguiente
# dd/mm/YYYY hh:mm:ss+p.m.

# IMPORTANTE: las fechas se pasan asi
# NOTAR QUE NO SE PASA EL PARAMETRO ENTRE COMILLAS

# if validarFecha $fecha; then
#  	echo Es una fecha valida
# else
# 	echo es una fecha invalida.
# fi

function validarFecha(){

	#Primero validar que haya recibido si o si 3 parametros.
	if [ ! "$#" -eq 2 ]; then
		return 1
	fi

	primeraParte=$1
	segundaParte=$2

		#el primer parametro es la fecha. Deberia tener exactamente 10 caracteres
	if [ ! ${#primeraParte} -eq 10 ]; then
		return 1
	fi

	# para empezar me fijo que hayan 2 "/" para evitar problemas mayores.
	cantOcurrencias=$(grep -o "/" <<< "$primeraParte" |wc -l)
	if [ ! "$cantOcurrencias" -eq 2 ]; then
		return 1
	fi
	
	# ahora debemos intercambiar el orden de los dias con los meses
	# viene como dd/mm/YYYY
	# y lo necesito como mm/dd/YYYY para usar la funcion de bash.
	mes=`echo "$primeraParte" | cut -d'/' -f1`
	dia=`echo "$primeraParte" | cut -d'/' -f2`
	anio=`echo "$primeraParte" | cut -d'/' -f3`

	fechaParseada="$dia/$mes/$anio"

	# Si la funcion date devuelve errores, la fecha no era valida.
	aux=$(date +"%d/%m/%Y" --date=$fechaParseada)
	if [ "$?" -eq 1 ]; then
		return 1
	fi




	# La segunda parte esta compuesta por la hora y el am/pm
	# hh:mm:ss+a.m.  = 12 caracteres 
	if [ ! ${#segundaParte} -eq 12 ]; then
		return 1
	fi

	# Ahora nos fijamos que los ultimos 4 caracteres tengan la finalizacion de am o pm
	amOpm=${segundaParte: -4}
	regexAmPm='[ap].m.'
	if [[ ! "$amOpm" =~ $regexAmPm ]]; then
		return 1
	fi

	# Ya sabemos que termina en am o pm si llegamos aca.
	# para obtener el horario, le achuramos los ultimos 4 caracteres
	# que corresponden al am o pm
	horario=${segundaParte::-4}

	# de nuevo usamos la funcion date para que nos valide la hora.
	# Si la funcion date devuelve errores, la fecha no era valida.
	aux=$(date +"%d/%m/%Y" --date=$horario)
	return "$?"

} 2> /dev/null
# "hack" para que muestre el error de invalid date por consola

# Función para sumar días a una fecha.
# Coloca el resultado en la variable $fecha.
# $1 fecha a incrementar.
# $2 cantidad de días a sumar.
function sumarDias {
	expresion=`date --date=$1 +%s`
	aux=$(echo "$expresion + 3600*24*$2" | bc)
	fecha=$(date -d "1970-01-01 $aux sec GMT" "+%Y-%m-%d")
}
