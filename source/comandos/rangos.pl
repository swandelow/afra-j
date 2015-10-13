#!/usr/bin/perl

use warnings;
use Scalar::Util qw(looks_like_number);

# se pueden realizar consultas sobre un archivo, extender esto de uno hasta muchos.
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

#Setear la ruta a los archivos de sospechas.
my $RUTA_SOSPECHAS = "grupo06/sospechosas/salida_afumb.txt";
my $RUTA_CENTRALES = "grupo06/mae/CdC.mae";
my $RUTA_AGENTES = "grupo06/mae/agentes.mae";
my $RUTA_CIUDADES = "grupo06/mae/CdA.mae";
my $RUTA_PAISES = "grupo06/mae/CdP.mae";
my $RUTA_UMBRALES = "grupo06/mae/umbral.tab";

# Filtros a ser aplicados.
my @filtrosCentral;


# Hace un print del mensaje recibido por parametro.
# Le agrega el \n al final para que sea mas facil.

sub eko{
	my ($msg) = @_;
	print "$msg \n";
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

  	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
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
	eko("Afuera");

  	# Me devuelve la leng mas 1.
  	# eko("La long del array es $#array")
}

sub pedirFiltroAgentes{
	eko("Introducir ID(s) de agente(s):");

	$filtros = <STDIN>;
	chomp($filtros);	

	my @filtrosArray = split( /\s+/, $filtros);
	my @resultados;
  	# eko($array[1]);

  	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
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
			push @resultados, $linea;
		}
	}
	close(ENT);

	mostrarResultados(@resultados);

  	# Me devuelve la leng mas 1.
  	# eko("La long del array es $#array")
}


# TODO:
sub pedirFiltroUmbral{
	eko("Introducir umbral(es):");
}

# TODO:
sub pedirFiltroTipoLlamada{
	eko("Introducir filtro(s) de tipos de llamada:");
}

sub mostrarMensajeRangoInvalido{
	eko("Rango invalido! Intentar nuevamente");
}

# vamos a tener que validar 
sub pedirFiltroPorTiempoDeDuracion{

	#primero hay que ver que sea valido el intervalo, o no?
	my @resultados;

	eko("Introducir el intervalo separado por espacio:");

	$opcionValida = 0;
	while ($opcionValida == 0){
		$filtros = <STDIN>;
		chomp($filtros);	

		@intervalo = split( /\s+/, $filtros);

		eko("@intervalo");
		# si no tiene 2 parametros es invalido
		if ($#intervalo eq 1){
			eko("cantidad erronea de parametros");
			if ( looks_like_number($intervalo[0]) && looks_like_number($intervalo[1]) ){
				# si los 2 son numeros vamos bien.

				eko("Los 2 parecen numeros");

				# ahora vemos que sea un intervalo valido.
				if( ($intervalo[1] - $intervalo[0]) > 0){
					eko($intervalo[1] - $intervalo[0]);
					$opcionValida = 1;
				}
			}
		}
	}

	# el input es valido, hacer la query.

	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
	while($linea = <ENT>){
		chomp($linea);

		#todas las lineas son invalidas hasta que se demuestre lo contrario.
		$esValido = 0;

		$tiempoLlamada = obtenerCampo("$linea", "$TIEMPO_CONV");

		# viendo si el registro cae dentro de la query.
		if ($tiempoLlamada > $intervalo[0] && $tiempoLlamada < $intervalo[1]){
			push @resultados, $linea;
			#este seria el break de Perl.
		}
	}
	close(ENT);

	mostrarResultados(@resultados);
}


sub pedirFiltroNumeroA{
	eko("Introducir numero(s) A: ");

	$filtros = <STDIN>;
	chomp($filtros);	

	my @filtrosArray = split( /\s+/, $filtros);
	my @resultados;
  	# eko($array[1]);

  	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
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
			push @resultados, $linea;
		}
	}
	close(ENT);

	mostrarResultados(@resultados);
}



$opcion = mostrarOpciones;

if ($opcion eq "a"){
	eko("opc a");
	pedirFiltroCentral;
} elsif ($opcion eq "b"){
	eko("opc b");
	pedirFiltroAgentes	;
} elsif ($opcion eq "c"){
	pedirFiltroUmbral;
	eko("opc c");
} elsif ($opcion eq "d"){
	eko("opc d");
	pedirFiltroTipoLlamada;
} elsif ($opcion eq "e"){
	eko("opc e");
	pedirFiltroPorTiempoDeDuracion;
} elsif ($opcion eq "f"){
	eko("opc f");
	pedirFiltroNumeroA;
} elsif ($opcion eq "g"){
	eko("opc g");
}




