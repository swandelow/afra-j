
sub eko {
	# Hace un print del mensaje recibido por parametro.
	# Le agrega el \n al final para que sea mas facil.
    my ($msg) = @_;
    print "$msg \n";
}

sub esDirectorioVacio {
	# Recibe el path de un directorio y verifica si está vacio.

    opendir(DIR, shift) or die $!;
    my @files = grep { !m/\A\.{1,2}\Z/ } readdir(DIR);
    closedir(DIR);
    @files ? 0 : 1;
}

sub obtenerCampo {
	# Le paso el nombre del campo del registro que quiero obtener.
	# Primer parametro: El registro entero.
	# Segundo parametro: El campo.
	my ($registro, $campo) = @_;
	@campos = split(";",$registro);
	return $campos[$campo];
}

sub imprimirSeparador{
	eko("---------------------");
}

sub procesarArchivos {
	# Lee los archivos y ejecuta la función "procesadora" por cada linea.
	# arefArchivos: Referencia a array de archivos.
	# fref: Referencia a función que procesará cada linea. 
	my ($inputDir, $arefArchivos, $fref) = @_;

	foreach $archivo (@$arefArchivos) {
  		$rutaSospecha = "$inputDir" . "/$archivo";

		open(ENT,"<$rutaSospecha") || die "NO SE PUEDE REALIZAR LA CONSULTA. No se encontro el archivo $rutaSospecha \n";
		while($linea = <ENT>){
			chomp($linea);
			$fref->($linea);
			
		}
		close(ENT);
	}
}

sub procesardorUmbrales {
	# Closure procesador de  umbrales.
	# Recibe una referencia al hash contador de umbrales.
	# Devuelve subrutina anónima que procesa la linea y aumenta el contador.
	my ($hrefUmbrales) = @_;
	return sub { my ($linea) = @_; $idUmbral = obtenerCampo("$linea", "$ID_UMBRAL"); $hrefUmbrales->{$idUmbral}++; };
}

sub procesadorCentralMasSospechosas {
	# Closure procesador de centrales.
	# Recibe referencias a los hashes contador de centrales y acumulador de tiempos de conversación.
	# Devuelve subrutina anónima que procesa la linea y aumenta el contador y el acumulador.
	my ($hrefCentrales, $hrefTiempoConversacion) = @_;
	return sub { my ($linea) = @_;
		$idCentral = obtenerCampo("$linea", "$ID_CENTRAL");
		$tiempoConversacion = obtenerCampo("$linea", "$TIEMPO_CONV");

		# Incremento el contador de llamadas sospechosas.
		$hrefCentrales->{$idCentral}++;
		# Acumulo tiempos de conversación.
		$hrefTiempoConversacion->{$idCentral} += $tiempoConversacion;
	};
}

sub procesadorAgentesMasSospechosos {
	# Closure procesador de agentes.
	# Recibe referencias a los hashes contador de agentes y acumulador de tiempos de conversación.
	# Devuelve subrutina anónima que procesa la linea y aumenta el contador y el acumulador.
	my ($hrefAgentes, $hrefTiempoConversacion) = @_;
	return sub { my ($linea) = @_;
		$idAgente = obtenerCampo("$linea", "$ID_AGENTE");
		$tiempoConversacion = obtenerCampo("$linea", "$TIEMPO_CONV");

		# Incremento el contador.
		$hrefAgentes->{$idAgente}++;
		# Acumulo tiempos de conversación.
		$hrefTiempoConversacion->{$idAgente} += $tiempoConversacion;
	};
}

sub procesadorOficinaMasSospechosa {
	# Closure procesador de oficinas.
	# Recibe referencias a los hashes contador de oficinas y acumulador de tiempos de conversación.
	# Devuelve subrutina anónima que procesa la linea y aumenta el contador y el acumulador.
	my ($hrerOficinas, $hrefTiempoConversacion) = @_;
	return sub { my ($linea) = @_;
		$idAgente = obtenerCampo("$linea", "$ID_AGENTE");
		$tiempoConversacion = obtenerCampo("$linea", "$TIEMPO_CONV");

		$oficina = `grep "$idAgente" -R $RUTA_AGENTES | cut -d';' -f4`;
		chomp($oficina);

		# Incremento el contador de cada oficina.
		$hrerOficinas->{$oficina}++;
		$hrefTiempoConversacion->{$oficina} += $tiempoConversacion;
	};
}

sub procesadorDestinoMasSospechoso {
	# Closure procesador de destinos.
	# Recibe referencias a los hashes contador de destinos y mapas <código, descripción> de país y área.
	# Devuelve subrutina anónima que procesa la linea y aumenta el contador y mapea las descripciónes.
	my ($hrerLineaDestino, $hrefCodigoPais, $hrefCodigoArea) = @_;
	return sub { my ($linea) = @_;
		$destinoSospechoso = obtenerCampo("$linea", "$NUMERO_DESTINO");
		$codigoPais = obtenerCampo("$linea", "$CODIGO_PAIS_B");
		$codigoArea = obtenerCampo("$linea", "$COD_AREA_B");

		# Incremento contador de llamadas al nro de linea destino.
		$hrerLineaDestino->{$destinoSospechoso}++;
		#  Si existe en el registro, almaceno el codigo de pais del nro destino.
		$hrefCodigoPais->{$destinoSospechoso} = $codigoPais if ($codigoPais ne '');
		#  Si existe en el registro, almaceno el codigo de area del nro destino.
		$hrefCodigoArea->{$destinoSospechoso} = $codigoArea if ($codigoArea ne '');
	};
}

sub verificarArgumentos {
	$numArgs = @ARGV;
	mostrarMsgInstr() if ($numArgs != 1);
}

1; #Requerido por Perl