#!/bin/bash
# AUTOR: Pedro Antonio Mayorgas Parejo
# Fecha 20 de Agosto de 2023
ACTUALUID=`id -u`
if [ $ACTUALUID != '0' ]; then
    echo "Error: root UID Not found, please use sudo" >&2
    exit 127
fi

# THIS SCRIPT DO ARCHIVAL .SQL ON A SUBFOLDER FOR CLEANING THE BACKUP SUBDIR
# PLEASE DO NOT INCLUDE LAST /
backup_subdir=/var/backups/sql
backup_archival_subdir=/var/backups/archival

if [ ! -d $backup_subdir ]; then
    echo "Backup dir not found!!"
    mkdir -p $backup_subdir
fi
if [ ! -d $backup_archival_subdir ]; then
    echo "Backup archival not found!!" >&2
    mkdir -p $backup_archival_subdir
fi

# JUMPING TO THE FOLDER
cd ${backup_subdir}

# GETTING THE ACTUAL DAY
ACTUALDATE=`date +%y-%m-%d`

# CREATING TAR AND MOVING TO ARCHIVAL FOLDER
tar -czf dumps-${ACTUALDATE}.tar.gz $(ls | grep ".sql") && mv dumps-${ACTUALDATE}.tar.gz ${backup_archival_subdir}

# REMOVING .SQL 
rm $(ls | grep .sql)