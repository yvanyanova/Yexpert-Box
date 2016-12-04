#!/usr/bin/env bash
#!----------------------------------------------------------------------------!
#!                                                                            !
#! Yexpert : (your) Système Expert sous Mumps GT.M et GNU/Linux               !
#! Copyright (C) 2001-2015 by Hamid LOUAKED (HL).                             !
#!                                                                            !
#!----------------------------------------------------------------------------!

# Importer Yexpert Globals et Routines dans l'instance $instance

# Vérifier la présence des variables requises
if [[ -z $instance && $gtmver && $gtm_dist && $basedir ]]; then
    echo "Les variables requises ne sont pas définies (instance, gtmver, gtm_dist, basedir)"
fi

# Importer les routines
echo "Copier les routines"
OLDIFS=$IFS
IFS=$'\n'
for routine in $(cd $basedir/src/Yexpert-M && git ls-files -- \*.m); do
    cp $basedir/src/Yexpert-M/${routine} $basedir/routines
done
echo "Copie des routines terminée"

# Compiler les routines
echo "Compiler les routines"
cd $basedir/routines/$gtmver
for routine in $basedir/routines/*.m; do
    mumps ${routine} >> $basedir/log/compilerRoutines.log 2>&1
done
echo "Compilation des routines terminée"

# Import globals
echo "Importer les globals"
for global in $(cd $basedir/src/Yexpert-M && git ls-files -- \*.zwr); do
    mupip load \"$basedir/src/Yexpert-M/${global}\" >> $basedir/log/importerGloabls.log 2>&1
done
echo "Importation des globals terminée"

# reset IFS
IFS=$OLDIFS



