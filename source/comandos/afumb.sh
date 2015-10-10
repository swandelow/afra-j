#!/bin/bash 

# ACORDARSE DE HACER LO DE LOG Y EL FOR QUE ENGLOBE A TODOS LOS ARCHIVOS. 
 
# Esta función tiene como fin procesar todos los archivos del directorio ACEPDIR. 

# Función para obtener la fecha actual. 
# Deja el resultado en $fechaHoy para que sea utilizada despues. 
function obtenerFecha { 
	fechaHoy=`date +%Y%m%d` 
} 

# SACAR ESTE HARCODEO Y TODOS 
ACEPDIR="/home/nicolasdubiansky/Descargas/afra-j/archivos/ACEPDIR" 
RECHDIR="/home/nicolasdubiansky/Descargas/afra-j/archivos/RECHDIR" #CAMBIAR POR EL DIRECTORIO GENERAL. 
rutaDeArchivos="/home/nicolasdubiansky/Descargas/afra-j/archivos/carpeta" #ESTA RUTA TIENE QUE SER DONDE ESTAN LOS ARCHIVOS. 

# Recorro todos los archivos del directorio y me quedo con el minimo. 
function obtenerArchivoFechaMasAntigua {        
	cd $rutaDeArchivos 
	dir=$(dir) 
	obtenerFecha 
	MINIMO=$fechaHoy 
	for file in $dir; 
	do 
		fechaArchivo=$(echo "$file" | cut -d'_' -f2) 
		fechaArchivoSinExtension=$(echo "$fechaArchivo" | cut -d'.' -f1) 
		if [ $fechaArchivoSinExtension -le $MINIMO ]; then 
			MINIMO=$fechaArchivoSinExtension 
			nombreArchivoMinimo=$file	 
		fi 
	done; 
} 

# Se fija si el archivo esta en PROCDIR. 
# Si está, devuelve 0. 
# Si no está, devuelve 1. 
function verificarQueElArchivoHayaSidoProcesado { 
	# Ahora hay que chequear que no este en el directorio PROCDIR. 
	PROCDIR="/home/nicolasdubiansky/Descargas/afra-j/archivos/procdir" #CAMBIAR POR EL DIRECTORIO GENERAL.	 
	cd "/home/nicolasdubiansky/Descargas/afra-j/archivos/procdir/proc"
	dir=$(dir) 
	# Recorro todos los archivos procesados y me fijo si hay alguno con el mismo nombre. En ese caso muevo el archivo a RECHDIR. 
	for file in $dir; 
	do 
		if [ $file = $nombreArchivoMinimo ]; then 
			resultadoFuncionVerificarArchivoProcesado=0
			return 0 
		fi 
	done; 
	resultadoFuncionVerificarArchivoProcesado=1
	return 1 
} 

# Chequea que la estructura interna sea válida(que tenga 8 campos). 
# Devuelve 0, si es inválida. 
# Devuelve 1, si es válida. 
function verificarCantidadDeCampos { 
	while read line 
	do 
		cantidadPuntoYComa=$(grep -o ";" <<< "$line" |wc -l)	 
		if [ ! "$cantidadPuntoYComa" -eq 7 ]; then 
			resultadoVerificarCampos=0
			return 0 
		fi 
		resultadoVerificarCampos=1
		return 1 
	done < $rutaDeArchivos/$nombreArchivoMinimo 
} 

function obtenerCantidadArchivos { 
	cd $rutaDeArchivos 
	dir=$(dir) 
	for file in $dir; 
	do 
		let cantidadDeArchivosEnElDirectorio=cantidadDeArchivosEnElDirectorio+1 
	done;	 
} 

#se le pasa dos parametros. EL primero es la longitud del codigo de area, y el segundo es la longitud del numero de linea. Despues se mira el numero de resultado para ver si salio todo bien
function validarLongitudNumeroDeLinea (){
	if ( [[ $1 -eq 2 ]] && [[ ! $2 -eq 8 ]] ) || ( [[ $1 -eq 3 ]] && [[ ! $2 -eq 7 ]] ) || ( [[ $1 -eq 4 ]] && [[ ! $2 -eq 6 ]] ) ; then 
		return 1
	fi
	return 0		
}
#grabo en RECHDIR/LLAMADAS el registro rechazado (en su respectivo archivo)
function rechazarRegistro(){
	fuente=$nombreArchivoMinimoSinCsv  # PARA QUE SIRVE ESTO????
	linea="$nombreArchivoMinimo;$motivo;$1"
	cd "$RECHDIR/llamadas"
	echo "$linea" >> "$nombreArchivoMinimoSinCsv.rech" 
}	

#el parametro que recibe es la linea que se quiere escribir en el archivo de llamada sospechosa
function grabarLlamadaSospechosa(){
	lineaAGrabar=$1
	nombreArchivoAGenerarSospechoso=$oficina'_'$anioLlamadaMesLlamada
	PROCDIR="/home/nicolasdubiansky/Descargas/afra-j/archivos/procdir" #CAMBIAR POR EL DIRECTORIO GENERAL.	 
	cd $PROCDIR
	echo "$lineaAGrabar" >> "$nombreArchivoAGenerarSospechoso" 
}

#determino el tipo de llamada. HAY QUE PASARLE EL REGISTRO QUE SE ESTA PROCESANDO COMO PARAMETRO!
function determinarTipoDeLlamada(){
	codPais=$(echo "$1" | cut -d';' -f6) 
	numLineaB=$(echo "$1" | cut -d';' -f8)
	if [ ! "$codPais" == "" ]; then #me fijo que se haya ingresado un codigo de pais (no es obligatorio)
		codPaisExt="$codPais;" 
		existecodPais=`grep "$codPaisExt" -c "/home/nicolasdubiansky/Descargas/afra-j/archivos/CdP.csv"` #me fijo si esta en el maestro de 																paises
		if [[ "$?" -eq 1 ]] || [[ "$numLineaB" == "" ]] ; then ##la segunda condicion es porque dice que tiene que haber un numero en la 												consigna pero es medio al pedo
			motivo="codigo de pais inexistente o no hay numero de linea"
			tipoLLamada="error"
			return 1
		fi
		tipoLLamada="DDI" #guardo tipo de llamada
		return 0
	else 
		codAreaA=$(echo "$1" | cut -d';' -f4)
		codAreaB=$(echo "$1" | cut -d';' -f7)
		existecodAreaB=`grep "$codAreaB" -c "/home/nicolasdubiansky/Descargas/afra-j/archivos/CdA.csv"` #me fijo si esta en el maestro de 																		área
		if [ "$?" -eq 1 ] ; then #No encontro el codigo de area.
			motivo="area erronea"
			return 1
		else
			longCodAreaB=${#codAreaB} 
			longNumLineaB=${#numLineaB}
			resultadoValidacion= validarLongitudNumeroDeLinea "$longCodAreaB" "$longNumLineaB" #llamo a la funcion que valida el 													numero de linea contra el codigo de area
			if [[ $resultadoValidacion -eq 1 ]]; then
				motivo="la suma de las longitudes del código de área y del número de linea B no es la esperada"
				return 1 #esto lo chequeo afuera pero tengo que salir de aca para no grabar el tipo de llamada
			fi
			if [ "$codAreaA" -eq "$codAreaB" ]; then
				tipoLLamada="LOC"
				return 0
			else
				tipoLLamada="DDN"
				return 0
			fi
		fi
		
	fi
}

#HIPOTESIS: Al detectar más de un umbral aplicable a la llamada, se ha decidido considerar solo el primero (sea o no una llamada sospechosa).

#Se fija si hay alguna llamada sospechosa y de ser así, la graba. Además setea los contadores.
function verificarSiHayAlgunUmbralActivo {
	regristroDelArchivoDeLLamadas=$line 
	listaDeRegistrosDeNumeroOrigen=`grep $numLineaA  "/home/nicolasdubiansky/afra-j/archivos/umbrales.csv"`	

	for registro in $listaDeRegistrosDeNumeroOrigen
	do 
		estadoUmbral=$(echo "$registro" | cut -d';' -f7) #Obtengo el estado del umbral.
		if [ $estadoUmbral == "Activo" ]; then
			let contadorDeLlamadasConUmbral=contadorDeLlamadasConUmbral+1
			tope=$(echo "$registro" | cut -d';' -f6) 
			codigoArea=$(echo "$registro" | cut -d';' -f2) 
			numeroDeLineaOrigen=$(echo "$registro" | cut -d';' -f3) 
			tipoDeLlamadaUmbral=$(echo "$registro" | cut -d';' -f4) 
			codigoDestino=$(echo "$registro" | cut -d';' -f5) 
			if ([[ $tope < $tiempoDeConversacion ]]) && 
			   ([ $codigoArea == $codArea ]) &&
			   ([ $numeroDeLineaOrigen == $numLineaA ]) ; then
				if ( [[ $tipoDeLlamadaUmbral == "DDI" ]] && ([[ $codigoDestino == $codPais ]] || 
					[[ $codigoDestino == "" ]]) ) ||
				   ( ([[ $tipoDeLlamadaUmbral == "DDN" ]] || [[ $tipoDeLlamadaUmbral == "LOC" ]]) &&			 					     ([[ $codigoDestino == $codAreaB ]] || 
					[[ $codigoDestino == "" ]]) ) ; then
						let contadorDeLlamadasSospechosas=contadorDeLlamadasSospechosas+1
						idUmbral=$(echo "$registro" | cut -d';' -f1) 
						idAgente=$(echo "$regristroDelArchivoDeLLamadas" | cut -d';' -f1) 
						#ESTA FALLANDO CON LOPEZ BAIOBRENDA PORQUE CUANDO HACE EL GREP POR APELLIDO COMPUESTO CON 											ESPACIO FALLA
						registroDelAgente=`grep $idAgente "/home/nicolasdubiansky/Descargas/afra-j/archivos/agentes.csv"`
						oficina=$(echo "$registroDelAgente" | cut -d';' -f4)
						fechaHoraLLamada=$(echo "$regristroDelArchivoDeLLamadas" | cut -d';' -f2)
						fechaSola=$(echo "$fechaHoraLLamada" | cut -d' ' -f1)
						horaSola=$(echo "$fechaHoraLLamada" | cut -d' ' -f2)
						fechaDeLaLlamada=$(echo "$fechaHoraLLamada" | cut -d' ' -f1)
  						anioDeLaLlamada=$(echo "$fechaDeLaLlamada" | cut -d'/' -f3)
  						mesDeLaLlamada=$(echo "$fechaDeLaLlamada" | cut -d'/' -f2)
						anioLlamadaMesLlamada=$anioDeLaLlamada$mesDeLaLlamada
						idCentral=$(echo "$nombreArchivoMinimo" | cut -d'_' -f1)
						codAreaDeLaLlamada=$(echo "$line" | cut -d';' -f4)
						codPaisNumeroB=$(echo "$line" | cut -d';' -f6)
						codAreaNumeroB=$(echo "$line" | cut -d';' -f7)
						numeroLineaB=$(echo "$line" | cut -d';' -f8)
						fechaFormatoArchivoInput=$(echo "$nombreArchivoMinimoSinCsv" | cut -d'_' -f2)
						#separamos la fecha de la hora con una comilla porque si queremos separar con espacio 							concatena todo hasta el espacio, y todo lo que venia despues lo pierde.
						primerRenglon="$idCentral;$idAgente;$idUmbral;$tipoDeLlamadaUmbral;$fechaSola'$horaSola"
						segundoRenglon=";$tiempoDeConversacion;$codAreaDeLaLlamada;$numLineaA"
						tercerRengln=";$codPaisNumeroB;$codAreaNumeroB;$numeroLineaB;$fechaFormatoArchivoInput"	
						registroAEscribir="$primerRenglon$segundoRenglon$tercerRengln"
						grabarLlamadaSospechosa $registroAEscribir
						return 1
				else
					let contadorDeLlamadasNoSospechosas=contadorDeLlamadasNoSospechosas+1
					return 1				
				fi				
			else
				let contadorDeLlamadasNoSospechosas=contadorDeLlamadasNoSospechosas+1
				return 1
			fi
		fi
	done
	let contadorDeLlamadasSinUmbral=contadorDeLlamadasSinUmbral+1
	return 0					
}

function validarRegistro { #funcion que valida registro por registro que se verifiquen las especificaciones
			while read line 
			do
				let contadorDeLlamadas=contadorDeLlamadas+1				
				agente=$(echo "$line" | cut -d';' -f1) #chequeo que el nombre de agente este en el maestro
				agente="$agente;"  #agrego coma porque si pongo MARIO matchea con MARIORUIZ y esta mal
				existeAgente=`grep "$agente" -c "/home/nicolasdubiansky/Descargas/afra-j/archivos/agentes.csv"` #chequeo que exista
				if [ "$?" -eq 1 ]; then
					motivo="agente erroneo"
					echo $motivo
					let contadorDeLlamadasRechazadas=contadorDeLlamadasRechazadas+1
					rechazarRegistro "$line" #lo escribo en rechazados
					continue
				fi
				#chequeo que el codigo de area A sea correcto
				codArea=$(echo "$line" | cut -d';' -f4)
				codAreaExt=";$codArea"
				existeArea=`grep "$codAreaExt" -c "/home/nicolasdubiansky/Descargas/afra-j/archivos/CdA.csv"`
				
				if [ "$?" -eq 1 ]; then
					motivo="area erronea"
					#FALTA EL LOG.
					let contadorDeLlamadasRechazadas=contadorDeLlamadasRechazadas+1
					#grabo el reg en llamadas rechazadas
					rechazarRegistro "$line"
					continue
				fi
				#me fijo que la longitud de codigo de area y de la linea de telefono sean validos
				longCodAreaA=${#codArea} #esta funcion da la longitud
				numLineaA=$(echo "$line" | cut -d';' -f5)
				longNumLineaA=${#numLineaA}
				resultadoValidacionA= validarLongitudNumeroDeLinea "$longCodAreaA" "$longNumLineaA"
				if [[ $resultadoValidacionA -eq 1 ]]; then
					motivo="la suma de las longitudes del código de área y del número de linea A no es la esperada"
					#FALTA EL LOG
					let contadorDeLlamadasRechazadas=contadorDeLlamadasRechazadas+1
					rechazarRegistro "$line"
					continue
				fi
				resultadoFuncion= determinarTipoDeLlamada "$line" #devuelve el nombre del tipo de llamada en una variable, esto 												lo vamos a usar para grabar sospechosas	
				if [[ $resultadoFuncion -eq 1 ]]; then #Quiere decir que hubo algun error al determinar el tipo de llamada
					#LOGUEAR, EL MOTIVO YA ESTA SETEADO.
					let contadorDeLlamadasRechazadas=contadorDeLlamadasRechazadas+1
					rechazarRegistro "$line"
					continue
				fi
				tiempoDeConversacion=$(echo "$line" | cut -d';' -f3)
				if [[ $tiempoDeConversacion -lt 0 ]]; then
					motivo="tiempo de conversacion menor a cero"
					let contadorDeLlamadasRechazadas=contadorDeLlamadasRechazadas+1
					#LOGUEAR
					rechazarRegistro "$line"
					continue
				fi

				# Si llegó hasta acá, el registro es válido.
				
				#Chequeo si existe algún umbral activo para el número de linea A (origen).
				existeUmbral=`grep "$numLineaA" -c "/home/nicolasdubiansky/afra-j/archivos/umbrales.csv"` #chequeo que exista
				if [ "$?" -eq 1 ]; then
					motivo="no hay ningún umbral activo para el número de origen"
					#LOGUEAR
					let contadorDeLlamadasSinUmbral=contadorDeLlamadasSinUmbral+1
					continue
				fi

				verificarSiHayAlgunUmbralActivo
			done < "$rutaDeArchivos/$nombreArchivoMinimo" 
}

cantidadArchivosRechazados=0
cantidadArchivosProcesados=0
cantidadDeArchivosEnElDirectorio=0 
obtenerCantidadArchivos 
rutaComandoGraLog="/home/nicolasdubiansky/Descargas/afra-j/source/comandos"
cd $rutaComandoGraLog
bash ./GraLog.sh "AFUMB" "Inicio de AFUMB" "INFO"  
bash ./GraLog.sh "AFUMB" "Cantidad de archivos a procesar:$cantidadDeArchivosEnElDirectorio" "INFO"  

#Procesa todos los archivos del directorio.
for (( i=0; i < $cantidadDeArchivosEnElDirectorio; i++ )); 
do 
	contadorDeLlamadas=0
	contadorDeLlamadasRechazadas=0
	contadorDeLlamadasConUmbral=0
	contadorDeLlamadasSinUmbral=0
	contadorDeLlamadasSospechosas=0
	contadorDeLlamadasNoSospechosas=0	
	obtenerArchivoFechaMasAntigua 
	verificarQueElArchivoHayaSidoProcesado
	if [ $resultadoFuncionVerificarArchivoProcesado == 0 ]; then 
		cd $rutaComandoGraLog
		bash ./GraLog.sh "AFUMB" "Se rechaza el archivo por estar DUPLICADO" "ERROR" 
		# Para poder ejecutar el comando move.sh. ACORDARSE DE CAMBIAR POR MOVERA.SH
		let cantidadArchivosRechazados=cantidadArchivosRechazados+1
		rutaComandoMove="/home/nicolasdubiansky/Descargas/afra-j/source/comandos" 
		cd $rutaComandoMove	 
		bash ./move.sh "$rutaDeArchivos/$nombreArchivoMinimo" "$RECHDIR" 
	else 
		verificarCantidadDeCampos
		if [ $resultadoVerificarCampos == 0 ]; then 
			cd $rutaComandoGraLog
			bash ./GraLog.sh "AFUMB" "Se rechaza el archivo porque su estructura no se corresponde con el formato esperado" "ERROR"
 			let cantidadArchivosRechazados=cantidadArchivosRechazados+1
			# Para poder ejecutar el comando move.sh. ACORDARSE DE CAMBIAR POR MOVERA.SH 
			rutaComandoMove="/home/nicolasdubiansky/Descargas/afra-j/source/comandos" 
			cd $rutaComandoMove	 
			bash ./move.sh "$rutaDeArchivos/$nombreArchivoMinimo" "$RECHDIR" 
		else 
			cd $rutaComandoGraLog
			bash ./GraLog.sh "AFUMB" "Archivo a procesar:$nombreArchivoMinimo" "INFO" 			
			cd "$RECHDIR/llamadas"

			let cantidadArchivosProcesados=cantidadArchivosProcesados+1
			nombreArchivoMinimoSinCsv=$(echo "$nombreArchivoMinimo" | cut -d'.' -f1) #le saco el .csv al nombre!
			> "$nombreArchivoMinimoSinCsv.rech" 
			validarRegistro #valido todo los registros del archivo
			rutaComandoMove="/home/nicolasdubiansky/Descargas/afra-j/source/comandos" 
			cd $rutaComandoMove 
			bash ./move.sh "$rutaDeArchivos/$nombreArchivoMinimo" "/home/nicolasdubiansky/Descargas/afra-j/archivos/procdir/proc" 
		fi 
	fi 
	echo "Llamadas totales: "$contadorDeLlamadas
	echo "Llamadas rechazadas: "$contadorDeLlamadasRechazadas
	echo "Llamadas con umbral: "$contadorDeLlamadasConUmbral 
	echo "Llamadas sin umbral: "$contadorDeLlamadasSinUmbral
	echo "Llamadas sospechosas: "$contadorDeLlamadasSospechosas
	echo "Llamadas no sospechosas: "$contadorDeLlamadasNoSospechosas	
	echo " "
done 
			cd $rutaComandoGraLog
			bash ./GraLog.sh "AFUMB" "Cantidad de archivos procesados:$cantidadArchivosProcesados" "INFO" 	
			bash ./GraLog.sh "AFUMB" "Cantidad de archivos rechazados:$cantidadArchivosRechazados" "INFO" 	
			bash ./GraLog.sh "AFUMB" "Fin de AFUMB" "INFO" 	
