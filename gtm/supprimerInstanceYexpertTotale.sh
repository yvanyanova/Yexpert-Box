#!/usr/bin/env bash
#!----------------------------------------------------------------------------!
#!                                                                            !
#! Yexpert : (your) Système Expert sous Mumps GT.M et GNU/Linux               !
#! Copyright (C) 2001-2015 by Hamid LOUAKED (HL).                             !
#!                                                                            !
#!----------------------------------------------------------------------------!

# Supprimer totalement l'instance de Yexpert 
# Cet utilitaire nécessite privliges root

# Assurez-vous que nous sommes en root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root" 1>&2
    exit 1
fi

# Si chkconfig n'est pas installé
apt-get install chkconfig

# Options
# Utilisation http://rsalveti.wordpress.com/2007/04/03/bash-parsing-arguments-with-getopts/
# Documentation à titre indicatif

usage()
{
    cat << EOF
    usage: $0 options

    Ce script permet de supprimer une instance de Yexpert pour GT.M

    OPTIONS:
      -h    Afficher ce message
      -i    Nom de l'instance
EOF
}

while getopts ":hi:" option
do
    case $option in
        h)
            usage
            exit 1
            ;;
        i)
            instance=$(echo $OPTARG |tr '[:upper:]' '[:lower:]')
            ;;
    esac
done

if [[ -z $instance ]]
then
    usage
    exit 1
fi

# $basedir est le répertoire de base de l'instance
# exemples d'installation possibles : /home/$instance, /opt/$instance, /var/db/$instance
basedir=/home/$instance

# Arrêter le service
if [[ $debian || -z $RHEL ]]; then
    update-rc.d ${instance}yexpert remove
    update-rc.d ${instance}yexpert-js remove
fi

if [[ $RHEL || -z $debian ]]; then
    chkconfig --del ${instance}yexpert
    chkconfig --del ${instance}yexpert-js
fi

# Arrêter et supprimer les services
if [ -h /etc/init.d/${instance}yexpert ]; then
    service ${instance}yexpert stop
    rm /etc/init.d/${instance}yexpert
fi

if [ -h /etc/init.d/${instance}yexpert-js ]; then
    service ${instance}yexpert-js stop
    rm /etc/init.d/${instance}yexpert-js
fi

# Supprimer l'instance $instance s'il semble qu'elle existe déjà.
if grep "^$instance:" /etc/passwd > /dev/null ||
   grep "^${instance}util:" /etc/passwd > /dev/null ||
   grep "^${instance}prog:" /etc/passwd > /dev/null ; then
    deluser --remove-home ${instance}util
    deluser --remove-home ${instance}prog
    deluser --remove-home ${instance}
    delgroup ${instance}util
    delgroup ${instance}prog
    delgroup ${instance}
fi

echo "L'instance d'Yexpert $instance est supprimée..."



