#!/usr/bin/perl

use warnings;

# Hace un print del mensaje recibido por parametro.
# Le agrega el \n al final para que sea mas facil.
sub imprimir{

	#veo la cantidad de parametros recibidos
	my $n = scalar(@_);

	#esto me agarra solo el primer parametro.
	my ($name) = @_;

	# esto me deja los 2 primeros parametros en el asunto
	my ($name, $frase) = @_;


	print "Se pasaron $n parametros \n";
	print "$name \n";
	print "$frase \n"
}

# Hace un print del primer parametro.
sub eko{

	my ($msg) = @_;
	print "$msg \n";
}

sub informarComandoErroneo(){
	eko("La opcion ingresada es erronea. Vuelva a intentar.");
}

sub mostrarMsgInstr{
	eko("Instruccion invalida.");
	eko("Usa -h para una lista de posibles instrucciones");
}

sub mostrarAyuda(){
	eko("==========================================================");
	eko("=======================AFLIST=============================");
	eko("==========================================================");
	eko("=  -w  para grabar consultas realizada                   =");
	eko("=  -r para realizar consultas sobre llamadas sospechosas =");
	eko("=  -s para visualizar estadisticas                       =");
	eko("=  -h para acceder a este menu                           =");
	eko("==========================================================");
	eko("==========================================================");
	eko("==========================================================");
}

# me devuelve la opcion de la salida elegida.
sub mostrarFormasDeConsultarLlamadasSospechosas(){
	eko("==========================================================");
	eko("====Consultas de llamadas sospechosas ====================");
	eko("=                                                        =");
	eko("=   Seleccione la opcion deseada:                        =");
	eko("=     1) consultar sobre reg de llamadas sospechosas     =");
	eko("=     2) consultar sobre archivos de consultas previos   =");
	eko("=                                                        =");
	eko("==========================================================");

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

	# el usuario por fin eligio una opcion valida.
	# felicitarlo.
	return $salidaElegida;
}

sub mostrarEstadisticas(){
	eko("La central con mayor cantidad de llamadas sospechosas es: ");
	eko("Ranking de centrales"); #mostrar codigo y descripcion de central.
	eko("La oficina con mayor cantidad de llamadas sospechosas es: ");
	eko("El agente con mayor cantidad de llamadas sospechosas es: ");
	eko("Ranking de agentes: "); #ID del agente, mail y oficina a la cual pertenece
	eko("El destino con mayor cantidad de llamadas sospechosas es: ");
	eko("Ranking de destinos: "); #mostrar codigo y nombre pais/provincia/ciudad.
	eko("Ranking de umbrales:"); #filtrar los que tengan menos de 2 llamadas.
}

sub chequearCantidadArgumentos{
	$numArgs = @ARGV;

	eko ("$numArgs");

	#Si no recibo exactamente un parametro le muestro el mensaje de -h
	if ( $numArgs != 1) {
		mostrarMsgInstr();
	} else {
		eko ("no hay 1 argumento");
		# vamos a ver si es un argumento valido.
		$primerArgumento = "$ARGV[0]";
		if ($primerArgumento eq "-h"){
			mostrarAyuda();
		}elsif ($primerArgumento eq "-w"){
			eko ("-w seleccionada");
		}elsif ($primerArgumento eq "-r"){
			mostrarFormasDeConsultarLlamadasSospechosas();
		}elsif ($primerArgumento eq "-s"){
			mostrarEstadisticas();
		} else{
			mostrarMsgInstr();
		}
	}
}

# Primero vamos a chequear que se haya llamado a la funcion con algun argumento
# y sino le vamos a decir que use el -h para pedir ayuda.

chequearCantidadArgumentos();


