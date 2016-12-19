#!/usr/bin/env bash
#!----------------------------------------------------------------------------!
#!                                                                            !
#! Yexpert : (your) Système Expert sous Mumps GT.M et GNU/Linux               !
#! Copyright (C) 2001-2015 by Hamid LOUAKED (HL).                             !
#!                                                                            !
#!----------------------------------------------------------------------------!

# Script d'installation de Yexpert-JS, EWD.js et autres modules nodejs

# Vérifier la présence des variables requises
if [[ -z $instance && $gtmver && $gtm_dist && $basedir ]]; then
    echo "Les variables requises ne sont pas définies (instance, gtmver, gtm_dist)"
fi

# Définir la version de node
nodever="4.2"

# Définir la variable arch
arch=$(uname -m | tr -d _)

# Exécuter en tant que propriétaire de l'instance
if [[ -z $basedir ]]; then
    echo "La variable requise \$instance n'existe pas"
fi

echo "Installer Yexpert-JS"

# Copier les scripts init.d dans le répertoite scripts de Yexpert
su $instance -c "cp -R config $basedir"

# Télécharger l'installateur dans le répertoire tmp
cd $basedir/tmp

# Installer node.js en utilisant NVM (node version manager) - https://github.com/creationix/nvm
echo "Télécharger l'installateur NVM"
curl -s -k --remote-name -L  https://raw.githubusercontent.com/creationix/nvm/master/install.sh
echo "Téléchargement l'installateur NVM terminé"

# Exécuter install.sh
chmod +x install.sh
su $instance -c "./install.sh"

# Enlever install.sh
rm -f ./install.sh

# Aller à $basedir
cd $basedir

# Installer node $nodever
su $instance -c "source $basedir/.nvm/nvm.sh && nvm install $nodever > /dev/null 2>&1 && nvm alias default $nodever && nvm use default"

# Dire à $basedir/config/env notre nodever
echo "export nodever=$nodever" >> $basedir/config/env

# Dire à nvm d'utiliser la version de node dans .profile et .bash_profile
if [ -s $basedir/.profile ]; then
    echo "" >> $basedir/.profile
    echo "source \$HOME/.nvm/nvm.sh" >> $basedir/.profile
    echo "nvm use $nodever" >> $basedir/.profile
fi

if [ -s $basedir/.bash_profile ]; then
    echo "source \$HOME/.nvm/nvm.sh" >> $basedir/.bash_profile
    echo "nvm use $nodever" >> $basedir/.bash_profile
fi

# Créer les répertoires pour node
su $instance -c "source $basedir/config/env && mkdir $basedir/yexpert-js"

# Créer un script d'installation silencieux pour EWD.js
cat > $basedir/yexpert-js/silent.js << EOF
{
    "silent": true,
    "extras": false
}
EOF

# Mettre les droits corrects
chown $instance:$instance $basedir/yexpert-js/silent.js

# Créer un script d'installation silencieux pour yexpert-term
cat > $basedir/yexpert-js/yexpert-termSilent.js << EOF
{
    "silent": true,
    "extras": true
}
EOF

# Mettre les droits corrects
chown $instance:$instance $basedir/yexpert-js/yexpert-termSilent.js

# Créer un script d'installation silencieux pour yexpert-js
cat > $basedir/yexpert-js/yexpert-jsSilent.js << EOF
{
    "silent": true,
    "extras": true
}
EOF

# Mettre les droits corrects
chown $instance:$instance $basedir/yexpert-js/yexpert-jsSilent.js

# Installer les modules de node requis
cd $basedir/yexpert-js
##echo "1/9 ewdjs"
##su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewdjs >> $basedir/log/installerewdjs.log"
echo "1/20 express"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet express >> $basedir/log/installerExpress.log"
echo "2/20 ewd-qoper8-express"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewd-qoper8-express >> $basedir/log/installerEwd-qoper8-express.log"
echo "3/20 ewd-xpress"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewd-xpress >> $basedir/log/installerEwd-xpress.log"
echo "4/20 ewd-xpress-monitor"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewd-xpress-monitor >> $basedir/log/installerEwd-xpress-monitor.log"
echo "5/20 ewd-qoper8"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewd-qoper8 >> $basedir/log/installerEwd-qoper8.log"
echo "6/20 nodem"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet nodem >> $basedir/log/installerNodem.log"


echo "7/20 babelify"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet babelify >> $basedir/log/installerBabelify.log"
echo "8/20 browserify" # http://doc.progysm.com/doc/browserify
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet -g browserify >> $basedir/log/installerBrowserify.log"
echo "9/20 bootstrap@3"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet bootstrap@3 >> $basedir/log/installerBootstrap@3.log"
echo "10/20 toastr"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet toastr >> $basedir/log/installerToastr.log"
echo "11/20 ewd-client"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewd-client >> $basedir/log/installerEwd-client.log"
echo "12/20 socket.io-client"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet socket.io-client >> $basedir/log/installerSocket.io-client.log"
echo "13/20 jquery"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet jquery >> $basedir/log/installerJquery.log"
echo "14/20 ewd-session"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewd-session >> $basedir/log/installerEwd-session.log"
echo "15/20 yexpert-rpc"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet yexpert-rpc >> $basedir/log/installerYexpert-rpc.log"
echo "16/20 yexpert-gtm"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet yexpert-gtm >> $basedir/log/installerEwd-qoper8-gtm.log"
echo "17/20 ewd-document-store"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewd-document-store >> $basedir/log/installerEwd-document-store.log"
echo "18/20 body-parser"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet body-parser >> $basedir/log/installerBody-parser.log"


echo "19/20 yexpert-js"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet yexpert-js >> $basedir/log/installeryexpert-js.log"
##echo "6/9 ewdliteclient"
##su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewdliteclient >> $basedir/log/installerEwdliteclient.log"
##echo "7/9 ewdrest"
##su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet ewdrest >> $basedir/log/installerEwdrest.log"
echo "20/20 yexpert-term"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet yexpert-term >> $basedir/log/installerYexpert-term.log"
#echo "20/20 node-inspector"
#su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet -g node-inspector >> $basedir/log/installerNode-inspector.log"


echo "../.. ewd-xpress-react"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet -g ewd-xpress-react >> $basedir/log/installerEwd-xpress-react.log"
echo "../.. react-bootstrap"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet -g react-bootstrap >> $basedir/log/installerReact-bootstrap.log"
echo "../.. react-dom"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet -g react-dom >> $basedir/log/installerReact-dom.log"
echo "../.. react-toastr"
su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && npm install --quiet -g react-toastr >> $basedir/log/installerReact-toastr.log"


# Certaines distributions linux installent nodejs non comme exécutable "node" mais comme "nodejs".
# Dans ce cas, vous devez lier manuellement à "node", car de nombreux paquets sont programmés après le node "binaire". Quelque chose de similaire se produit également avec "python2" non lié à "python".
# Dans ce cas, vous pouvez faire un lien symbolique facile. Pour les distributions linux qui installent des binaires de package dans /usr/bin, vous pouvez faire
ln -s /usr/bin/nodejs /usr/bin/node

# Créer le fichier bundle.js requis par l application
echo "Créer le fichier bundle.js requis par l application"
su $instance -c "cd $basedir/yexpert-js/www/yexpert && browserify -t [ babelify ] app.js -o bundle.js"

# ewd-express
echo "Copier les fichiers ewd-express"
#su $instance -c "cp $basedir/yexpert-js/node_modules/ewd-xpress/example/ewd-xpress-gtm.js $basedir/yexpert-js/ewd-xpress.js"
su $instance -c "mkdir $basedir/yexpert-js/www/ewd-xpress-monitor"
su $instance -c "cp $basedir/yexpert-js/node_modules/ewd-xpress-monitor/www/bundle.js $basedir/yexpert-js/www/ewd-xpress-monitor"
su $instance -c "cp $basedir/yexpert-js/node_modules/ewd-xpress-monitor/www/*.html $basedir/yexpert-js/www/ewd-xpress-monitor"
su $instance -c "cp $basedir/yexpert-js/node_modules/ewd-xpress-monitor/www/*.css $basedir/yexpert-js/www/ewd-xpress-monitor"

# Copier mumps$nodever.node_$arch
#su $instance -c "cp $basedir/yexpert-js/node_modules/nodem/lib/mumps"$nodever".node_$arch $basedir/yexpert-js/mumps.node"
#su $instance -c "mv $basedir/yexpert-js/node_modules/nodem/lib/mumps"$nodever".node_$arch $basedir/yexpert-js/node_modules/nodem/lib/mumps.node"

# Copier toutes les routines de yexpert-js
su $instance -c "find $basedir/yexpert-js/node_modules/yexpert-js -name \"*.m\" -type f -exec cp {} $basedir/p/ \;"

# Configurer de GTM C Callin
# avec nodem 0.3.3 le nom de la ci a changé. Déterminer l'utilisation ls -1
calltab=$(ls -1 $basedir/yexpert-js/node_modules/nodem/resources/*.ci)
echo "export GTMCI=$calltab" >> $basedir/config/env
# Ajouter les routines nodem dans gtmroutines
echo "export gtmroutines=\"\${gtmroutines}\"\" \"\$basedir/yexpert-js/node_modules/nodem/src" >> $basedir/config/env

# Ajouter les routines Yexpert-RPC dans gtmroutines
########echo "export gtmroutines=\"\${gtmroutines}\"\" \"\$basedir/yexpert-js/node_modules/Yexpert-RPC/mumps" >> $basedir/config/env
######su $instance -c "cp $basedir/yexpert-js/node_modules/yexpert-rpc/mumps/*.m $basedir/s"

# Créer la configuration ewd.js
cat > $basedir/yexpert-js/node_modules/Yrelay-Config.js << EOF
module.exports = {
  setParams: function() {
    return {
      ssl: true
    };
  }
};
EOF

# Mettre les droits corrects
chown $instance:$instance $basedir/yexpert-js/node_modules/Yrelay-Config.js

# Installer les droits webservice
#echo "Installer les droits webservice"
#su $instance -c "source $basedir/.nvm/nvm.sh && source $basedir/config/env && nvm use $nodever && cd $basedir/yexpert-js && node registerWSClient.js"

# Modifier les scripts init.d pour les rendre compatibles avec $instance
perl -pi -e 's#y-instance#'$instance'#g' $basedir/config/init.d/yexpert-js

# Créer le démarrage de service
# TODO: A supprimer
if [ -h /etc/init.d/${instance}yexpert-js ]; then
    rm /etc/init.d/${instance}yexpert-js
fi
ln -s $basedir/config/init.d/yexpert-js /etc/init.d/${instance}yexpert-js

# Installer le script init
if [[ $debian || -z $RHEL ]]; then
    update-rc.d ${instance}yexpert-js defaults
fi

if [[ $RHEL || -z $debian ]]; then
    chkconfig --add ${instance}yexpert-js
fi

# Add firewall rules
if [[ $RHEL || -z $debian ]]; then
    iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT # EWD.js
    iptables -I INPUT 1 -p tcp --dport 8000 -j ACCEPT # EWD.js Webservices
    iptables -I INPUT 1 -p tcp --dport 8081 -j ACCEPT # EWD Yexpert Term
    iptables -I INPUT 1 -p tcp --dport 8082 -j ACCEPT # Pour test
    iptables -I INPUT 1 -p tcp --dport 3000 -j ACCEPT # Débuggeur node-inspector

    service iptables save
fi

# Démarrer le service
service ${instance}yexpert-js start

echo "Installation EWD.js terminée..."





