#!/usr/bin/env bash
#!----------------------------------------------------------------------------!
#!                                                                            !
#! Yexpert : (your) Système Expert sous Mumps GT.M et GNU/Linux               !
#! Copyright (C) 2001-2015 by Hamid LOUAKED (HL).                             !
#!                                                                            !
#!----------------------------------------------------------------------------!

# Assurez-vous que nous sommes en root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root" 1>&2
    exit 1
fi

# Sur mon système, j’initialise les variables LANG et LC_MESSAGES à,
# respectivement, fr_FR.utf8 et en_US.utf8. Ainsi, les différents programmes
# appliquent les paramètres régionaux français à l’exception des messages qui
# sont affichés en anglais. Cela implique de bien inclure ces deux « locales »
# dans le fichier /etc/locale.gen. Toutefois, celles-ci peuvent être
# indisponibles sur certains systèmes distants. La plupart des applications se
# rabattent sur la locale C sans broncher. Une exception notable est Perl qui
# se plaint très bruyamment.
# La documentation de Perl explique comment se débarasser de ce message.

export PERL_BADLANG=0

# Si fr_FR.UTF-8 n'est pas installé,
# lancer "sudo dpkg-reconfigure locales"
# choisir UTF8 en_US.UTF-8 + fr_FR.UTF-8

# Options
# instance = nom de l'instance
# utilisation http://rsalveti.wordpress.com/2007/04/03/bash-parsing-arguments-with-getopts/
# documentation à titre indicatif

usage()
{
    cat << EOF
    usage: $0 options

    Ce script permet de créer automatiquement une instance Yexpert pour GT.M sur Debian

    DEFAULTS:
      Dépôt Yexpert-Box alternatif = https://github.com/Yrelay/Yexpert-Box.git
      Dépôt Yexpert-M alternatif = https://github.com/Yrelay/Yexpert-M.git
      Dépôt Yexpert-JS alternatif = https://github.com/Yrelay/Yexpert-JS.git
      Dépôt de la partition utilisateur = https://github.com/Yrelay/Yexpert-DMO.git
      Installer Yexpert-JS = false
      Créer les répertoires de développement = false
      Nom de l'instance = Yrelay
      Nom de la partition utilisateur = DMO
      Post Installation = none
      Réinstaller l'instance = false
      Passer les tests = false

    OPTIONS:
      -h    Afficher ce message
      -a    Dépôt Yexpert-M alternatif (Doit être au format Yrelay)
      -b    Dépôt Yexpert-JS alternatif (Doit être au format Yrelay)
      -c    Dépôt Yexpert-DMO alternatif (Doit être au format Yrelay)
      -e    Installer Yexpert-JS (gère les répertoires de développement)
      -d    Créer les répertoires de développement (s & p)
      -i    Nom de l'instance
      -j    Nom de la partition utilisateur
      -p    Post Installation (chemin vers le script)
      -r    Réinstaller l'instance
      -s    Passer les tests

EOF
}

while getopts ":habc:edij:p:rs" option
do
    case $option in
        h)
            usage
            exit 1
            ;;
        a)
            cheminDepotM=$OPTARG
            ;;
        b)
            cheminDepotJS=$OPTARG
            ;;
        c)
            cheminDepotPartUtil=$OPTARG
            ;;
        d)
            repertoireDev=true
            ;;
        e)
            installerJS=true
            repertoireDev=true
            ;;
        i)
            instance=$(echo $OPTARG |tr '[:upper:]' '[:lower:]')
            ;;
        j)
            # TODO: Ne fonctionne pas
            partitionUtil=$(echo $OPTARG |tr '[:upper:]' '[:lower:]')
            ;;
        p)
            postInstallation=true
            postInstallationScript=$OPTARG
            ;;
        r)
            reInstall=true
            ;;
        s)
            passerLesTests=true
            ;;
    esac
done

# Paramètres par défaut pour les options
if [[ -z $cheminDepot ]]; then
    cheminDepot="https://github.com/Yrelay/"
    cheminDepotBox="https://github.com/Yrelay/Yexpert-Box.git"
    cheminDepotM="https://github.com/Yrelay/Yexpert-M.git"
    cheminDepotJS="https://github.com/Yrelay/Yexpert-JS.git"
    cheminDepotPartUtil="https://github.com/Yrelay/Yexpert-DMO.git"
fi

if [[ -z $repertoireDev ]]; then
    repertoireDev=false
fi

if [[ -z $installerJS ]]; then
    installerJS=false
fi

if [[ -z $instance ]]; then
    instance=yrelay
fi

if [[ -z $partitionUtil ]]; then
    partitionUtil=DMO
fi

if [[ -z $postInstallation ]]; then
    postInstallation=false
fi

if [ -z $reInstall ]; then
    reInstall=false
fi

if [ -z $passerLesTests ]; then
    passerLesTests=false
fi

# Abandonner l'installation s'il semble que l'instance existe déjà.
if [ -d /home/$instance/globals ] && ! $reInstall ; then
    echo "Yexpert est déjà installé. Abandon."
    echo "Vous pouvez réinstaller l'instance $instance en ajoutant l'option -r"
    echo "ATTENTION : avec l'option -r toutes les données seront perdues."
    exit 0
else
    if [ -d /home/$instance/globals ] && $reInstall ; then
        # Rechercher les processus $instance qui sont encore en cours d'exécution
        # TODO: Fermer d'une manière plus douce
        echo "Les processus liés à l'instance $instance seront fermer de force !"
        echo "Tuer les process yrelay*"
        pkill -u "yrelay"
        pkill -u "yrelayutil"
        pkill -u "yrelayprog"

        echo "10 seconds d'attente"
        sleep 10

        echo "Lister les process yrelay*"
        ps -u "yrelay"
        ps -u "yrelayutil"
        ps -u "yrelayprog"
    fi
fi

# Résumer des options
echo "!------------------------------------------------------!"
echo "Utiliser $cheminDepot pour les routines et globales"
echo "Créer les répertoires de développement : $repertoireDev"
echo "Installer l'instance nommée : $instance"
echo "Installer la partition utilisateur nommée : $partitionUtil"
echo "Installer Yexpert-JS : $installerJS"
echo "Post installation : $postInstallation"
echo "Ré-installation : $reInstall"
echo "Passer les tests : $passerLesTests"
echo "!------------------------------------------------------!"

# Obtenir le nom de l'utilisateur principal si vous utilisez sudo, default si $username n'est pas sudo
if [[ -n "$SUDO_USER" ]]; then
    utilisateurPrincipal=$SUDO_USER
elif [[ -n "$USERNAME" ]]; then
    utilisateurPrincipal=$USERNAME
else
    echo "Nom d'utilisateur non trouvé ou approprié à ajouter au groupe $instance"
    exit 1
fi

echo "Ce script va ajouter $utilisateurPrincipal au groupe $instance"

# le contrôle de l'interactivité des outils de Debian
export DEBIAN_FRONTEND="noninteractive"

# utilitaires supplémentaires - utilisé pour les clones initiaux
# Remarque: Amazon EC2 nécessite deux commandes apt-get update pour fonctionner
echo "Mettre à jour le système d'exploitation"
apt-get update -qq > /dev/null
apt-get update -qq > /dev/null
apt-get install -qq -y build-essential cmake-curses-gui git dos2unix daemon > /dev/null

# Voir si le dossier vagrant existe si oui l'utiliser. si non cloner le dépôt
if [ -d /vagrant ]; then
    repScript=/vagrant

    # Convertir les fins de lignes
    find /vagrant -name \"*.sh\" -type f -print0 | xargs -0 dos2unix > /dev/null 2>&1
    dos2unix /vagrant/ewd/config/init.d/ewdjs > /dev/null 2>&1
    dos2unix /vagrant/gtm/config/init.d/yexpert > /dev/null 2>&1

else
    # TODO: à commenter
    if [ -d /home/$utilisateurPrincipal/Yrelay/Yexpert-Box ]; then
        repScript=/home/$utilisateurPrincipal/Yrelay/Yexpert-Box
    else
        if [ -d /usr/local/src/Yexpert-Box ]; then
            rm -rf /usr/local/src/Yexpert-Box
        fi
        cd /usr/local/src
        git clone -q $cheminDepotBox Yexpert-Box
        repScript=/usr/local/src/Yexpert-Box
    fi
fi

# Amorcer le sytème
cd $repScript
./debian/amorcerServeurDebian.sh

# Indiquer au scripts que nous sommes sur une distribution debian
export debian=true;

# Installer GTM
cd gtm
./installerGTM.sh

# Créer une instance Yexpert
./creerInstanceYexpert.sh -i $instance

# Abandonner l'installation si l'instance n'a âs été créée
if ! [ -d /home/$instance/globals ] ; then
    echo "L'instance $instance n'a pas pu être créée. Abandon."
    exit 0
fi

# Modifier l'utilisateur principal afin qu'il soit en mesure d'utiliser l'instance Yexpert
usermod -a -G $instance $utilisateurPrincipal
chmod g+x /home/$instance

# Créer les variables d'environnement que devra utiliser $basedir
source /home/$instance/config/env

#HL170122# Obtenir le répertoire personnel de l'utilisateur
#HL170122USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

#HL170122# Modifier le fichier .bashrc pour le script env soit lancé au démarrage
#HL170122echo "source $basedir/config/env" >> $USER_HOME/.bashrc

# Construire un environnement Yexpert et exécuter les tests pour vérifier l'installation
# L'environnement Yexpert sera cloner depuis le dépot Yexpert-M
# Exécuter ceux-ci avec l'utilisateur $instance

# Cloner le dépot Yexpert-M
cd $basedir/src
git clone $cheminDepotM Yexpert-M

# Retourner à $basedir
cd $basedir

# Effectuer l'importation
su $instance -c "source $basedir/config/env && $repScript/gtm/importerYexpert-M.sh"

if $passerLesTests; then
    # Créer une chaîne aléatoire pour l'identification de la construction
    export buildID=`tr -dc "[:alpha:]" < /dev/urandom | head -c 8`

    # Importer Yexpert et lancer les tests utilisés par Yrelay
    su $instance -c "source $basedir/config/env && ctest -S $repScript/debian/test.cmake -V"
    # Dire aux utilisateurs leur ID de construction
    echo "Votre ID de construction est: $buildID vous en aurez besoin pour identifier votre construction sur Yexpert"
fi

# Activer la journalisation
su $instance -c "source $basedir/config/env && $basedir/scripts/activerJournal.sh"

# Redémarrer xinetd
service xinetd restart

# Ajouter P et S répertoires à la variable d'environnement gtmroutines
if $repertoireDev; then
    su $instance -c "mkdir $basedir/{p,p/$gtmver,s,s/$gtmver}"
    perl -pi -e 's#export gtmroutines=\"#export gtmroutines=\"\$basedir/p/\$gtmver\(\$basedir/p\) \$basedir/s/\$gtmver\(\$basedir/s\) #' $basedir/config/env
fi

# Installer Yexpert-JS
if $installerJS; then
    cd $repScript/yexpert-js
    ./yexpert-js.sh
    cd $basedir
fi

# Construire un environnement nodejs pour Yexpert
# L'environnement Yexpert-JS sera cloner depuis les dépots Yexpert-JS
# Copier le réperotre /www/

# Cloner le dépot Yexpert-JS
#***cd $basedir/src
#***git clone $cheminDepotJS Yexpert-JS

# Retourner à $basedir
#***cd $basedir

# Effectuer l'importation de Yexpert-JS
#***su $instance -c "source $basedir/config/env && $repScript/gtm/importerYexpert-JS.sh"

# Construire un environnement pour la partition utilisateur (par défaut DMO)
# L'environnement de la partition utilisateur sera cloner depuis le dépot $partitionUtil 
# Créer la partititon utilisateur avec importerPartitionUtil.sh

# Cloner le dépot de la partition utilisateur (par défaut Yexpert-DMO)
cd $basedir/src
git clone $cheminDepotPartUtil Yexpert-${partitionUtil^^}

# Retourner à $repScript
cd $repScript

# Créer une partition utilisateur
./gtm/creerPartitionUtil.sh -i ${partitionUtil^^}

# Effectuer l'importation de Yexpert-$partitionUtil
su $instance -c "source $basedir/partitions/${partitionUtil,,}/config/env && $repScript/gtm/importerPartitionUtil.sh"

# Ajouter les outils de développement
# Axiom - Developer tools for editing M[UMPS]/GT.M routines in Vim
##if $devInstallation; then
    apt-get install vim -y
    cd $basedir/src
    git clone https://github.com/dlwicksell/axiom.git
    cd axiom
    su $instance -c "source $basedir/config/env && ./install -q"
    # Retourner à $basedir
    cd $basedir
##fi

# Post-installation
if $postInstallation; then
    su $instance -c "source $basedir/config/env && $postInstallationScript"
fi

# Mettre les droits corrects
chmod -R g+rw /home/$instance

# Retourner à $repScript
cd $repScript

# Relancer les services s'il s'agit d'une réinstallation.
# TODO: à déplacer
if $reInstall ; then
    echo "Redémarrer les services ${instance}yexpert et ${instance}yexpert-js"
    service ${instance}yexpert restart
    service ${instance}yexpert-js restart
fi

echo "Installation Auto terminée..."



