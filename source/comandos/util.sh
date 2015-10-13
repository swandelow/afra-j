# Verifica que el proceso pasado en el parametro $1 se esta ejecutando.
function estaEjecutandose(){
	res=$(ps -C $1)
	return $?
}

# Función para tener la fecha actual.
# Modifica la variable $hoy que tiene que estar declarada de antemano.
function fechaHoy {
	hoy=`date +%Y-%m-%d`
}
