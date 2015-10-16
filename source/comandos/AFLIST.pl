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

#Setear la ruta a los archivos de sospechas.
my $PATH_MAEDIR = $ENV{'MAEDIR'};

my $RUTA_REPODIR = $ENV{'REPODIR'};
my $RUTA_CENTRALES = "$PATH_MAEDIR" . "/CdC.mae";
my $RUTA_AGENTES = "$PATH_MAEDIR" . "/agentes.mae";
my $RUTA_CIUDADES = "$PATH_MAEDIR" . "/CdA.mae";
my $RUTA_PAISES = "$PATH_MAEDIR" . "/CdP.mae";
my $RUTA_UMBRALES = "$PATH_MAEDIR" . "/umbral.tab";

# Por defecto el directorio input de las consultas
# será el directorio de llamadas sospechosas, output de AFUMB.
$INPUT_DIR = $PROCDIR;

my $extensionArchivo = "000";
my $archivoAGuardar = "$RUTA_REPODIR/$extensionArchivo";

my $rand1 = int(rand(1000));
my $randEstadisticas = int(rand(1000000));

my $rutaConsulta = "$RUTA_REPODIR/subllamadas.$rand1";
my $rutaEstadistica = "$RUTA_REPODIR/subllamadas.$randEstadisticas";




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
sub grabarEstadisticaEnArchivo{
	my ($entry) = @_;
	open(my $fh, '>', $rutaEstadistica);
	print $fh "$entry\n";
	close $fh;
}

sub grabarConsultaEnArchivo{
	my ($entry) = @_;
	open(my $fh, '>', $rutaConsulta);
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


# 1- Analizar todos los registros de llamadas sospechosas e ir acumulando
# en el contador de cada central.
# 2- Hacer un sort de las claves DESC.
# 3- Hacer un match con el archivo de las centrales para mostrar el codigo y
# su descripcion.

# ya sabemos de ante mano que existe la central en el archivo de centrales
sub mostrarCentralMasSospechosas{

	my (@archivos) = @_;

	eko2("---------------------------------------");
	eko2("------------CENTRALES SOSPECHOSAS---------------------");
	eko2("---------------------------------------");
	my %hashCentrales;

	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR" . "/$archivos[$a]";

  		# eko("RUTA SOSPECHOSA $rutaSospecha" );

		open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$idCentral = obtenerCampo2("$linea", "$ID_CENTRAL");

			# Incremento el contador.
			$hashCentrales{$idCentral}++;
		}
	}

	close(ENT);


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada central
	my @keys = sort { $hashCentrales{$b} <=> $hashCentrales{$a} } keys%hashCentrales;
	my @values = @hashCentrales{@keys};

	# ya tengo todo ordenado, me faltaria obtener el codigo y la descripcion.
	for my $i (0..$#keys){
		$entry ="$keys[$i] #$values[$i] apariciones -> ".`grep "$keys[$i]" -R $RUTA_CENTRALES | cut -d';' -f2`;

		if ($ESTADO_GRABACION == 0){
			eko($entry);	
		} else {
			grabarEstadisticaEnArchivo("$entry");
		}
	 	
		# print ("$keys[$i] #$values[$i] apariciones -> ");
		# print `grep "$keys[$i]" -R $RUTA_CENTRALES | cut -d';' -f2`;
		imprimirSeparador;
	}
}


# no mostrarlo si tiene solo 1 llamada.
# TODO: falta ver que carajo hacer con los umbrales
sub mostrarRankingDeUmbrales{
	eko2("---------------------------------------");
	eko2("------------RANKING DE UMBRALES---------------------");
	eko2("---------------------------------------");

	my (@archivos) = @_;

	my %hashUmbrales;

	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR" . "/$archivos[$a]";

  	 	# eko("RUTA SOSPECHOSA $rutaSospecha" );
		open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$idUmbral = obtenerCampo2("$linea", "$ID_UMBRAL");

			# Incremento el contador.
			$hashUmbrales{$idUmbral}++;
		}
		close(ENT);
	}


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada central
	my @keys = sort { $hashUmbrales{$b} <=> $hashUmbrales{$a} } keys%hashUmbrales;
	my @values = @hashUmbrales{@keys};

	for my $i (0..$#keys){
		# el enunciado pedia ignorar umbrales 
		if ($values[$i] > 1){
			$entry= "ID UMBRAL: $keys[$i] ->  #$values[$i] apariciones";

			# ESCRIBIR EN ARCHIVO.
			if ($ESTADO_GRABACION == 0){
				eko($entry);	
			} else {
				grabarEstadisticaEnArchivo("$entry");
			}
			# print `grep "$keys[$i]" -R $RUTA_UMBRALES | cut -d';' -f2`;	
		}
	}

	imprimirSeparador;
}

sub mostrarAgentesMasSospechosos{

	eko2("---------------------------------------");
	eko2("-----------Agentes mas sospechosos--------------------------");
	eko2("---------------------------------------");

	my (@archivos) = @_;

	my %hashAgentes;

	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR" . "/archivos[$a]";

  		# eko("RUTA SOSPECHOSA $rutaSospecha" );

		open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$idAgente = obtenerCampo2("$linea", "$ID_AGENTE");

			# Incremento el contador.
			$hashAgentes{$idAgente}++;
		}
	}

	close(ENT);


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada central
	my @keys = sort { $hashAgentes{$b} <=> $hashAgentes{$a} } keys%hashAgentes;
	my @values = @hashAgentes{@keys};

	# ya tengo todo ordenado, me faltaria obtener el codigo y la descripcion.
	for my $i (0..$#keys){

		
		# print ("$keys[$i]  -> #$values[$i] apariciones -> ");
		# print `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f5`;
		$mail = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f5`;
		$oficina = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f4`;
		# print("Mail: $mail");
		# print("oficina: $oficina");

		$entry="$keys[$i]  -> #$values[$i] apariciones -> "."Mail: $mail"."oficina: $oficina";
		if ($ESTADO_GRABACION == 0){
			eko($entry);	
		} else {
			grabarEstadisticaEnArchivo("$entry");
		}
		imprimirSeparador;
	}
}

sub mostrarOficinaMasSospechosa{

eko2("---------------------------------------");
eko2("-------------Oficinas mas sospechosas--------------------");
eko2("---------------------------------------");

my (@archivos) = @_;

my %hashAgentes;

for my $a (0..$#archivos){
	$rutaSospecha = "$PROCDIR/$archivos[$a]";

	# eko("RUTA SOSPECHOSA $rutaSospecha" );

	open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
	while($linea = <ENT>){
		chomp($linea);
		$idAgente = obtenerCampo2("$linea", "$ID_AGENTE");

		# Incremento el contador.
		$hashAgentes{$idAgente}++;
	}

	close(ENT);
}


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada central
	# no haria falta ordenar aca pero ya fue.
	my @keys = sort { $hashAgentes{$b} <=> $hashAgentes{$a} } keys%hashAgentes;
	my @values = @hashAgentes{@keys};

	# tengo que extraer la oficina de cada agente e ir acumulando...
	my %hashOficinas;
	
	for my $i (0..$#keys){
		$oficina = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f4`;
		$hashOficinas{$oficina}++;
	}

	@keys = sort { $hashOficinas{$b} <=> $hashOficinas{$a} } keys%hashOficinas;
	@values = @hashOficinas{@keys};


	# ya tengo todo ordenado, me faltaria obtener el codigo y la descripcion.
	for my $i (0..$#keys){
		$entry = "Oficina $keys[$i] -> $values[$i] apariciones";
		# eko2("Oficina $keys[$i] -> $values[$i] apariciones");
		if ($ESTADO_GRABACION == 0){
			eko($entry);	
		} else {
			grabarEstadisticaEnArchivo("$entry");
		}

		imprimirSeparador;
	}
}

sub mostrardDestinoMasSospechoso{

eko2("---------------------------------------");
eko2("-------------Destinos mas sospechosos--------------------");
eko2("---------------------------------------");

# En esta variable voy a ir acumulando los contadores de los destinos.
my (@archivos) = @_;

my %hashDestinos;
my %hashCodigoPais;
my %hashCodigoArea;

		for my $a (0..$#archivos){
  			$rutaSospecha = "$PROCDIR/" . "$archivos[$a]";

  			# eko("RUTA SOSPECHOSA $rutaSospecha" );
			open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
			while($linea = <ENT>){
				# eko("$a en el for");
				chomp($linea);
				$destinoSospechoso = obtenerCampo2("$linea", "$NUMERO_DESTINO");
				$codigoArea = obtenerCampo2("$linea", "$COD_AREA_B");
				$codigoPais = obtenerCampo2("$linea", "$CODIGO_PAIS_B");

				# eko2($codigoPais);
				# eko2($codigoArea);

				# si el codigo del pais del no esta vacio, tengo que sacar el nombre del archivo
				# maestro de los paises.
				if ($codigoPais eq ''){
					$hashCodigoPais{$destinoSospechoso} = 0;
				} else {
					$hashCodigoPais{$destinoSospechoso} = $codigoPais;
				}

				# si el codigo de area es distinto de 0, tneo que buscar el nombre en el archivo
				# maestro de los codigos de los paises.
				if ($codigoArea eq ''){
					$hashCodigoArea{$destinoSospechoso} = 0;
				} else {
					$hashCodigoArea{$destinoSospechoso} = $codigoArea;
				}


				# Incremento el contador	.
				$hashDestinos{$destinoSospechoso}++;
			}
			close(ENT);
	}
	
	# eko("despjes del for");


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada destino
	my @keys = sort { $hashDestinos{$b} <=> $hashDestinos{$a} } keys%hashDestinos;
	my @values = @hashDestinos{@keys};

	for my $i (0..$#keys){
		print ("$keys[$i] #$values[$i] apariciones ");

		# Aca tengo que fijarme si la ciudad es local o no es local.
		# para esto me fijo en cualquiera de los dos hashes auxiliares 
		# y comparo contra 0. Si el primero es 0, entonces la llamada 
		# no es local/internacional

		if ($hashCodigoPais{$keys[$i]} != 0){
			$entry = " Codigo: $hashCodigoPais{$keys[$i]}  "." Nombre: ".
			`grep "$hashCodigoPais{$keys[$i]}" -m 1 -R $RUTA_CIUDADES | cut -d';' -f1`;
			# eko2(" Codigo: $hashCodigoPais{$keys[$i]}  ");
			# print(" Nombre: ");
			# print `grep "$hashCodigoPais{$keys[$i]}" -m 1 -R $RUTA_CIUDADES | cut -d';' -f1`;;
		} else {
			$entry = " Codigo: $hashCodigoArea{$keys[$i]}  "." Nombre: "." Nombre: ".`grep "$hashCodigoArea{$keys[$i]}" -m 1 -R $RUTA_CIUDADES | cut -d';' -f1`;
			# print(" Codigo: $hashCodigoArea{$keys[$i]}  ");
			# print(" Nombre: ");
			# print `grep "$hashCodigoArea{$keys[$i]}" -m 1 -R $RUTA_CIUDADES | cut -d';' -f1`;;

			if ($ESTADO_GRABACION == 0){
				eko($entry);	
			} else {
				grabarEstadisticaEnArchivo("$entry");
			}

		}
		# print `grep "$keys[$i]" -R $RUTA_CENTRALES | cut -d';' -f2 \n`;
	}

	imprimirSeparador;
}


# eko2 ("inicio ejecucion");

# mostrarCentralMasSospechosas;

# mostrarAgentesMasSospechosos;

# mostrarOficinaMasSospechosa;

# mostrardDestinoMasSospechoso;

# mostrarRankingDeUmbrales;











































# Filtros a ser aplicados.
my @filtrosCentral;


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

sub mostrarOpciones{
	eko("Opciones posibles:");
	eko("A) Setear filtro(s) de Centrales");
	eko("B) Setear filtro(s) para Agentes");
	eko("C) Setear filtro(s) por umbral");
	eko("D) Setear filtro(s) para Tipos de llamadas");
	eko("E) Setear filtro(s) para Tiempos de conversaciones");
	eko("F) Setear filtro(s) para el Numero A");
	eko("------------------------------------------------------");
	eko("G) Mostrar resultados");
	eko("------------------------------------------------------");
	eko("Aclaracion: al elegir una opcion se borran los filtros anteriores");
	eko("------------------------------------------------------");

	$opcionValida = 0;
	while ($opcionValida == 0){
		$salidaElegida = <STDIN>;
		chomp($salidaElegida);	
		if($salidaElegida eq "a" || $salidaElegida eq "b" || $salidaElegida eq "c"
		|| $salidaElegida eq "d" || $salidaElegida eq "e" || $salidaElegida eq "f"
		|| $salidaElegida eq "g")
		{
			$opcionValida = 1;			
		}
		else{
			informarComandoErroneo();
		
		}
	}

	return $salidaElegida;
}

sub mostrarOpcionesEstadisticas{
	eko("Opciones posibles:");
	eko("A) Ranking de Centrales");
	eko("B) Ranking de Agentes con mas llamados sospechosos");
	eko("C) Ranking de oficinas con mas llamados sospechosos");
	eko("D) Ranking de destinos de llamados sospechosos");
	eko("E) Ranking de umbrales");
	eko("------------------------------------------------------");

	$opcionValida = 0;
	while ($opcionValida == 0){
		$salidaElegida = <STDIN>;
		chomp($salidaElegida);	
		if($salidaElegida eq "a" || $salidaElegida eq "b" || $salidaElegida eq "c"
		|| $salidaElegida eq "d" || $salidaElegida eq "e" )
		{
			$opcionValida = 1;			
		}
		else{
			informarComandoErroneo();
		
		}
	}

	return $salidaElegida;
}

sub informarComandoErroneo{
	eko("Error! Seleccionar una opcion valida.");
}

sub mostrarQueryVacia{
	eko("La query no devolvio registros validos");
}

sub obtenerCampo{
	my ($registro, $campo) = @_;
	@campos = split(";",$registro);
	return $campos[$campo];
}


# Recibe un registro (en formato csv seguramente) y lo muestro de forma humana.
sub mostrarResultado{
	my ($registro) = @_;

}

# param 1: el tipo de filtro a aplicar (ej central, agente, etc)
# param 2: el array.
sub setearFiltros{

}

# recibe por parametro un hash, lo ordena usando el comparador de hashes
# y muestra los registros.
sub mostrarResultadosHash{

	#eko("mostrar clave hash");
	my (%resultados) = @_;

	@keys = sort { comparadorHashes($resultados{$a}, $resultados{$b}) } keys%resultados;
	@values = @resultados{@keys};

	#eko("Long del array $#keys");
	#eko("Long del values $#values");

	if ($#keys < 0){
		mostrarQueryVacia;
	}

	for my $i (0..$#keys){
		if ($ESTADO_GRABACION == 1){
			grabarConsultaEnArchivo("$values[$i]");
		} else {
			eko($values[$i]);
		}
		
	}
}

sub mostrarResultados{
	my (@resultados) = @_;

	if ($#resultados < 0){
		mostrarQueryVacia;
		return 0;
	}
	for my $i (0..$#resultados){
		eko("$resultados[$i]");
	}
}

sub pedirFiltroCentral{
	eko("Introducir ID(s) de la central:");

	$filtros = <STDIN>;
	chomp($filtros);	

	my @filtrosArray = split( /\s+/, $filtros);
	my @resultados;
  	# eko($array[1]);

  	open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
	while($linea = <ENT>){
		chomp($linea);

		#todas las lineas son invalidas hasta que se demuestre lo contrario.
		$esValido = 0;

		$idCentral = obtenerCampo("$linea", "$ID_CENTRAL");

		# viendo si el registro cae dentro de la query.
		for my $i (0..$#filtrosArray){
			if ($idCentral eq $filtrosArray[$i]){
				$esValido = 1;

				#este seria el break de Perl.
				last;
			}
		}

		if ($esValido == 1){
			push @resultados, $linea;
		}
	}
	close(ENT);

	mostrarResultados(@resultados);
	#eko("Afuera");

  	# Me devuelve la leng mas 1.
  	# eko("La long del array es $#array")
}


sub pedirFiltroCentralHash{
	eko("Introducir ID(s) de la central:");

	my (@archivos) = @_;
	$filtros = <STDIN>;
	chomp($filtros);	

	my @filtrosArray = split( /\s+/, $filtros);
	my %resultados;
  	# eko($array[1]);

  	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR" . "/$archivos[$a]";

  		#eko("RUTA SOSPECHOSA $rutaSospecha" );


  		open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);

			#todas las lineas son invalidas hasta que se demuestre lo contrario.
			$esValido = 0;

			$idCentral = obtenerCampo("$linea", "$ID_CENTRAL");

			# viendo si el registro cae dentro de la query.
			for my $i (0..$#filtrosArray){
				if ($idCentral eq $filtrosArray[$i]){
					$esValido = 1;

					#este seria el break de Perl.
					last;
				}
			}

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

sub pedirFiltroAgentes{

	my (@archivos) = @_;


	eko("Introducir ID(s) de agente(s):");

	$filtros = <STDIN>;
	chomp($filtros);	

	my @filtrosArray = split( /\s+/, $filtros);
	my %resultados;
  	# eko($array[1]);

  	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR/" . "$archivos[$a]";

  		eko("RUTA SOSPECHOSA $rutaSospecha" );



	  	open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);

			#todas las lineas son invalidas hasta que se demuestre lo contrario.
			$esValido = 0;

			$idAgente = obtenerCampo("$linea", "$ID_AGENTE");

			# viendo si el registro cae dentro de la query.
			for my $i (0..$#filtrosArray){
				if ($idAgente eq $filtrosArray[$i]){
					$esValido = 1;

					#este seria el break de Perl.
					last;
				}
			}

			if ($esValido == 1){
				$claveHash = obtenerClaveHash($linea);
				$resultados{$claveHash}=$linea;
			}
		}
		close(ENT);
	}

	mostrarResultadosHash(%resultados);

  	# Me devuelve la leng mas 1.
  	# eko("La long del array es $#array")
}


sub pedirFiltroUmbral{
	eko("Introducir ID(s) de umbral(s):");

	my @archivos = @_;

	$filtros = <STDIN>;
	chomp($filtros);	

	my @filtrosArray = split( /\s+/, $filtros);
	my %resultados;
  	# eko($array[1]);

  	# eko(@filtrosArray);

  	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR/" . "$archivos[$a]";

  		# eko("RUTA SOSPECHOSA $rutaSospecha" );

	  	open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);

			#todas las lineas son invalidas hasta que se demuestre lo contrario.
			$esValido = 0;

			$idUmbral = obtenerCampo("$linea", "$ID_UMBRAL");

			# viendo si el registro cae dentro de la query.
			for my $i (0..$#filtrosArray){
				if ($idUmbral eq $filtrosArray[$i]){
					$esValido = 1;

					#este seria el break de Perl.
					last;
				}
			}

			if ($esValido == 1){
				$claveHash = obtenerClaveHash($linea);
				$resultados{$claveHash}=$linea;
			}
		}
		close(ENT);
	}

	mostrarResultadosHash(%resultados);

  	# Me devuelve la leng mas 1.
  	# eko("La long del array es $#array")
}

sub pedirFiltroTipoLlamada{
	eko("Introducir tipo(s) de llamada(s):");
	eko("[ DDI / DDN / LOC ]");

	my (@archivos) = @_;

	$opcionValida = 0;
	while ($opcionValida == 0){
		$filtros = <STDIN>;
		chomp($filtros);	

		@aFiltros = split( /\s+/, $filtros);

		for my $i (0..$#aFiltros){
			if ( ($aFiltros[$i] eq "DDI") || ($aFiltros[$i] eq "LOC") || 
			($aFiltros[$i] eq "DDN") ){
				$opcionValida = 1;

				last;
			}
		}

		if ($opcionValida == 1){
			#esta todo bien
		} else{
			eko("Debe pasar algun parametro valido");
		}
	}

	my @filtrosArray = split( /\s+/, $filtros);
	my %resultados;
  	# eko($array[1]);

  	# eko(@filtrosArray);

  	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR/" . "$archivos[$a]";

  		# eko("RUTA SOSPECHOSA $rutaSospecha" );

	  	open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);

			#todas las lineas son invalidas hasta que se demuestre lo contrario.
			$esValido = 0;

			$tipoLlamada = obtenerCampo("$linea", "$TIPO_LLAMDA");

			# viendo si el registro cae dentro de la query.
			for my $i (0..$#filtrosArray){
				if ($tipoLlamada eq $filtrosArray[$i]){
					$esValido = 1;

					#este seria el break de Perl.
					last;
				}
			}

			if ($esValido == 1){
				$claveHash = obtenerClaveHash($linea);
				$resultados{$claveHash}=$linea;
			}
		}
		close(ENT);
	}

	mostrarResultadosHash(%resultados);

  	# Me devuelve la leng mas 1.
  	# eko("La long del array es $#array")
}

sub mostrarMensajeRangoInvalido{
	eko("Rango invalido! Intentar nuevamente");
}

# vamos a tener que validar 
sub pedirFiltroPorTiempoDeDuracion{

	my (@archivos) = @_;

	#primero hay que ver que sea valido el intervalo, o no?
	my %resultados;

	eko("Introducir el intervalo separado por espacio:");

	$opcionValida = 0;
	while ($opcionValida == 0){
		$filtros = <STDIN>;
		chomp($filtros);	

		@intervalo = split( /\s+/, $filtros);

		# eko("@intervalo");
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

	# el input es valido, hacer la query.

	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR/$archivos[$a]";

  		# eko("RUTA SOSPECHOSA $rutaSospecha" );



		open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);

			#todas las lineas son invalidas hasta que se demuestre lo contrario.
			$esValido = 0;

			$tiempoLlamada = obtenerCampo("$linea", "$TIEMPO_CONV");

			# viendo si el registro cae dentro de la query.
			if ($tiempoLlamada > $intervalo[0] && $tiempoLlamada < $intervalo[1]){

				$claveHash = obtenerClaveHash($linea);
				$resultados{$claveHash}=$linea;
				#este seria el break de Perl.
			}
		}
		close(ENT);
	}

	mostrarResultadosHash(%resultados);
}


sub pedirFiltroNumeroA{
	eko("Introducir numero(s) A: ");

	my (@archivos) = @_;

	$filtros = <STDIN>;
	chomp($filtros);	

	my @filtrosArray = split( /\s+/, $filtros);
	my %resultados;
  	# eko($array[1]);

  	for my $a (0..$#archivos){
  		$rutaSospecha = "$PROCDIR/$archivos[$a]";

  		# eko("RUTA SOSPECHOSA $rutaSospecha" );


	  	open(ENT,"<$rutaSospecha")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);

			#todas las lineas son invalidas hasta que se demuestre lo contrario.
			$esValido = 0;

			$codArea = obtenerCampo("$linea", "$AREA_NUM_A");
			$numeroOrigen = obtenerCampo("$linea", "$NUMERO_ORIGEN");
			$numeroA = $codArea.$numeroOrigen;

			# viendo si el registro cae dentro de la query.
			for my $i (0..$#filtrosArray){
				if ($numeroA == $filtrosArray[$i]){
					$esValido = 1;

					#este seria el break de Perl.
					last;
				}
			}

			if ($esValido == 1){
				$claveHash = obtenerClaveHash($linea);
				$resultados{$claveHash}=$linea;
			}
		}
		close(ENT);
	}

	mostrarResultadosHash(%resultados);
}

sub mostrarOpcionesDeFiltros{

	# Si no se recibieron parametros es porque va a usar todos los archivos.
	$numParams = @_;

	# eko("se recibieron $numParams parametros");

	my (@archivosRecibidos) = @_;

	$opcion = mostrarOpciones;

	if ($opcion eq "a"){
		# eko("opc a");
		pedirFiltroCentralHash(@archivosRecibidos);
	} elsif ($opcion eq "b"){
		# eko("opc b");
		pedirFiltroAgentes(@archivosRecibidos)	;
	} elsif ($opcion eq "c"){
		# eko("opc c");
		pedirFiltroUmbral(@archivosRecibidos);
	} elsif ($opcion eq "d"){
		# eko("opc d");
		pedirFiltroTipoLlamada(@archivosRecibidos);
	} elsif ($opcion eq "e"){
		# eko("opc e");
		pedirFiltroPorTiempoDeDuracion(@archivosRecibidos);
	} elsif ($opcion eq "f"){
		# eko("opc f");
		pedirFiltroNumeroA(@archivosRecibidos);
	} elsif ($opcion eq "g"){
		# eko("opc g");
	}
}

sub mostrarOpcionesDeFiltrosEstadisticas{

	# Si no se recibieron parametros es porque va a usar todos los archivos.
	$numParams = @_;

	# eko("se recibieron $numParams parametros");

	my (@archivosRecibidos) = @_;

	$opcion = mostrarOpcionesEstadisticas;


# mostrarCentralMasSospechosas;

# mostrarAgentesMasSospechosos;

# mostrarOficinaMasSospechosa;

# mostrardDestinoMasSospechoso;

# mostrarRankingDeUmbrales;

	if ($opcion eq "a"){
		# eko("opc a");
		mostrarCentralMasSospechosas(@archivosRecibidos);
	} elsif ($opcion eq "b"){
		# eko("opc b");
		mostrarAgentesMasSospechosos(@archivosRecibidos)	;
	} elsif ($opcion eq "c"){
		# eko("opc c");
		mostrarOficinaMasSospechosa(@archivosRecibidos);
	} elsif ($opcion eq "d"){
		# eko("opc d");
		mostrardDestinoMasSospechoso(@archivosRecibidos);
	} elsif ($opcion eq "e"){
		# eko("opc e");
		mostrarRankingDeUmbrales(@archivosRecibidos);
	}
}































# Hace un print del mensaje recibido por parametro.
# Le agrega el \n al final para que sea mas facil.



	# sub imprimir{

	# 	#veo la cantidad de parametros recibidos
	# 	my $n = scalar(@_);

	# 	#esto me agarra solo el primer parametro.
	# 	my ($name) = @_;

	# 	# esto me deja los 2 primeros parametros en el asunto
	# 	my ($name, $frase) = @_;


	# 	print "Se pasaron $n parametros \n";
	# 	print "$name \n";
	# 	print "$frase \n";
	# }


# si esta activado, lo desactivo.
# y viceversa
sub manejarEstadoDeGrabacion{
	if ($ESTADO_GRABACION == 0){

		#aca estoy activando la grabacion.
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
	eko("Instruccion invalida.");
	eko("Usa -h para una lista de posibles instrucciones");
}

sub mostrarAyuda(){
	eko("==========================================================");
	eko("=======================AFLIST=============================");
	eko("==========================================================");
	eko("=  -w  para activar la opcion de guardado                =");
	eko("=  -r para realizar consultas sobre llamadas sospechosas =");
	eko("=  -s para visualizar estadisticas                       =");
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
	eko("=  w  para activar/desactivar la grabacion de consultas ==");
	eko("=  r  para realizar consultas sobre llamadas sospechosas =");
	eko("=  s  para visualizar estadisticas                       =");
	eko("=                                                        =");
	eko("=  q  para terminar la ejecucion                          =");
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
	eko("introducir oficina(as) separadas por espacio:");

	$oficinas = <STDIN>;
	chomp($oficinas);	

	return split( /\s+/, $oficinas);
}

#esto me va a devolver el nombre de los archivos que estoy buscando.
# $1 recibe el tipo de filtro
# $2 la lista de filtros.
sub obtenerArchivosAProcesar{

	eko("obteniendo archivos a procesar");
	my @archivosParaConsultar;
	my ($tipoFiltro, @arrayFiltros) = @_;


  	# $rutaSospecha = "$PROCDIR/$archivos[$a]";
	my $dir = "$PROCDIR/";
    opendir(DIR, $dir) or die $!;

    while (my $file = readdir(DIR)) {

        # Use a regular expression to ignore files beginning with a period
        next if ($file =~ m/^\./);

		@campos = split("_",$file);

        if ( $tipoFiltro eq "ANIOMES"){
        	
        	for my $i (0..$#arrayFiltros){
        		if ($arrayFiltros[$i] eq $campos[1]){

        			eko("Pusheando $file al array con ANIOMES");
        			push @archivosParaConsultar, $file;

        			last;
        		} 
        	}
        } else{
        	for my $i (0..$#arrayFiltros){
        		if ($arrayFiltros[$i] eq $campos[0]){
        			eko("Pusheando $file al array con OFCINAS");
        			push @archivosParaConsultar, $file;

        			last;
        		} 
        	}
        }
    }

    closedir(DIR);

    return @archivosParaConsultar;
}


# Filtra array de archivos de acuerdo al tipo de filtro y  array de filtros
# LOS ARRAYS SE DEBEN PASAR POR REFERENCIA SINO NO FUNCIONA!
sub filtrarArchivos {
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

	} else {
		eko("Tipo de filtro invalido.");
			return; 
	}

	return @resultado;
}

sub obtenerArchivos {
	eko("obteniendo archivos a procesar");
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
	eko("=   Seleccione la opcion deseada:                        =");
	eko("=     1) consultar sobre reg de llamadas sospechosas     =");
	eko("=     2) introducir nombre de oficina para consultar     =");
	eko("=     3) introducir aniomes                              =");
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
	eko("=   Seleccione la opcion deseada:                         =");
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
			eko("Seleccione input de consultas.");
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
	eko("introducir aniomes(es) separadas por espacio:");

	$aniomes = <STDIN>;
	chomp($aniomes);	

	return split( /\s+/, $aniomes);
}


sub pedirAnioMes{
	
	@filtrosAnioMes = obtenerFiltrosAnioMes;
	@archivos = obtenerArchivos($inputConsultas, "ANIOMES", @filtrosAnioMes);
	while(1) {
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

			mostrarOpcionesDeFiltros(@archivos);
		} elsif ($opcionSeleccionada == 2) {
			mostrarOpcionesDeFiltros(@archivos);
		} else {
			eko("Ingrese una opción valida por favor."); eko("");
		}
	}
}

sub pedirSubLlamadas {
	eko("introducir sufijo(s) de subllamadas separados por espacio:");

	$inputSufijos = <STDIN>;
	chomp($inputSufijos);	

	my @sufijos = split( /\s+/, $inputSufijos);
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
	my $dir = "$PROCDIR";
	my @archivosAProcesar;

	my ($opc) = @_;
    opendir(DIR, $dir) or die $!;

    while (my $file = readdir(DIR)) {

        # Use a regular expression to ignore files beginning with a period
        next if ($file =~ m/^\./);

        push @archivosAProcesar, $file;
    }

    if ($opc == 1){
		mostrarOpcionesDeFiltros(@archivosAProcesar);
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
	@archivos = obtenerArchivos($inputConsultas, "OFICINAS", @filtrosOficinas);
	while(1) {
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

			mostrarOpcionesDeFiltros(@archivos);
		} elsif ($opcionSeleccionada == 2) {

			mostrarOpcionesDeFiltros(@archivos);
		} else {
			eko("Ingrese una opción valida por favor."); eko("");
		}	
	}
}


sub pedirOficinasEstadisticas{
	eko("introducir oficina(as) separadas por espacio:");

	$oficinas = <STDIN>;
	chomp($oficinas);	

	my @aOficinas = split( /\s+/, $oficinas);


	@archivosAProcesar = obtenerArchivosAProcesar("OFICINAS", @aOficinas);


	mostrarOpcionesDeFiltrosEstadisticas(@archivosAProcesar);
}


sub mostrarMenuEstadisticas{
	$opcionElegida = mostrarFormasDeConsultarLlamadasSospechosas;

	#eko("ACA LA OPCION ES $opcionElegida");
	if ($opcionElegida eq "1"){
		#va a la parte de las querys con todos los achivos
		obtenerTodosLosArchivosDeSospechas(0);
	} elsif ($opcionElegida eq "2"){
		pedirOficinasEstadisticas;
	} elsif ($opcionElegida eq "3"){
		pedirAnioMesEstadisticas;
	} elsif ($opcionElegida eq "4"){

	} else{

	}
}

sub menuConsultasLlamadasSospechosas {
	my $pathInput = @_[0];
	
	$opcionElegida = mostrarFormasDeConsultarLlamadasSospechosas;

	if ($opcionElegida eq "1") {
		@archivos = obtenerTodosLosArchivos($pathInput);
		eko("Archivos: @archivos");

		mostrarOpcionesDeFiltros(@archivos);

	} elsif ($opcionElegida eq "2") {
		pedirOficinas;

	} elsif ($opcionElegida eq "3") {
		pedirAnioMes;

	} else{

	}
}

sub menuConsultasSubLlamadas {
	my $pathInput = @_[0];

	my $opcionElegida = mostrarFormasDeConsultarSubLlamadas;

	if ($opcionElegida eq "1") {
		@archivos = obtenerTodosLosArchivos($pathInput);
		eko("Archivos: @archivos");

		mostrarOpcionesDeFiltros(@archivos);

	} elsif ($opcionElegida eq "2") {
		
		pedirSubLlamadas;
	} else {

	}
}

sub mostrarMenuConsultas{
	
	my ($inputConsultas, $tipoInput) = obtenerInputConsultas();

	eko("inputConsultas: $inputConsultas");
	#eko("tipoInput: $tipoInput");
	
	if ($tipoInput eq 1) {
		menuConsultasLlamadasSospechosas($inputConsultas);

	} elsif ($tipoInput eq 2) {
		menuConsultasSubLlamadas($inputConsultas);
	} else {

	}

}

sub mostrarEstadisticas{

	eko("La central con mayor cantidad de llamadas sospechosas es: ");
	eko("Ranking de centrales"); #mostrar codigo y descripcion de central.
	eko("La oficina con mayor cantidad de llamadas sospechosas es: ");
	eko("El agente con mayor cantidad de llamadas sospechosas es: ");
	eko("Ranking de agentes: "); #ID del agente, mail y oficina a la cual pertenece
	eko("El destino con mayor cantidad de llamadas sospechosas es: ");
	eko("Ranking de destinos: "); #mostrar codigo y nombre pais/provincia/ciudad.
	eko("Ranking de umbrales:"); #filtrar los que tengan menos de 2 llamadas.
}


sub menuMain{
	$deberiaEjecutarme = 1;
	while ($deberiaEjecutarme == 1){
		# system 'clear';
		$opcion = mostrarMenuYPedirOpcion;

		if ($opcion eq "h"){
			mostrarAyuda();
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
			mostrarAyuda();
		}elsif ($primerArgumento eq "-w"){
			# eko ("-w selecionada");
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




