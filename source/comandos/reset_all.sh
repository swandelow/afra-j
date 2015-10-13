#!/bin/bash

grupo="$1"

rm -r "$grupo/bin"
rm -r "$grupo/aceptadas"
rm -r "$grupo/novedades"
rm -r "$grupo/rechazadas"
rm -r "$grupo/sospechosas"
rm -r "$grupo/log"
rm -r "$grupo/mae"
rm -r "$grupo/reportes"
rm "$grupo/conf/AFINSTAL.cnfg" 
rm "$grupo/conf/AFINSTAL.lg" 

echo Se ha eliminado todos los directrios creadas por AFINSTALL
