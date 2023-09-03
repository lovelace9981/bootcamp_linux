#!/bin/bash
# AUTOR: Pedro Antonio Mayorgas Parejo
# LAB 02: Especialidad de GNU/Linux

# TO ENABLE VERBOSE MODE
# 1 FOR ENABLING
# 0 FOR DISABLING
VERBOSE_MODE="0"
PATH_MAPS="/etc/app/juegos/mapas/"
PATH_OLD="/etc/app/juegos/old/"
PATH_LOGFILE="/var/log/historico.log"

# CHECK IF EXISTS OLD FOLDER
if [ ! -d ${PATH_OLD} ]
then
	echo "Error, la carpeta ${PATH_OLD} no existe, creando..."
	mkdir ${PATH_OLD}
	#exit 2
fi

# CHECK IF MAP PATH EXISTS
if [ ! -d ${PATH_MAPS} ]
then
	echo "Error, la carpeta ${PATH} no existe"
	exit 2
fi 

# OBTENEMOS NUMERO DE FICHEROS DE MAPA
numberfiles=$(ls ${PATH_MAPS} | grep -E '^*.map$' |  wc -l)
files=$(ls ${PATH_MAPS} | grep -E '^*.map$')

# CHECK IF WE HAVE FILES TO COMPRESS
if [ ${numberfiles} -eq "0" ]
then
	echo "No hay ficheros para comprimir en la copia de seguridad"
	exit 1
else
	echo "Creating empty tar.gz file"
	filenamebackup="copy-$(date +%y%m%d).tar"
	# CREAMOS UN FICHERO VACIO
	if [ ${VERBOSE_MODE} -eq "1" ]
	then
		tar -cvf ${PATH_OLD}${filenamebackup} -T /dev/null
	else
		tar -cf ${PATH_OLD}${filenamebackup} -T /dev/null
	fi

	# CHECK compressed file created
	if [ $? -eq 0 ]
	then
		echo "Created ${filenamebackup}"
	fi

	for f in ${files}
	do
		if [ ${VERBOSE_MODE} -eq "1" ]
		then
			tar -C ${PATH_MAPS} -uvf ${PATH_OLD}${filenamebackup} ${f}
			echo "FICHERO ${f} appended to ${filenamebackup}"
		else
			tar -C ${PATH_MAPS} -uf ${PATH_OLD}${filenamebackup} ${f}
		fi
	done

	numberfilescompressed=$(tar -tvf ${PATH_OLD}${filenamebackup} | wc -l)
	echo "FILES LISTED: ${numberfiles} | FILES COMPRESSED: ${numberfilescompressed}"
	
	if [ ${numberfilescompressed} -ne ${numberfiles} ]
	then
		echo "All files aren't compressed on tar"
	fi
	
	# COMPRESS
	gzip ${PATH_OLD}${filenamebackup}

	# CHECK IF LOGFILE EXISTS
	if [ ! -f ${PATH_LOGFILE} ]
	then	
		echo "Creating logfile..."
		touch ${PATH_LOGFILE}
	fi

	# OUTPUT TO LOGFILE
	echo "BACKUP MAKED BY ${USER} AT $(date +%y%m%d-%H:%M)" >> ${PATH_LOGFILE}
fi

