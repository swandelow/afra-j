#!/usr/bin/perl

# use warnings;

use Scalar::Util qw(looks_like_number);

############################################################################################
# En este archivo van a estar todas las funciones que tienen que ver
# Con la generacion de estadsitcas del AFLIST.
#


$ESTADO_GRABACION = 0;
# Siempre saco los datos de las llamadas sospechosas


# FORMATO DE LOS REGISTROS:
my $ID_CENTRAL = 0;
my $ID_AGENTE = 1;
my $ID_UMBRAL = 2;
my $TIPO_LLAMDA =3;
my $INICIO_LLAMADA = 4;
my $TIEMPO_CONV = 5;
my $AREA_NUM_A = 6; 
my $NUMERO_ORIGEN = 7;
my $CODIGO_PAIS_B = 8;  # este a veces viene vacio 
my $COD_AREA_B = 9; # si el anterior es vacio, aca tengo el codigo del area.
my $NUMERO_DESTINO = 10;
my $FECHA_ARCHIVO = 11;



my $PROCDIR = $ENV{'PROCDIR'};
$INPUT_CONSULTAS_GLOBAL = $PROCDIR;
#Setear la ruta a los archivos de sospechas.
my $PATH_MAEDIR = $ENV{'MAEDIR'};

my $RUTA_REPODIR = $ENV{'REPODIR'};
my $RUTA_ESTADISTICAS = "$RUTA_REPODIR" . "/estadisticas";
my $RUTA_CENTRALES = "$PATH_MAEDIR" . "/CdC.mae";
my $RUTA_AGENTES = "$PATH_MAEDIR" . "/agentes.mae";
my $RUTA_CIUDADES = "$PATH_MAEDIR" . "/CdA.mae";
my $RUTA_PAISES = "$PATH_MAEDIR" . "/CdP.mae";
my $RUTA_UMBRALES = "$PATH_MAEDIR" . "/umbral.tab";

my $CANT_RANKING = 4;
# Por defecto el directorio input de las consultas
# será el directorio de llamadas sospechosas, output de AFUMB.
$INPUT_DIR = $PROCDIR;

my $extensionArchivo = "000";
my $archivoAGuardar = "$RUTA_REPODIR/$extensionArchivo";

my $rand1 = int(rand(1000));
my $randEstadisticas = int(rand(1000000));

my $rutaConsulta = "$RUTA_REPODIR/subllamadas.$rand1";
my $rutaEstadistica = "$RUTA_REPODIR/subllamadas_estadisticas.$randEstadisticas";




# 	unless(open FILE, '>'.$rutaConsulta) {
#     	# Die with error message 
#     	# if we can't open it.
#     	die "\nError escribiendo archivo $rutaConsulta\n";

#     	close $rutaConsulta;
# 	}

# 	unless(open FILE, '>'.$rutaEstadistica) {
#     	# Die with error message 
#     	# if we can't open it.
#     	die "\nError escribiendo archivo $rutaEstadistica\n";

#     	close $rutaEstadistica;
# }
sub crearNombreArchivoEstadisticas {
	# Pide nombre al usuario y le agrega sufijo random para evitar nombres duplicados.
	while(1) {
		eko("Ingrese nombre de archivo donde se grabarán las estadísticas:");
		$input = <STDIN>;
		chomp($input);
		if ($input eq '') { 
			eko("Ingrese un nombre por favor.");
			eko("");
		} else {
			my $sufijo_random = int(rand(1000000));
			my $nombre = "$input.$sufijo_random";
			return $nombre;
		}	
	}
}

sub grabarEstadistica {
	my ($nombre_archivo, $entry) = @_;
	my $path_archivo = "$RUTA_ESTADISTICAS". "/$nombre_archivo"; 
	open(my $fh, '>>', $path_archivo);
	print $fh "$entry\n";
	close $fh;
}

sub grabarEstadisticaEnArchivo {
	my ($entry) = @_;
	open(my $fh, '>>', $rutaEstadistica);
	print $fh "$entry\n";
	close $fh;
}

sub grabarConsultaEnArchivo{
	my ($entry) = @_;
	open(my $fh, '>>', $rutaConsulta);
	print $fh "$entry\n";
	close $fh;	
}



# Hace un print del primer parametro.
sub eko2{

	my ($msg) = @_;
	print "$msg \n";
}

sub imprimirSeparador{
	eko2("---------------------");
}
# Le paso el nombre del campo del registro que quiero obtener.

# Primer parametro: El registro entero.
# Segundo parametro: El campo.
sub obtenerCampo2{
	my ($registro, $campo) = @_;
	@campos = split(";",$registro);
	return $campos[$campo];
}

sub displayHashCentrales {

	my (%hash) = @_;
	my $puestos_a_mostrar = $CANT_RANKING;
	# Ordeno las keys del mapa de acuerdo a su valor correspondiente.
	my @keys = sort { $hash{$b} <=> $hash{$a} } keys %hash;
	my @values = @hash{@keys};

	if ($puestos_a_mostrar > $#keys) {
		$puestos_a_mostrar = $#keys;
	}

	if ($ESTADO_GRABACION == 0) {
		# Imprimo por pantalla los resultados del ranking.
		for my $i (0..$puestos_a_mostrar) {
			$nombre_central = `grep "$keys[$i]" -R $RUTA_CENTRALES | cut -d';' -f2`;
			chomp($nombre_central);
			$entry ="$keys[$i] -> $values[$i].". " $nombre_central";
			eko($entry);	
		}
	 	
		imprimirSeparador;
	} else {
		# Guardo en un archivo el resultado del ranking.
		my $nombre_archivo = crearNombreArchivoEstadisticas();

		for my $i (0..$puestos_a_mostrar) {
			$nombre_central = `grep "$keys[$i]" -R $RUTA_CENTRALES | cut -d';' -f2`;
			chomp($nombre_central);
			$entry ="$keys[$i] -> $values[$i].". " $nombre_central";

			grabarEstadistica($nombre_archivo, $entry);
		}

		eko("Se grabó el ranking en archivo: $nombre_archivo");
	 	
		imprimirSeparador;	
	}
}

sub displayHashAgentes {

	my (%hash) = @_;
	my $puestos_a_mostrar = $CANT_RANKING;
	# Ordeno las keys del mapa de acuerdo a su valor correspondiente.
	my @keys = sort { $hash{$b} <=> $hash{$a} } keys %hash;
	my @values = @hash{@keys};

	if ($puestos_a_mostrar > $#keys) {
		$puestos_a_mostrar = $#keys;
	}

	if ($ESTADO_GRABACION == 0) {
		# Imprimo por pantalla los resultados del ranking.
		for my $i (0..$puestos_a_mostrar) {
			$mail = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f5`;
			$oficina = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f4`;

			# necesario quitar el salto del linea por cuestiones de display.
			chomp($mail);
			chomp($oficina);

			$entry="$keys[$i]  -> #$values[$i] -> "."Mail: $mail"." oficina: $oficina";
			eko($entry);	
		}
	 	
		imprimirSeparador;
	} else {
		# Guardo en un archivo el resultado del ranking.
		my $nombre_archivo = crearNombreArchivoEstadisticas();

		for my $i (0..$puestos_a_mostrar) {
			$mail = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f5`;
			$oficina = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f4`;

			# necesario quitar el salto del linea por cuestiones de display.
			chomp($mail);
			chomp($oficina);

			$entry="$keys[$i]  -> #$values[$i] -> "."Mail: $mail"." oficina: $oficina";

			grabarEstadistica($nombre_archivo, $entry);
		}

		eko("Se grabó el ranking en archivo: $nombre_archivo");
	 	
		imprimirSeparador;	
	}
}

sub displayHashOficinas {

	my (%hash) = @_;
	my $puestos_a_mostrar = $CANT_RANKING;
	# Ordeno las keys del mapa de acuerdo a su valor correspondiente.
	my @keys = sort { $hash{$b} <=> $hash{$a} } keys %hash;
	my @values = @hash{@keys};

	if ($puestos_a_mostrar > $#keys) {
		$puestos_a_mostrar = $#keys;
	}

	if ($ESTADO_GRABACION == 0) {
		# Imprimo por pantalla los resultados del ranking.
		for my $i (0..$puestos_a_mostrar) {
			$entry = "Oficina $keys[$i] -> $values[$i].";

			eko($entry);	
		}
	 	
		imprimirSeparador;
	} else {
		# Guardo en un archivo el resultado del ranking.
		my $nombre_archivo = crearNombreArchivoEstadisticas();

		for my $i (0..$puestos_a_mostrar) {
			$entry = "Oficina $keys[$i] -> $values[$i].";

			grabarEstadistica($nombre_archivo, $entry);
		}

		eko("Se grabó el ranking en archivo: $nombre_archivo");
	 	
		imprimirSeparador;	
	}
}

# 1- Analizar todos los registros de llamadas sospechosas e ir acumulando
# en el contador de cada central.
# 2- Hacer un sort de las claves DESC.
# 3- Hacer un match con el archivo de las centrales para mostrar el codigo y
# su descripcion.

# ya sabemos de ante mano que existe la central en el archivo de centrales
sub mostrarCentralMasSospechosas {

	my (@archivos) = @_;

	eko2("---------------------------------------");
	eko2("----- CENTRALES SOSPECHOSAS -----------");
	eko2("---------------------------------------");
	
	my %hashCentrales;
	my %hashTiempoConversacion;

	foreach $archivo (@archivos) {
  		$rutaSospecha = "$INPUT_CONSULTAS_GLOBAL" . "/$archivo";

  		#eko("rutaSospecha: $rutaSospecha");

		open(ENT,"<$rutaSospecha") || die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$idCentral = obtenerCampo2("$linea", "$ID_CENTRAL");
			$tiempoConversacion = obtenerCampo2("$linea", "$TIEMPO_CONV");

			# Incremento el contador de llamadas sospechosas.
			$hashCentrales{$idCentral}++;
			# Acumulo tiempos de conversación.
			$hashTiempoConversacion{$idCentral} += $tiempoConversacion;
		}
		close(ENT);
	}

	# Selecciona el tipo de ranking que se quiere mostrar.
	my $input_invalido = 1;
	while($input_invalido) {
		eko("Seleccione que tipo de ranking desea:");
		eko("1) Ranking por cantidad de llamadas.");
		eko("2) Ranking por tiempos de conversación.");
		eko("3) Ambos rankings.");

		$inputSeleccionado = <STDIN>;
		chomp($inputSeleccionado);

		if ($inputSeleccionado == 1) {
			$input_invalido = 0;
			displayHashCentrales(%hashCentrales);
		} elsif ($inputSeleccionado == 2) {
			$input_invalido = 0;
			displayHashCentrales(%hashTiempoConversacion);
		} elsif ($inputSeleccionado == 3) {
			$input_invalido = 0;
			eko("RANKING POR CANTIDAD DE LLAMADAS.");
			eko("");
			displayHashCentrales(%hashCentrales);
			eko("RANKING POR TIEMPOS DE CONVERSACIÓN.");
			eko("");
			displayHashCentrales(%hashTiempoConversacion);
		} else {
			eko("Ingrese una opción valida por favor."); 
		}
	}
}


# no mostrarlo si tiene solo 1 llamada.
sub mostrarRankingDeUmbrales{
	eko2("---------------------------------------");
	eko2("------- RANKING DE UMBRALES -----------");
	eko2("---------------------------------------");

	my (@archivos) = @_;

	my %hashUmbrales;

	foreach $archivo (@archivos) {
  		$rutaSospecha = "$INPUT_CONSULTAS_GLOBAL" . "/$archivo";

		open(ENT,"<$rutaSospecha") || die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$idUmbral = obtenerCampo2("$linea", "$ID_UMBRAL");

			# Incremento el contador.
			$hashUmbrales{$idUmbral}++;
		}
		close(ENT);
	}


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada central
	my @keys = sort { $hashUmbrales{$b} <=> $hashUmbrales{$a} } keys % hashUmbrales;
	my @values = @hashUmbrales{@keys};

	my $puestos_a_mostrar = $CANT_RANKING;
	if ($puestos_a_mostrar > $#keys) {
		$puestos_a_mostrar=$#keys;
	}
	for my $i (0..$puestos_a_mostrar){
		# el enunciado pedia ignorar umbrales 
		if ($values[$i] > 1){
			$entry= "ID UMBRAL: $keys[$i] ->  #$values[$i].";

			# ESCRIBIR EN ARCHIVO.
			if ($ESTADO_GRABACION == 0){
				eko($entry);	
			} else {
				grabarEstadisticaEnArchivo("$entry");
			}
		}
	}

	imprimirSeparador;
}

sub mostrarAgentesMasSospechosos {

	eko2("---------------------------------------");
	eko2("------ Agentes más sospechosos --------");
	eko2("---------------------------------------");

	my (@archivos) = @_;

	my %hashAgentes;
	my %hashTiempoConversacion;

	foreach $archivo (@archivos) {
  		$rutaSospecha = "$INPUT_CONSULTAS_GLOBAL" . "/$archivo";

		open(ENT,"<$rutaSospecha") || die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$idAgente = obtenerCampo2("$linea", "$ID_AGENTE");
			$tiempoConversacion = obtenerCampo2("$linea", "$TIEMPO_CONV");

			# Incremento el contador.
			$hashAgentes{$idAgente}++;
			# Acumulo tiempos de conversación.
			$hashTiempoConversacion{$idAgente} += $tiempoConversacion;
		}
		close(ENT);
	}

	# Selecciona el tipo de ranking que se quiere mostrar.
	my $input_invalido = 1;
	while($input_invalido) {
		eko("Seleccione que tipo de ranking desea:");
		eko("1) Ranking por cantidad de llamadas.");
		eko("2) Ranking por tiempos de conversación.");
		eko("3) Ambos rankings.");

		$inputSeleccionado = <STDIN>;
		chomp($inputSeleccionado);

		if ($inputSeleccionado == 1) {
			$input_invalido = 0;
			displayHashAgentes(%hashAgentes);
		} elsif ($inputSeleccionado == 2) {
			$input_invalido = 0;
			displayHashAgentes(%hashTiempoConversacion);
		} elsif ($inputSeleccionado == 3) {
			$input_invalido = 0;
			eko("RANKING POR CANTIDAD DE LLAMADAS.");
			eko("");
			displayHashAgentes(%hashAgentes);
			eko("RANKING POR TIEMPOS DE CONVERSACIÓN.");
			eko("");
			displayHashAgentes(%hashTiempoConversacion);
		} else {
			eko("Ingrese una opción valida por favor."); 
		}
	}
}

sub mostrarOficinaMasSospechosa {

	eko2("----------------------------------------");
	eko2("------- Oficinas más sospechosas -------");
	eko2("----------------------------------------");

	my (@archivos) = @_;

	my %hashOficinas;
	my %hashTiempoConversacion;

	foreach $archivo (@archivos) {
		$rutaSospecha = "$INPUT_CONSULTAS_GLOBAL/$archivo";

		open(ENT,"<$rutaSospecha") || die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$idAgente = obtenerCampo2("$linea", "$ID_AGENTE");
			$tiempoConversacion = obtenerCampo2("$linea", "$TIEMPO_CONV");

			$oficina = `grep "$idAgente" -R $RUTA_AGENTES | cut -d';' -f4`;
			chomp($oficina);

			# Incremento el contador de cada oficina.
			$hashOficinas{$oficina}++;
			$hashTiempoConversacion{$oficina} += $tiempoConversacion;
		}
		close(ENT);
	}

	# Selecciona el tipo de ranking que se quiere mostrar.
	my $input_invalido = 1;
	while($input_invalido) {
		eko("Seleccione que tipo de ranking desea:");
		eko("1) Ranking por cantidad de llamadas.");
		eko("2) Ranking por tiempos de conversación.");
		eko("3) Ambos rankings.");

		$inputSeleccionado = <STDIN>;
		chomp($inputSeleccionado);

		if ($inputSeleccionado == 1) {
			$input_invalido = 0;
			displayHashOficinas(%hashOficinas);
		} elsif ($inputSeleccionado == 2) {
			$input_invalido = 0;
			displayHashOficinas(%hashTiempoConversacion);
		} elsif ($inputSeleccionado == 3) {
			$input_invalido = 0;
			eko("RANKING POR CANTIDAD DE LLAMADAS.");
			eko("");
			displayHashOficinas(%hashOficinas);
			eko("RANKING POR TIEMPOS DE CONVERSACIÓN.");
			eko("");
			displayHashOficinas(%hashTiempoConversacion);
		} else {
			eko("Ingrese una opción valida por favor."); 
		}
	}
}

sub mostrardDestinoMasSospechoso {

	eko2("----------------------------------------");
	eko2("------- Destinos más sospechosos -------");
	eko2("----------------------------------------");

	# En esta variable voy a ir acumulando los contadores de los destinos.
	my (@archivos) = @_;

	my %hashLineaDestino;
	my %hashCodigoPais;
	my %hashCodigoArea;

	foreach $archivo (@archivos) {
  		$rutaSospecha = "$INPUT_CONSULTAS_GLOBAL/" . "$archivo";

		open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$destinoSospechoso = obtenerCampo2("$linea", "$NUMERO_DESTINO");
			$codigoPais = obtenerCampo2("$linea", "$CODIGO_PAIS_B");
			$codigoArea = obtenerCampo2("$linea", "$COD_AREA_B");

			# Incremento contador de llamadas al nro de linea destino.
			$hashLineaDestino{$destinoSospechoso}++;
			#  Si existe en el registro, almaceno el codigo de pais del nro destino.
			$hashCodigoPais{$destinoSospechoso} = $codigoPais if ($codigoPais ne '');
			#  Si existe en el registro, almaceno el codigo de area del nro destino.
			$hashCodigoArea{$destinoSospechoso} = $codigoArea if ($codigoArea ne '');

		}
		close(ENT);
	}

	my $puestos_a_mostrar = $CANT_RANKING;
	# Ordeno las keys del mapa de acuerdo a su valor correspondiente.
	my @keys = sort { $hashLineaDestino{$b} <=> $hashLineaDestino{$a} } keys %hashLineaDestino;
	my @values = @hashLineaDestino{@keys};

	if ($puestos_a_mostrar > $#keys) {
		$puestos_a_mostrar = $#keys;
	}

	for my $i (0..$puestos_a_mostrar) {
		my $nro_destino = $keys[$i];
		my $conteo = $values[$i];

		my $cod_area = $hashCodigoArea{$nro_destino};
		my $cod_pais = $hashCodigoPais{$nro_destino};

		$entry = "Nro. de linea: $nro_destino -> $conteo. ";

		# Si existe, agrego información del área	
		if ($cod_area) {
			my $nombre_area = `grep "$cod_area" -m 1 -R $RUTA_CIUDADES | cut -d';' -f1`;
			chomp($nombre_area);
			my $detalle_area = "Cod. de área: $cod_area, Area: $nombre_area. ";

			$entry = $entry.$detalle_area;
		}

		# Si existe, agrego información del país
		if ($cod_pais) {
			my $nombre_pais = `grep "$cod_pais" -m 1 -R $RUTA_PAISES | cut -d';' -f2`;
			chomp($nombre_pais);
			my $detalle_pais = "Cod. de país: $cod_pais, País: $nombre_pais.";

			$entry = $entry.$detalle_pais;
		}

		if ($ESTADO_GRABACION == 0){
			eko($entry);	
		} else {
			grabarEstadisticaEnArchivo("$entry");
		}
	}
}


# Hace un print del mensaje recibido por parametro.
# Le agrega el \n al final para que sea mas facil.

sub eko{
	my ($msg) = @_;
	print "$msg \n";
}


# Se fija cual tiene una duracion mas larga
# Se usara para el sort.
# $1, la clave de un hash
# $2, otra clave.

# Clave del hash:idcentral ; idAgente ; duracionLlamada ; numeroDestino
sub comparadorHashes{
	my ($claveA, $claveB) = @_;
	@camposA = split(";",$claveA);
	@camposB = split(";",$claveB);

	$duracionA = $camposA[2];
	$duracionB = $camposB[2];

	# eko($duracionA <=> $duracionB);
	return ($duracionA <=> $duracionB);
}

# $1, un registro del archivo de novedades.
# devuelve un string con la clave para el hash
sub obtenerClaveHash{
	my ($registro) = @_;

	$idCentral = obtenerCampo($registro, $ID_CENTRAL);
	$idAgente = obtenerCampo($registro, $ID_AGENTE);
	$duracionLlamada = obtenerCampo($registro, $TIEMPO_CONV);
	$numeroDestino = obtenerCampo($registro, $NUMERO_DESTINO);

	return ("$idCentral;$idAgente;$duracionLlamada;$numeroDestino");
}

sub mostrarOpcionesEstadisticas{
	eko("Opciones posibles:");
	eko("a) Ranking de centrales");
	eko("b) Ranking de agentes con más llamados sospechosos");
	eko("c) Ranking de oficinas con más llamados sospechosos");
	eko("d) Ranking de destinos de llamados sospechosos");
	eko("e) Ranking de umbrales");
	eko("------------------------------------------------------");

	$opcionValida = 0;
	while ($opcionValida == 0){
		$salidaElegida = <STDIN>;
		chomp($salidaElegida);	
		if($salidaElegida eq "a" || $salidaElegida eq "b" || $salidaElegida eq "c"
		|| $salidaElegida eq "d" || $salidaElegida eq "e" )
		{
			$opcionValida = 1;			
		} else{
			informarComandoErroneo();
		}
	}

	return $salidaElegida;
}

sub informarComandoErroneo{
	eko("Error! Seleccionar una opción válida.");
}

sub mostrarQueryVacia{
	eko("La query no devolvió registros válidos.");
}

sub obtenerCampo{
	my ($registro, $campo) = @_;
	@campos = split(";",$registro);
	return $campos[$campo];
}

# recibe por parametro un hash, lo ordena usando el comparador de hashes
# y muestra los registros.
sub mostrarResultadosHash {

	my (%resultados) = @_;

	@keys = sort { comparadorHashes($resultados{$a}, $resultados{$b}) } keys%resultados;
	@values = @resultados{@keys};

	my $arraySize = @values;

	if ($#keys < 0){
		mostrarQueryVacia;
	}

	if ($ESTADO_GRABACION == 1) {
		for my $i (0..$#keys){
			grabarConsultaEnArchivo("$values[$i]");
		}
		eko("Cantidad de resultados: $arraySize");
		eko("");
		eko("Se han grabado los resultados de la consulta en el archivo: subllamadas.$rand1");
		eko("");
	} else {
		eko("Cantidad de resultados: $arraySize");
		eko("");
		for my $i (0..$#keys){
			eko($values[$i]);
		}
		eko("");
	}

}

sub pedirCentrales {
	eko("Introducir ID(s) de la(s) central(es):");
	my $filtros_centrales = <STDIN>;
	chomp($filtros_centrales);	
	my @filtros_centrales_array = split( /\s+/, $filtros_centrales);
	#print join(", ", @filtros_centrales_array);
	return @filtros_centrales_array;	
}

sub pedirAgentes {
	eko("Introducir ID(s) de agente(s):");
	my $filtros_agentes = <STDIN>;
	chomp($filtros_agentes);	
	my @filtros_agentes_array = split( /\s+/, $filtros_agentes);	
	return @filtros_agentes_array;
}

sub pedirUmbrales {
	eko("Introducir ID(s) de umbral(es):");
	my $filtros_umbrales = <STDIN>;
	chomp($filtros_umbrales);	
	my @filtros_umbrales_array = split( /\s+/, $filtros_umbrales);	
	return @filtros_umbrales_array;
}

sub pedirTiposLlamada {
	eko("Introducir tipo(s) de llamada(s):");
	eko("[ DDI / DDN / LOC ]");
	my $opcionValida = 0;
	while ($opcionValida == 0){
		$filtros_tipos_llamada = <STDIN>;
		chomp($filtros_tipos_llamada);
		@filtros_tipos_llamada_array = split( /\s+/, $filtros_tipos_llamada);
		if ($filtros_tipos_llamada eq "") {
			last;
		}
		print join(", ", @filtros_tipos_llamada_array);
		for my $i (0..$#filtros_tipos_llamada_array){
			if ( ($filtros_tipos_llamada_array[$i] eq "DDI") || ($filtros_tipos_llamada_array[$i] eq "LOC") || ($filtros_tipos_llamada_array[$i] eq "DDN") ){
				$opcionValida = 1;
				last;
			}
		}
		if ($opcionValida == 0){
			eko("Debe pasar algun parametro valido");
		}
	}
	print join(", ", @filtros_tipos_llamada_array);
	return @filtros_tipos_llamada_array;
}

sub pedirIntervalo {
	eko("Introducir el intervalo de duración separado por un espacio:");
	my $opcionValida = 0;
	while ($opcionValida == 0){
		my $filtros_intervalo = <STDIN>;
		chomp($filtros_intervalo);
		@intervalo = split( /\s+/, $filtros_intervalo);
		if ($filtros_intervalo eq "") {
			last;
		}
		# si no tiene 2 parametros es invalido
		if ($#intervalo eq 1){
			# eko("cantidad erronea de parametros");
			if ( looks_like_number($intervalo[0]) && looks_like_number($intervalo[1]) ){
				# si los 2 son numeros vamos bien.
				# eko("Los 2 parecen numeros");
				# ahora vemos que sea un intervalo valido.
				if( ($intervalo[1] - $intervalo[0]) > 0){
					eko($intervalo[1] - $intervalo[0]);
					$opcionValida = 1;
				}
			}
		}
	}
	return @intervalo;	
}

sub pedirNumerosA {
	eko("Introducir número(s) A: ");
	my $filtros_numeros_a = <STDIN>;
	chomp($filtros_numeros_a);	
	my @filtros_numeros_a_array = split( /\s+/, $filtros_numeros_a);
	return @filtros_numeros_a_array; 	
}

sub pedirFiltros {

	my (@archivos) = @_;
	my %resultados;

	my $filtro_no_vacio = 0;
	while ($filtro_no_vacio == 0) {
		@filtros_centrales = &pedirCentrales;
		@filtros_agentes = &pedirAgentes;
		@filtros_umbrales = &pedirUmbrales;
		@filtros_tipos_llamada = &pedirTiposLlamada;
		@filtros_intervalo = &pedirIntervalo;
		@filtros_numeros_a = &pedirNumerosA;

		if ((@filtros_centrales == 0) && (@filtros_agentes == 0) && (@filtros_umbrales == 0) 
			&& (@filtros_tipos_llamada == 0) && (@filtros_intervalo == 0) && (@filtros_numeros_a == 0)) {
			eko("Debe indicar por lo menos un filtro.\n");
		} else {
			$filtro_no_vacio = 1;
		}
	}

	#ACA EMPIEZA LA DIVERSIÓN (?)

  	for my $a (0..$#archivos){
  		$rutaSospecha = "$INPUT_CONSULTAS_GLOBAL" . "/$archivos[$a]";
  		#eko("$rutaSospecha");
  		open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			#todas las lineas son inválidas hasta que se demuestre lo contrario.
			$esValido = 0;
			
			#FILTRO POR CENTRALES
			if (@filtros_centrales) {
				#eko("++++ FILTRANDO POR CENTRALES ++++");
				$esValido = 0;
				$idCentral = obtenerCampo("$linea", "$ID_CENTRAL");
				for my $i (0..$#filtros_centrales){
					if ($idCentral eq $filtros_centrales[$i]){
						$esValido = 1;
						last;
					} 
				}
				if ($esValido == 0) {
					#El registro no cumple con el filtro, paso al siguiente registro
					next;
				}
			}

			#FILTRO POR AGENTES
			if (@filtros_agentes > 0) {
				#eko("++++ FILTRANDO POR AGENTES ++++");
				$esValido = 0;
				$idAgente = obtenerCampo("$linea", "$ID_AGENTE");
				for my $i (0..$#filtros_agentes){
					if ($idAgente eq $filtros_agentes[$i]){
						$esValido = 1;
						last;
					} 
				}
				if ($esValido == 0) {
					#El registro no cumple con el filtro, paso al siguiente registro
					next;
				}
			}

			#FILTRO POR UMBRAL
			if (@filtros_umbrales > 0) {
				#eko("++++ FILTRANDO POR UMBRALES ++++");
				$esValido = 0;
				$idUmbral = obtenerCampo("$linea", "$ID_UMBRAL");
				for my $i (0..$#filtros_umbrales){
					if ($idUmbral eq $filtros_umbrales[$i]){
						$esValido = 1;
						last;
					} 
				}
				if ($esValido == 0) {
					#El registro no cumple con el filtro, paso al siguiente registro
					next;
				}
			}

			#FILTRO POR TIPO LLAMADA
			if (@filtros_tipos_llamada > 0) {
				#eko("++++ FILTRANDO POR TIPO DE LLAMADA ++++");
				$esValido = 0;
				$tipoLlamada = obtenerCampo("$linea", "$TIPO_LLAMDA");
				for my $i (0..$#filtros_tipos_llamada){
					if ($tipoLlamada eq $filtros_tipos_llamada[$i]){
						$esValido = 1;
						last;
					} 
				}
				if ($esValido == 0) {
					#El registro no cumple con el filtro, paso al siguiente registro
					next;
				}
			}

			#FILTRO POR DURACION LLAMADA
			if (@filtros_intervalo > 0) {
				#eko("++++ FILTRANDO POR DURACIÓN LLAMADA ++++");
				$esValido = 0;
				$tiempoLlamada = obtenerCampo("$linea", "$TIEMPO_CONV");
				if ($tiempoLlamada > $filtros_intervalo[0] && $tiempoLlamada < $filtros_intervalo[1]){
					$esValido = 1;
				}
				if ($esValido == 0) {
					#El registro no cumple con el filtro, paso al siguiente registro
					next;
				}
			}
			
			#FILTRO POR NUMERO A
			if (@filtros_numeros_a > 0) {
				#eko("++++ FILTRANDO POR NÚMERO A ++++");
				$esValido = 0;
				$codArea = obtenerCampo("$linea", "$AREA_NUM_A");
				$numeroOrigen = obtenerCampo("$linea", "$NUMERO_ORIGEN");
				$numeroA = $codArea.$numeroOrigen;
				for my $i (0..$#filtros_numeros_a){
					if ($numeroA eq $filtros_numeros_a[$i]){
						$esValido = 1;
						last;
					} 
				}
				if ($esValido == 0) {
					#El registro no cumple con el filtro, paso al siguiente registro
					next;
				}
			}


			#El registro cumplió con todos los filtros, lo almaceno
			if ($esValido == 1){
				$claveHash = obtenerClaveHash($linea);
				$resultados{$claveHash} = $linea;
			}
		}
		close(ENT);
  	}


  	mostrarResultadosHash(%resultados);
	# eko("Afuera");

  	
  	# Me devuelve la leng mas 1.
  	# eko("La long del array es $#array")
}

sub mostrarOpcionesDeFiltrosEstadisticas{
	# Si no se recibieron parametros es porque va a usar todos los archivos.
	$numParams = @_;
	# eko("se recibieron $numParams parametros");
	my (@archivosRecibidos) = @_;
	$opcion = mostrarOpcionesEstadisticas;

	if ($opcion eq "a"){
		mostrarCentralMasSospechosas(@archivosRecibidos);
	} elsif ($opcion eq "b"){
		mostrarAgentesMasSospechosos(@archivosRecibidos)	;
	} elsif ($opcion eq "c"){
		mostrarOficinaMasSospechosa(@archivosRecibidos);
	} elsif ($opcion eq "d"){
		mostrardDestinoMasSospechoso(@archivosRecibidos);
	} elsif ($opcion eq "e"){
		mostrarRankingDeUmbrales(@archivosRecibidos);
	}
}

# si esta activado, lo desactivo.
# y viceversa
sub manejarEstadoDeGrabacion{
	if ($ESTADO_GRABACION == 0){
		$ESTADO_GRABACION = 1;
	} else {
		$ESTADO_GRABACION = 0;
	}
}

sub mostrarEstadoDeGrabacion{
	if ($ESTADO_GRABACION == 0){		
		eko("GRABACION DESACTIVADA");
	} else {
		eko("GRABACION ACTIVADA");
	}	
}

sub mostrarMsgInstr{
	eko("Instrucción inválida.");
	eko("Usa -h para una lista de posibles instrucciones");
}

sub mostrarAyuda{
	eko("==========================================================");
	eko("=======================AFLIST=============================");
	eko("==========================================================");
	eko("=  -w para activar la opción de guardado                 =");
	eko("=  -r para realizar consultas sobre llamadas sospechosas =");
	eko("=  -s para visualizar estadísticas                       =");
	eko("=  -h para acceder a este menu                           =");
	eko("==========================================================");
	eko("==========================================================");
	eko("==========================================================");
}

sub mostrarMenuYPedirOpcion{
	mostrarEstadoDeGrabacion;
	eko("==========================================================");
	eko("=======================AFLIST=============================");
	eko("==========================================================");
	eko("=  w  para activar/desactivar la grabación de consultas ==");
	eko("=  r  para realizar consultas sobre llamadas sospechosas =");
	eko("=  s  para visualizar estadísticas                       =");
	eko("=                                                        =");
	eko("=  q  para terminar la ejecución                         =");
	eko("==========================================================");
	eko("==========================================================");
	eko("==========================================================");

	$opcionValida = 0;
	while ($opcionValida == 0){
		$salidaElegida = <STDIN>;
		chomp($salidaElegida);	
		if($salidaElegida eq "w" || $salidaElegida eq "r" ||
			$salidaElegida eq "s" || $salidaElegida eq "h" || $salidaElegida eq "q"){
			$opcionValida = 1;			
		} else{
			informarComandoErroneo();
			
		}
	}

	# el usuario por fin eligio una opcion valida.
	# felicitarlo.
	return $salidaElegida;
}

sub obtenerFiltrosOficinas {
	$filtros_no_ingresados = 1;
	while ($filtros_no_ingresados) {
		eko("Introducir oficina(s) separadas por espacio:");

		$oficinas = <STDIN>;
		chomp($oficinas);
		@filtros = split( /\s+/, $oficinas);
		$size = @filtros;
		if ($size < 1) {
			eko("Debe ingresar al menos un nombre de oficina.");
			eko("");
		} else {
			return @filtros;
		}
	}
}

#esto me va a devolver el nombre de los archivos que estoy buscando.
# $1 recibe el tipo de filtro
# $2 la lista de filtros.
sub obtenerArchivosAProcesar{

	eko("Obteniendo archivos a procesar");
	my @archivosParaConsultar;
	my ($tipoFiltro, @arrayFiltros) = @_;


  	# $rutaSospecha = "$PROCDIR/$archivos[$a]";
	my $dir = "$INPUT_CONSULTAS_GLOBAL/";
    opendir(DIR, $dir) or die $!;

    while (my $file = readdir(DIR)) {
        # Use a regular expression to ignore files beginning with a period
        next if ($file =~ m/^\./);

		@campos = split("_",$file);

        if ( $tipoFiltro eq "ANIOMES"){
        	
        	for my $i (0..$#arrayFiltros){
        		if ($arrayFiltros[$i] eq $campos[1]){

        			#eko("Pusheando $file al array con ANIOMES");
        			push @archivosParaConsultar, $file;

        			last;
        		} 
        	}
        } else{
        	for my $i (0..$#arrayFiltros){
        		if ($arrayFiltros[$i] eq $campos[0]){
        			#eko("Pusheando $file al array con OFCINAS");
        			push @archivosParaConsultar, $file;

        			last;
        		} 
        	}
        }
    }

    closedir(DIR);

    return @archivosParaConsultar;
}

sub filtrarArchivos {
	# Filtra array de archivos de acuerdo al tipo de filtro y  array de filtros
	# LOS ARRAYS SE DEBEN PASAR POR REFERENCIA SINO NO FUNCIONA!

	my ($archivos, $filtros, $tipoFiltro) = @_;

	my @resultado;

	if ($tipoFiltro eq "ANIOMES") {
		#eko("filtrando por aniomes!");
		foreach $archivo (@$archivos) {
			($oficina, $aniomes) = split("_", $archivo);

			foreach $filtro (@$filtros) {
				#eko("filtro: $filtro");
				#eko("oficina: $aniomes");
				if ($filtro eq $aniomes) {
					push @resultado, $archivo;
				}
			}
		}
	} elsif ($tipoFiltro eq "OFICINAS") {
		#eko("filtrando por oficinas!");
		foreach $archivo (@$archivos) {
			($oficina, $aniomes) = split("_", $archivo);

			foreach $filtro (@$filtros) {
				#eko("filtro: $filtro");
				#eko("oficina: $oficina");
				if ($filtro eq $oficina) {
					#eko("match: $filtro $oficina");
					push @resultado, $archivo;
				}
			}
		}

	} elsif ($tipoFiltro eq "SUBLLAMADAS") {
		foreach $archivo (@$archivos) {
			($prefix, $sufix) = split('\.', $archivo);
			foreach $filtro (@$filtros) {
				#eko("oficina: $oficina");
				if ($filtro eq $sufix) {
					push @resultado, $archivo;
				}
			}
		}
	} else {
		eko("Tipo de filtro invalido.");
			return; 
	}

	return @resultado;
}

sub obtenerArchivos {
	# Recibe path del directorio input, tipo de filtro
	# y una lista de patrones para filtrar los archivos del directorio.

	eko("Obteniendo archivos a procesar");
	my @archivosParaConsultar;
	my ($inputDir, $tipoFiltro, @arrayFiltros) = @_;
	#eko("arrayFiltros: @arrayFiltros");
	@archivos = obtenerTodosLosArchivos($inputDir);
	@archivosParaConsultar = filtrarArchivos(\@archivos, \@arrayFiltros, $tipoFiltro);

	return @archivosParaConsultar;
}

# me devuelve la opcion de la salida elegida.
sub mostrarFormasDeConsultarLlamadasSospechosas(){
	eko("==========================================================");
	eko("====Consultas de llamadas sospechosas ====================");
	eko("=                                                        =");
	eko("=   Seleccione la opción deseada:                        =");
	eko("=     1) Consultar sobre reg de llamadas sospechosas     =");
	eko("=     2) Introducir nombre de oficina para consultar     =");
	eko("=     3) Introducir aniomes                              =");
	eko("=                                                        =");
	eko("==========================================================");

	$opcionValida = 0;
	while ($opcionValida == 0){
		$salidaElegida = <STDIN>;
		chomp($salidaElegida);	
		if($salidaElegida eq "1" || $salidaElegida eq "2" ||
			$salidaElegida eq "3"){
			$opcionValida = 1;	
		}
		else{
			informarComandoErroneo();
			
		}
	}

	#eko("La salida es $salidaElegida");
	# el usuario por fin eligio una opcion valida.
	# felicitarlo.
	return $salidaElegida;
}

# me devuelve la opcion de la salida elegida.
sub mostrarFormasDeConsultarSubLlamadas {
	eko("===========================================================");
	eko("==== Consultas de subllamadas =============================");
	eko("=                                                         =");
	eko("=   Seleccione la opción deseada:                         =");
	eko("=     1) Todos los archivos de subllamadas.               =");
	eko("=     2) Seleccionar archivos de subllamadas.             =");
	eko("=                                                         =");
	eko("===========================================================");

	$opcionValida = 0;
	while ($opcionValida == 0){
		$salidaElegida = <STDIN>;
		chomp($salidaElegida);	
		if($salidaElegida eq "1" || $salidaElegida eq "2"){
			$opcionValida = 1;	
		}
		else{
			informarComandoErroneo();
		}
	}

	return $salidaElegida;
}

#Checkea si el directorio pasado por argumento está vacio.
sub esDirectorioVacio {
    opendir(DIR, shift) or die $!;
    my @files = grep { !m/\A\.{1,2}\Z/} readdir(DIR);
    closedir(DIR);
    @files ? 0 : 1;
}

# Retorna el path del directorio input para las consultas.
# - Si existen archivos de subllamadas, se solicita al usuario elegir el input deseado
# 	y se retorna el path al directorio correspondiente. 
# - Si no existen, devuelve el directorio de llamadas sospechosas (default).
sub obtenerInputConsultas {
	my $dirSubLlamadasVacio = esDirectorioVacio($RUTA_REPODIR);

	if($dirSubLlamadasVacio) {
		eko("No existen archivos de subllamadas. Default input.");
		return ($PROCDIR, 1);
	} else {
		while(1) {
			eko("Seleccione input de consultas:");
			eko("1) Realizar consultas en archivos de llamadas sospechosas.");
			eko("2) Realizar consultas en archivos de subllamadas.");

			$inputSeleccionado = <STDIN>;
			chomp($inputSeleccionado);

			if    ($inputSeleccionado == 1) { return ($PROCDIR, 1); }
			elsif ($inputSeleccionado == 2) { return ($RUTA_REPODIR, 2); }
			else { eko("Ingrese una opción valida por favor."); }
		}
	}
}

sub obtenerFiltrosAnioMes {
	$filtros_no_ingresados = 1;
	while ($filtros_no_ingresados) {

		eko("Introducir aniomes(es) separadas por espacio:");

		$aniomes = <STDIN>;
		chomp($aniomes);
		@filtros =split( /\s+/, $aniomes);
		$size = @filtros;
		if ($size < 1) {
			eko("Debe ingresar al menos una fecha aniomes.");
			eko("");
		} else {
			return @filtros;
		}
	}
}


sub pedirAnioMes{
	
	@filtrosAnioMes = obtenerFiltrosAnioMes;
	@archivos = obtenerArchivos($INPUT_CONSULTAS_GLOBAL, "ANIOMES", @filtrosAnioMes);
	eko("Archivos: @archivos");
	eko("");
	eko("1) Filtrar por oficinas.");
	eko("2) Realizar consulta.");

	$opcionSeleccionada = <STDIN>;
	chomp($opcionSeleccionada);
	if ($opcionSeleccionada == 1) {
		@filtrosOficinas = obtenerFiltrosOficinas;
		@archivos = filtrarArchivos(\@archivos, \@filtrosOficinas, "OFICINAS");
		eko("Archivos: @archivos");

		pedirFiltros(@archivos);
	} elsif ($opcionSeleccionada == 2) {
		pedirFiltros(@archivos);
	} else {
		eko("Ingrese una opción valida por favor."); eko("");
	}
}

sub pedirSubLlamadas {
	my @archivos = @_;

	eko("Archivos: @archivos");

	eko("introducir sufijo(s) de subllamadas separados por espacio:");

	$inputFiltroSubllamadas = <STDIN>;
	chomp($inputFiltroSubllamadas);	

	my @filtrosSubLlamadas = split( /\s+/, $inputFiltroSubllamadas);


	@archivos = filtrarArchivos(\@archivos, \@filtrosSubLlamadas, "SUBLLAMADAS");

	eko("Archivos: @archivos");
	#PASAR REPODIR
	pedirFiltros(@archivos);
}

sub pedirAnioMesEstadisticas{
	eko("introducir aniomes(es) separadas por espacio:");

	$aniomes = <STDIN>;
	chomp($aniomes);	

	my @aniomeses = split( /\s+/, $aniomes);

	
	@archivosAProcesar = obtenerArchivosAProcesar("ANIOMES", @aniomeses);

	mostrarOpcionesDeFiltrosEstadisticas(@archivosAProcesar);
}

sub obtenerTodosLosArchivosDeSospechas{
	my $dir = "$INPUT_CONSULTAS_GLOBAL";
	my @archivosAProcesar;

	my ($opc) = @_;
    opendir(DIR, $dir) or die $!;

    while (my $file = readdir(DIR)) {

        # Use a regular expression to ignore files beginning with a period
        next if ($file =~ m/^\./);

        push @archivosAProcesar, $file;
    }

    if ($opc == 1){
		pedirFiltros(@archivosAProcesar);
    }else{
		mostrarOpcionesDeFiltrosEstadisticas(@archivosAProcesar);
    }
}

sub obtenerTodosLosArchivos {
	my ($inputDir) = @_;
	my @archivosAProcesar;

	opendir(dfh, $inputDir) or die $!;
	while (my $file = readdir(dfh)) {

        # Use a regular expression to ignore files beginning with a period
        next if ($file =~ m/^\./);
        # Si es un directorio no se agrega como archivo a procesar.
        $fullPath = $inputDir."/".$file;
        next if (-d $fullPath);

        push @archivosAProcesar, $file;
    }

    return @archivosAProcesar;
}


sub pedirOficinas {
	@filtrosOficinas = obtenerFiltrosOficinas;
	@archivos = obtenerArchivos($INPUT_CONSULTAS_GLOBAL, "OFICINAS", @filtrosOficinas);
	eko("Archivos: @archivos");
	eko("");
	eko("1) Filtrar por aniomes.");
	eko("2) Realizar consulta.");
	$opcionSeleccionada = <STDIN>;
	chomp($opcionSeleccionada);

	if ($opcionSeleccionada == 1) {
		@filtrosAnioMes = obtenerFiltrosAnioMes;
		@archivos = filtrarArchivos(\@archivos, \@filtrosAnioMes, "ANIOMES");
		eko("Archivos: @archivos");
		pedirFiltros(@archivos);
	} elsif ($opcionSeleccionada == 2) {

		pedirFiltros(@archivos);
	} else {
		eko("Ingrese una opción valida por favor."); eko("");
	}
}


sub pedirOficinasEstadisticas{
	eko("introducir oficina(s) separadas por espacio:");

	$oficinas = <STDIN>;
	chomp($oficinas);	

	my @aOficinas = split( /\s+/, $oficinas);


	@archivosAProcesar = obtenerArchivosAProcesar("OFICINAS", @aOficinas);


	mostrarOpcionesDeFiltrosEstadisticas(@archivosAProcesar);
}


sub mostrarMenuEstadisticas{
	my ($inputConsultas, $tipoInput) = obtenerInputConsultas();
	$INPUT_CONSULTAS_GLOBAL = $inputConsultas;
	#$opcionElegida = mostrarFormasDeConsultarLlamadasSospechosas;

	#if ($opcionElegida eq "1"){
		obtenerTodosLosArchivosDeSospechas(0);
	#} elsif ($opcionElegida eq "2"){
	#	pedirOficinasEstadisticas;
	#} elsif ($opcionElegida eq "3"){
	#	pedirAnioMesEstadisticas;
	#}
}

sub menuConsultasLlamadasSospechosas {
	my $pathInput = @_[0];
	
	$opcionElegida = mostrarFormasDeConsultarLlamadasSospechosas;

	if ($opcionElegida eq "1") {
		@archivos = obtenerTodosLosArchivos($pathInput);
		eko("Archivos: @archivos");

		pedirFiltros(@archivos);

	} elsif ($opcionElegida eq "2") {
		pedirOficinas;
	} elsif ($opcionElegida eq "3") {
		pedirAnioMes;
	}
}

sub menuConsultasSubLlamadas {
	my $pathInput = @_[0];

	@archivos = obtenerTodosLosArchivos($pathInput);

	my $opcionElegida = mostrarFormasDeConsultarSubLlamadas;

	if ($opcionElegida eq "1") {
		eko("Archivos: @archivos");

		pedirFiltros(@archivos);

	} elsif ($opcionElegida eq "2") {
		
		pedirSubLlamadas(@archivos);
	} else {

	}
}

sub mostrarMenuConsultas{
	
	my ($inputConsultas, $tipoInput) = obtenerInputConsultas();
	$INPUT_CONSULTAS_GLOBAL = $inputConsultas;

	eko("Input de consultas: $inputConsultas");
	
	if ($tipoInput eq 1) {
		menuConsultasLlamadasSospechosas($inputConsultas);
	} elsif ($tipoInput eq 2) {
		menuConsultasSubLlamadas($inputConsultas);
	}
}

sub menuMain{
	$deberiaEjecutarme = 1;
	while ($deberiaEjecutarme == 1){
		# system 'clear';
		$opcion = mostrarMenuYPedirOpcion;

		if ($opcion eq "h"){
			mostrarAyuda;
		}elsif ($opcion eq "w"){
			manejarEstadoDeGrabacion;
		}elsif ($opcion eq "r"){
			mostrarMenuConsultas;
		}elsif ($opcion eq "s"){
			mostrarMenuEstadisticas;
		} elsif ($opcion eq "q"){
			#eko("Ejecucion terminada");
			$deberiaEjecutarme = 0;
		} else{
			mostrarMsgInstr();
		}
	}	
}

sub chequearCantidadArgumentos{
	$numArgs = @ARGV;


	#Si no recibo exactamente un parametro le muestro el mensaje de -h
	if ( $numArgs != 1) {
		mostrarMsgInstr();
	} else {
		# vamos a ver si es un argumento valido.
		$primerArgumento = "$ARGV[0]";
		if ($primerArgumento eq "-h"){
			mostrarAyuda;
		}elsif ($primerArgumento eq "-w"){
			manejarEstadoDeGrabacion;
			menuMain;
		}elsif ($primerArgumento eq "-r"){
			mostrarMenuConsultas;
			menuMain;
		}elsif ($primerArgumento eq "-s"){
			mostrarMenuEstadisticas;
			menuMain;
		} else{
			mostrarMsgInstr();
		}
	}
}


my $AFRAENV = $ENV{'AFRAENV'};

if (! $AFRAENV eq ''){
	# inicializado

	#eko(`pgrep AFUMB`);

#	if(`ps -aef | grep -v grep $process_name`) {
#    print "Process is running!\n";

    chequearCantidadArgumentos;
} else{
	# no inicIALIzado
	eko("El ambiente no esta inicializado, ejecutar AFINI");
}
