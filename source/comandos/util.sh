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

#funcion general para logueo
function log {
	if [ $1 != "" ]
	then
	./Glog.sh "$1" "$2" "$3"
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

# Valida una fecha usando el comando date.
# Devuelve:
#	0 Si es una fecha valida.
#	1 Si es una fecha invalida.
function validarFecha(){
	res=$(date +"%Y-%m-%d" --date=$1)
	return $?
}

# Función para sumar días a una fecha.
# Coloca el resultado en la variable $fecha.
# $1 fecha a incrementar.
# $2 cantidad de días a sumar.
function sumarDias {
	expresion=`date --date=$1 +%s`
	aux=$(echo "$expresion + 3600*24*$2" | bc)
	fecha=$(date -d "1970-01-01 $aux sec GMT" "+%Y-%m-%d")
}
