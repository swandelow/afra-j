#!/usr/bin/perl

use warnings;

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

sub pedirFiltroAgente{
	eko("Introducir ID(s) del agente:");
}

sub pedirFiltroUmbral{
	eko("Introducir umbral(es):");
}

sub pedirFiltroTipoLlamada{
	eko("Introducir filtro(s) de tipos de llamada:");
}

# vamos a tener que validar 
sub pedirFiltroPorTiempoDeDuracion{
	eko("Introducir rango de duracion: ej: [0 10]");
}


sub pedirFiltroNumeroA{
	eko("Introducir numero(s) A: ");
}



$opcion = mostrarOpciones;

if ($opcion eq "a"){
	eko("opc a");
	pedirFiltroCentral;
} elsif ($opcion eq "b"){
	eko("opc b");
} elsif ($opcion eq "c"){
	eko("opc c");
} elsif ($opcion eq "d"){
	eko("opc d");
} elsif ($opcion eq "e"){
	eko("opc e");
} elsif ($opcion eq "f"){
	eko("opc f");
} elsif ($opcion eq "g"){
	eko("opc g");
}




