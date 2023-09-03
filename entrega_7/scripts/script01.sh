#!/bin/bash
# AUTOR: Pedro Antonio Mayorgas Parejo
# Fecha 20 de Agosto de 2023
ACTUALUID=`id -u`
if [ $ACTUALUID != '0' ]; then
    echo "Error: root UID Not found, please use sudo" >&2
    exit 127
fi

# THIS SCRIPT DO LOGICAL BACKUPS DUMPING TO A .SQL A COMPLETE DATABASE
# PLEASE DO NOT INCLUDE LAST /
backup_subdir=/var/backups/sql

if [ ! -d $backup_subdir ]; then
    echo "Backup dir not found!!" >&2
    mkdir -p $backup_subdir
fi

# The database user require for executing this scriot
# SELECT PRIVILEGE FOR DUMPING TABLES
# VIEW PRIVILEGE FOR DUMPING VIEWS
# TRIGGER PRIVILEGE FOR DUMPING TRIGGERS
# LOCK TABLES FOR DUMPING WITH ARG --single-transaction and --add-locks
# PROCESS FOR --no-tablespaces
db_user="tiendabd"
db_userpass="password"
db_conn="localhost"
db_name="tiendabd"
# BOOLEANS: TRUE OR FALSE
# BOOLEAN: SET TRUE IF YOU NEED DUMP FOR ALL DB. FALSE IF YOU NEED DUMP OF 
# BOOLEAN: SET LOCKING DB FOR CREATING DUMPING WIOUTH RACE CONDITION OF PARALLEL OR CONCURRENT TRANSACTIONS MISSED ARGS --single-transaction --add-locks
lock_db="TRUE"
# BOOLEAN: SET IF YOU NEED DROP SENTENCE BEFORE CREATE DATABASE OR CREATE TABLE
add_drop="TRUE"
# BOOLEAN: SET IF YOU NEED REPLACE DATA ON TABLES INSTEAD OF INSERTING
replace_sentences="TRUE"
# BOOLEAN: SET IF YOU USE SOCKET OR FALSE FOR USE IP STACK AND db_conn
use_socket="TRUE"

# WE ARE USING A ARRAY FOR APPENDING THE PARAMETERS TO THE BASE COMMAND
declare -a DUMPCOMMAND=("mysqldump --user=${db_user} --password=${db_userpass} --databases ${db_name}")

if [ $add_drop = 'TRUE' ]; then
    DUMPCOMMAND+=(' --add-drop-database --add-drop-table')
fi

if [ $lock_db = 'TRUE' ]; then
    DUMPCOMMAND+=(' --add_locks')
fi

if [ $replace_sentences = 'TRUE' ]; then
    DUMPCOMMAND+=(' --replace')
fi

if [ $use_socket = 'TRUE' ]; then
    DUMPCOMMAND+=(" --host=${db_conn}")
fi

ACTUALDATE=`date +%y-%m-%d-%H:%M`

DUMPCOMMAND+=(" --result-file=${backup_subdir}/dump-${ACTUALDATE}.sql")

# echo "${DUMPCOMMAND[@]}"
${DUMPCOMMAND[@]}