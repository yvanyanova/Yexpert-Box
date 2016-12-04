#!/usr/bin/env bash
#!----------------------------------------------------------------------------!
#!                                                                            !
#! Yexpert : (your) Système Expert sous Mumps GT.M et GNU/Linux               !
#! Copyright (C) 2001-2015 by Hamid LOUAKED (HL).                             !
#!                                                                            !
#!----------------------------------------------------------------------------!

# Importer les fichiers /www et /node /node_modules depuis Yexpert-EWD

# Vérifier la présence des variables requises
if [[ -z $instance && $gtmver && $gtm_dist && $basedir ]]; then
    echo "Les variables requises ne sont pas définies (instance, gtmver, gtm_dist, basedir)"
fi

# Importer les fichiers /www
cp -rf $basedir/src/Yexpert-EWD/www/* $basedir/www

# Créer le lien YexpertDemo vers ewdjs
# TODO: A supprimer
if [ -h $basedir/ewdjs/www/ewd/YexpertDemo ]; then
    rm $basedir/ewdjs/www/ewd/YexpertDemo
    rm $basedir/ewdjs/node_modules/YexpertDemo.js
    rm $basedir/ewdjs/node_modules/nodeYexpert.js
fi
ln -s $basedir/www/ewd/YexpertDemo $basedir/ewdjs/www/ewd/YexpertDemo
ln -s $basedir/www/node_modules/YexpertDemo.js $basedir/ewdjs/node_modules/YexpertDemo.js
ln -s $basedir/www/node_modules/nodeYexpert.js $basedir/ewdjs/node_modules/nodeYexpert.js





