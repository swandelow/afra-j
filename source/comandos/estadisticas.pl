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


# Hace un print del primer parametro.
sub eko{

	my ($msg) = @_;
	print "$msg \n";
}

sub imprimirSeparador{
	eko("---------------------");
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

	eko("---------------------------------------");
	eko("------------CENTRALES SOSPECHOSAS---------------------");
	eko("---------------------------------------");
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
		imprimirSeparador;
	}
}


# no mostrarlo si tiene solo 1 llamada.
# TODO: falta ver que carajo hacer con los umbrales
sub mostrarRankingDeUmbrales{
	eko("---------------------------------------");
	eko("------------RANKING DE UMBRALES---------------------");
	eko("---------------------------------------");
	my %hashUmbrales;
	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
	while($linea = <ENT>){
		chomp($linea);
		$idUmbral = obtenerCampo("$linea", "$ID_UMBRAL");

		# Incremento el contador.
		$hashUmbrales{$idUmbral}++;
	}
	close(ENT);


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada central
	my @keys = sort { $hashUmbrales{$b} <=> $hashUmbrales{$a} } keys%hashUmbrales;
	my @values = @hashUmbrales{@keys};

	for my $i (0..$#keys){
		# el enunciado pedia ignorar umbrales 
		if ($keys[$i] > 1){
			print ("$keys[$i] #$values[$i] apariciones -> ");
			print `grep "$keys[$i]" -R $RUTA_UMBRALES | cut -d';' -f2`;	
		} else {
			eko("ignorado");
		}
		
		imprimirSeparador;
	}
}

sub mostrarAgentesMasSospechosos{

	eko("---------------------------------------");
	eko("-----------Agentes mas sospechosos--------------------------");
	eko("---------------------------------------");

	my %hashAgentes;
	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
	while($linea = <ENT>){
		chomp($linea);
		$idAgente = obtenerCampo("$linea", "$ID_AGENTE");

		# Incremento el contador.
		$hashAgentes{$idAgente}++;
	}
	close(ENT);


	# Despues del while ya voy a tener en el hash todas las ocurrencias de cada central
	my @keys = sort { $hashAgentes{$b} <=> $hashAgentes{$a} } keys%hashAgentes;
	my @values = @hashAgentes{@keys};

	# ya tengo todo ordenado, me faltaria obtener el codigo y la descripcion.
	for my $i (0..$#keys){
		print ("$keys[$i] #$values[$i] apariciones -> ");
		# print `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f5`;
		$mail = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f5`;
		$oficina = `grep "$keys[$i]" -R $RUTA_AGENTES | cut -d';' -f4`;
		print("Mail: $mail");
		print("oficina: $oficina");
		imprimirSeparador;
	}
}

sub mostrarOficinaMasSospechosa{

eko("---------------------------------------");
eko("-------------Oficinas mas sospechosas--------------------");
eko("---------------------------------------");

my %hashAgentes;
	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
	while($linea = <ENT>){
		chomp($linea);
		$idAgente = obtenerCampo("$linea", "$ID_AGENTE");

		# Incremento el contador.
		$hashAgentes{$idAgente}++;
	}
	close(ENT);


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
		eko("Oficina $keys[$i] -> $values[$i] apariciones");
		imprimirSeparador;
	}
}

sub mostrardDestinoMasSospechoso{

eko("---------------------------------------");
eko("-------------Destinos mas sospechosos--------------------");
eko("---------------------------------------");

# En esta variable voy a ir acumulando los contadores de los destinos.
my %hashDestinos;
my %hashCodigoPais;
my %hashCodigoArea;
	open(ENT,"<$RUTA_SOSPECHAS")|| die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $RUTA_SOSPECHAS \n";
	while($linea = <ENT>){
		chomp($linea);
		$destinoSospechoso = obtenerCampo("$linea", "$NUMERO_DESTINO");
		$codigoArea = obtenerCampo("$linea", "$COD_AREA_B");
		$codigoPais = obtenerCampo("$linea", "$CODIGO_PAIS_B");

		# eko($codigoPais);
		# eko($codigoArea);

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
			eko(" Codigo: $hashCodigoPais{$keys[$i]}  ");
			print(" Nombre: ");
			print `grep "$hashCodigoPais{$keys[$i]}" -m 1 -R $RUTA_CIUDADES | cut -d';' -f1`;;
		} else {
			print(" Codigo: $hashCodigoArea{$keys[$i]}  ");
			print(" Nombre: ");
			print `grep "$hashCodigoArea{$keys[$i]}" -m 1 -R $RUTA_CIUDADES | cut -d';' -f1`;;

		}
		# print `grep "$keys[$i]" -R $RUTA_CENTRALES | cut -d';' -f2 \n`;
	}

	imprimirSeparador;
}


eko ("inicio ejecucion");

mostrarCentralMasSospechosas;

mostrarAgentesMasSospechosos;

mostrarOficinaMasSospechosa;

mostrardDestinoMasSospechoso;

mostrarRankingDeUmbrales;
