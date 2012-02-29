# GW

## Qu'est-ce que GW ?
L'idée est de centraliser les commandes d'administration système et de permettre à "n'importe qui" d'effectuer une maintenance d'un ou plusieurs serveurs.

Il ne gère à l'heure actuelle que les services suivants :

* Apache
* Mysql
* Postgresql
* vsftpd

Il comprend aussi différentes fonctions comme _systeme_ qui permet d'afficher un bref résumé de la configuration de la machine

*Il ne demande qu'a être enrichi !*

GW est un simple script tcsh, il dépend donc de ce shell qui a beaucoup de défauts ... mais j'ai bon espoir de le "convertir" en un script Bash voire même Python un jour.

## Installation & configuration
Il vous faut renseigner le _gw.conf_ selon la syntaxe suivante :

	NomDeMachine=\(^service1\|^service2\|^service3\|^service4\)

	ou par exemple :
	
	toto=\(^apache\|^mysql\)

Le fichier installgw.sh va installer les dépendances (le tcsh, donc mais aussi rsync)

A chaque mise à jour du script lui-même ou de sa configuration (_gw.conf_), *relancer installgw.sh*

## Utilisation
Pour un premier coup d'oeil rapide : Lancer gw sans argument et vous obtiendrez la liste des services disponibles sur la machine

Pour utiliser une commande de gw, taper simplement _gw maCommande_

## Notes
Le contenu présent dans ce dépot est publié sous les termes de la [Licence publique générale GNU v3](http://www.gnu.org/licenses/gpl.txt/ "Licence publique générale GNU v3")

Testé sur les Debian Lenny et Squeeze

Ma participation à l'écriture de ce script concerne seulement sa mise à jour pour gérer les distributions Debian (il était autrefois fait pour RedHat) et quelques ajouts de fonctionnalités

L'idée et le crédit pour le code revient à l'equipe SI de l'Université de Rennes 1 qui utilise un dérivé de ce script depuis plus de 10 ans