
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

1; #Requerido por Perl