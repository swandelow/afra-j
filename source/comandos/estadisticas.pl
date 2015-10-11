#!/usr/bin/perl

use warnings;

# En este archivo van a estar todas las funciones que tienen que ver
# Con la generacion de estadsitcas del AFLIST.
#
# Siempre saco los datos de las llamadas sospechosas


# FORMATO DE LOS REGISTROS:
# [0] Id central
# [1] Id agente.
# [2] ID del umbral.
# [3] Tipo de llamada.
# [4] Inicio de llamada.
# [5] Tiempo de conversacion.
# [6] Numero A (origen llamada)
# [7] Numbero B destino de la llamada.
# [8] Fecha del archivo.
my $ID_CENTRAL = 0;
my $ID_AGENTE = 1;
my $ID_UMBRAL = 2;
my $TIPO_LLAMDA =3;
my $INICIO_LLAMADA = 4;
my $TIEMPO_CONV = 5;
my $NUMERO_ORIGEN = 6;
my $NUMERO_DESTINO = 7;
my $FECHA_ARCHIVO =8;

#Setear la ruta a los archivos de sospechas.
#el sosp es una prueba.
my $RUTA_SOSPECHAS = "grupo06/sospechosas/sosp.txt";
my $RUTA_CENTRALES = "grupo06/mae/CdC.mae";


# Hace un print del primer parametro.
sub eko{

	my ($msg) = @_;
	print "$msg \n";
}
# Le paso el nombre del campo del registro que quiero obtener.

# Primer parametro: El registro entero.
# Segundo parametro: El campo.
sub obtenerCampo{
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

	my %hashCentrales;
	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
	while($linea = <ENT>){
		chomp($linea);
		$idCentral = obtenerCampo("$linea", "$ID_CENTRAL");

		# Incremento el contador.
		$hashCentrales{$idCentral}++;
	}
	close(ENT);


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada central
	my @keys = sort { $hashCentrales{$b} <=> $hashCentrales{$a} } keys%hashCentrales;
	my @values = @hashCentrales{@keys};

	# ya tengo todo ordenado, me faltaria obtener el codigo y la descripcion.
	for my $i (0..$#keys){
		print ("$keys[$i] #$values[$i] apariciones -> ");
		print `grep "$keys[$i]" -R $RUTA_CENTRALES | cut -d';' -f2`;
	}
}

eko ("inicio ejecucion");

mostrarCentralMasSospechosas;
