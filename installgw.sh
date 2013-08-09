#!/bin/bash
#---------------------------------------------------------------------------#
#                                                                           #
#   OS : Linux - Debian 5 (Lenny) ou 6 (Squeeze)                            #
#   Description : Permet d'installer gw sur différents serveurs simplement  #
#                                                                           #
#---------------------------------------------------------------------------#

# Var de destination de GW
export DESTCONFGW="/etc/gw.conf"
export DESTGWBIN="/usr/local/bin/gw"

# Création au besoin des .shellrc
touch ~/.tcshrc
touch ~/.bashrc

# Install des dépendances si besoin
if [ `dpkg -l | grep -E 'tcsh|rsync' | wc -l` -ne 2 ]
then
	echo "Installation des dépendances (tcsh, rsync) ..."
	echo ""
	apt-get install tcsh rsync
	export NB_TCSHRC=0
else
	export NB_TCSHRC=`cat ~/.tcshrc | grep "alias gw 'tcsh "$DESTGWBIN"'" | wc -l`
fi

echo "Copie du script et du .conf ..."
cp gw.conf $DESTCONFGW
cp gw.sh $DESTGWBIN

export NB_BASHRC=`cat ~/.bashrc | grep "alias gw='tcsh "$DESTGWBIN"'" | wc -l`

#Activation des alias pour les deux shells ...
# Celui par défaut sur le système actuel : bash
if [ $NB_BASHRC -eq 0 ]
then
	sed -i -e '/alias gw/d' ~/.bashrc
	echo "alias gw='tcsh "$DESTGWBIN"'" >> ~/.bashrc
fi

# Celui sur lequel tourne le script et que l'on vient d'installer : tcsh
if [ $NB_TCSHRC -eq 0 ]
then
	sed -i -e '/alias gw/d' ~/.tcshrc
	echo "alias gw 'tcsh "$DESTGWBIN"'" >> ~/.tcshrc
fi

# Mise à jour du shell en cours avec le nouvel alias si besoin
if [[ $NB_BASHRC -eq 0 || $NB_TCSHRC -eq 0 ]]
then
	. ~/.bashrc
	echo ""
	echo "Activation des alias pour les deux shells ..."
	echo ""
	echo "gw est maintenant installé !"
else
	echo "gw a été mis à jour !"
fi

# gw est éxécutable
chmod +x $DESTGWBIN