#!/bin/tcsh
#-------------------------------------------------------------------------#
#                                                                         #
#   OS : Linux - Debian 5 (Lenny) ou 6 (Squeeze)                          #
#   Description : gw est un programme permettant de gerer des serveurs.   #
#                                                                         #
#-------------------------------------------------------------------------#

# !!! Debug !!!
#set echo
#set verbose
# !!! TODO !!!
# Mettre un usage pour chaque mauvaise utilisation (mieux que "Attention, il manque un parametre")

# Infos système

set HOSTNAME=`hostname | awk -F'.' '{print $1}'`
set OS=`cat /etc/issue | cut --delimiter='\' -f 1`
set OSMAINVERSION=`cat /etc/issue | cut --delimiter='\' -f 1 | cut --delimiter=' ' -f 3 | cut --delimiter='.' -f 1`

switch ($OSMAINVERSION)
	case 5:
		set OS="$OS Lenny"
	breaksw
	case 6:
		set OS="$OS Squeeze"
	breaksw
	case 7:
		set OS ="$OS Wheezy"
	breaksw
endsw


set OSNAME=`uname -a`
set PLATEFORME=`uname -i`
set IP=`/sbin/ifconfig | grep "inet " | awk '{print $2}' | awk -F : '{print $2}' | grep -v 127`
set USERID=`id -g`
set USER=`/usr/bin/whoami`

# Divers

set WEBMASTER=localhost@localhost
set EDITOR=jed
set LOCK=/var/lock/gw
set MKPASSWD=/usr/local/bin/mkpasswd

#
# Variables de gestion du temps
#

set HEUREDUMP=`date '+%H-%M-%S'`
set DATETIME=`date '+%d/%m/%y %H:%M:%S'`
set DATE=`date '+%y-%m-%d'`
set DATPASS=`date '+%d%m'`
set LADATE=`date | awk '{printf("%s%s%02s",$3,$2,$(NF)-2000)}'`
set LEMOIS=`date|awk '{printf("%s%02s",$2,$(NF)-1900)}'`
set HEURE=`date '+%T'`

#
# Variables de gestion du GW
#
set FICHIERCONFGW=/etc/gw.conf
set GWBIN=/usr/local/bin/gw
set GWLOG=/var/log/gw.log

#
# Variables de gestion des serveurs MySQL
# On defnit certaines options en fonction du serveur
#
set MYSQLLOGDIR=/var/log/mysql
set DIRBASEMYSQL=/etc/mysql
set DIREXPORTMYSQL=/var/export-mysql
set DIRREPLICATEMYSQL=/var/replicate-mysql
set MYSQLDIR=/etc/init.d/mysql
set MYSQLBIN=/usr/bin
set MYSQLPASSWD=motdepasse
set PORT=3307
set SERVEURMYSQL=localhost

#
# Variables de gestion des serveurs Postgres
#
set POSTGRESDIR=/etc/init.d/postgresql
set DIRBASEPGSQL=/data/postgres
set DIREXPORTPGSQL=/var/export-postgres
set PGSQLPASSWD=motdepasse

#
# Variables de gestion des serveurs Apache
#
set WEBDIR=/etc/init.d/apache2
set WEBLOGDIR=/var/log/apache2

#
# Variables de gestion des serveur FTP
#
set FTPDIR=/etc/init.d/vsftpd
set FTPLOGDIR=/var/log/vsftpd.log
set FTPCONFDIR=/etc/vsftpd.conf
set FTPUSERDBDIR=/etc/vsftpd-login

#
# Variable de gestion des serveurs d'impression
#
set PRINTDIR=/opt/serveurImpression


#
# Gestion du log de gw
#
set DEBUTLOG="[$DATETIME] [$HOSTNAME] [$USER]"
if ($USER == "root") then
	echo "$DEBUTLOG gw $1 $2 $3 $4 $5 $6 $7 $8 $9" >> $GWLOG
endif

# Gestion de $COM
if ($#argv < 1) then
	set COM=default
	set COM2="vide"
	set COM3="vide"
else
   if ($#argv < 2) then
        set COM=$1
	set COM2="vide"
	set COM3="vide"
   else
        if ($#argv < 3) then
           set COM=$1
	   set COM2=$2
	   set COM3="vide"
	else
	   set COM=$1
	   set COM2="$2"
	   set COM3="$3"
	endif
   endif
endif


switch ($COM)

#--------------------------------#
#   Demarrer un serveur Apache   #
#--------------------------------#

case apacheStart:              Demarre un serveur apache

	# on démarre apache2
	$WEBDIR start
	# Message d'information
	sleep 1
	echo
	echo "Processus Apache2"
	echo "-----------------"
	set COMPTEGREP=`ps -ef | grep apache2 | grep -v grep | wc -l`
	if ($COMPTEGREP > 0) then
		ps -ef | grep apache2 | grep -v grep
	else
		echo "Aucun processus apache2"
	endif
	echo
	echo "Extrait du fichier error.log d'apache"
	echo "-------------------------------------"
	tail -6 $WEBLOGDIR/error.log

	echo
	echo "Le serveur Apache est démarré"
	echo
breaksw


#-------------------------------#
#   Arreter un serveur Apache   #
#-------------------------------#

case apacheStop:               Arrete un serveur apache

	# on stoppe apache2
	$WEBDIR stop

	# Message d'information
	sleep 1
	echo
	echo "Processus Apache2"
	echo "-----------------"
	set COMPTEGREP = `ps -ef | grep apache2 | grep -v grep | wc -l`
	if ($COMPTEGREP > 0) then
		ps -ef | grep apache2 | grep -v grep
	else
		echo "Aucun processus apache2"
	endif
	echo
	echo "Extrait du fichier error.log d'apache"
	echo "-------------------------------------"
	tail -6 $WEBLOGDIR/error.log

	echo
	echo "Le serveur Apache est arrêté"
	echo
breaksw

#--------------------------------------#
#   Rechargement d'un serveur Apache   #
#--------------------------------------#

case apacheReload:             Recharge la configuration du serveur apache

	# on recharge la config apache2
	$WEBDIR reload

	# Message d'information
	sleep 1
	echo
	echo "Processus Apache2"
	echo "-----------------"
	set COMPTEGREP = `ps -ef | grep apache2 | grep -v grep | wc -l`
	if ($COMPTEGREP > 0) then
		ps -ef | grep apache2 | grep -v grep
	else
		echo "Aucun processus apache2"
	endif
	echo
	echo "Extrait du fichier error.log d'apache"
	echo "-------------------------------------"

	tail -6 $WEBLOGDIR/error.log

	echo
	echo "La configuration du serveur Apache est rechargée"
	echo
breaksw

#-------------------------------------#
#   Redémarrage d'un serveur Apache   #
#-------------------------------------#

case apacheRestart:            Redemarre un serveur apache

	# On arrete et on redemarre
	$GWBIN apacheStop
	sleep 10
	$GWBIN apacheStart
breaksw


#----------------------------#
#   Liste des virtualhosts   #
#----------------------------#

case apacheVhosts:             Lister tous les sites virtuels heberges sur le serveur

	# Affichage du resultat
	echo
	echo "Les sites virtuels bases sur les noms"
	echo "-------------------------------------"
	echo
	apache2ctl -S
breaksw


#------------------------------------------------------#
#   Faire une sauvegarde d'une Base de Donnees Mysql   #
#------------------------------------------------------#

case mysqlDump:                <base> Dump de la base MySQL

	# Si il y bien un parametre, on fait le dump de la base passe en argument
	if ($2 != "") then

		echo "Lancement du dump de la base $2"
		/bin/mkdir -p $DIREXPORTMYSQL/$2
		/bin/chown -R mysql:mysql $DIREXPORTMYSQL

		# Dump + desactive les logs binaires
		echo "SET SQL_LOG_BIN=0;" > $DIREXPORTMYSQL/$2/$2.sql.$DATE.$HEUREDUMP
		$MYSQLBIN/mysqldump -h $SERVEURMYSQL --port=$PORT --user=root --password=$MYSQLPASSWD $2 >> $DIREXPORTMYSQL/$2/$2.sql.$DATE.$HEUREDUMP
		gzip -f -9 $DIREXPORTMYSQL/$2/$2.sql.$DATE.$HEUREDUMP
		echo "Dump de la base $2 ok, le fichier est disponible ici :"
		echo $DIREXPORTMYSQL/$2/$2.sql.$DATE.$HEUREDUMP.gz

	else
        # Si il n'y a pas de parametre, on dump toutes les bases que l'on trouve
		echo "Lancement du dump des bases"
        chown -R mysql:mysql $DIREXPORTMYSQL

        $MYSQLBIN/mysqldump --all-databases -h $SERVEURMYSQL --port=$PORT --user=root --password=$MYSQLPASSWD >> $DIREXPORTMYSQL/alldb.sql.$DATE.$HEUREDUMP
        gzip -f -9 $DIREXPORTMYSQL/alldb.sql.$DATE.$HEUREDUMP
        echo "Dump des bases ok, le fichier est disponible ici :"
        echo $DIREXPORTMYSQL/alldb.sql.$DATE.$HEUREDUMP.gz
	endif
breaksw


#-------------------------------------------------#
#   Recharger la configuration du serveur MySQL   #
#-------------------------------------------------#

case mysqlReload:              Recharge la configuration du serveur MySQL

	echo "Rechargement de la configuration :"
	$MYSQLDIR reload
breaksw


#----------------------------------#
#   Redémarrage du serveur MySQL   #
#----------------------------------#

case mysqlRestart:	          Redemarre le serveur MySQL

	echo
	echo "Redémarrage de MySQL"
	echo "--------------------"
	echo
	$GWBIN mysqlStop
	$GWBIN mysqlStart
breaksw


#--------------------------------#
#   Demarrage du serveur MySQL   #
#--------------------------------#

case mysqlStart:	          Demarrage du serveur MySQL

	echo "Démarrage de MySQL :"
	$MYSQLDIR start
	$GWBIN mysqlRepair
breaksw


#------------------------------------------------#
#   Check et Repair de toutes les tables MySQL   #
#------------------------------------------------#

case mysqlRepair:		  Check et Repair de toutes les bases MySQL

	echo "Check et Repair de toutes les bases MySQL :"
	mysqlcheck --all-databases -h $SERVEURMYSQL --port=$PORT --user=root --password=$MYSQLPASSWD
	mysqlrepair --all-databases -h $SERVEURMYSQL --port=$PORT --user=root --password=$MYSQLPASSWD
breaksw


#----------------------------#
#   Arret du serveur MySQL   #
#----------------------------#

case mysqlStop:		  Arreter le serveur MySQL

	echo "Arrêt de MySQL :"
	$MYSQLDIR stop
breaksw


#----------------------------------------#
#   Recopier une base de donnees MySQL   #
#----------------------------------------#

case mysqlCopie:               <basSource> <baseCible> Copie d une base vers une autre base

	if ($2 == "" || $3 == "") then
		# Message d'erreur
		echo "Attention, il manque un parametre"
		exit 1
	endif

	echo "Dump de la base source : $2"
	$MYSQLBIN/mysqldump --port=$PORT --user=root --password=$MYSQLPASSWD $2 >$DIREXPORTMYSQL.sql
	echo "Début de la copie"
	echo "Suppression de la base cible : $3"
	$MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="DROP DATABASE $3;"
	echo "Création de la base cible : $3"
	$MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="CREATE DATABASE $3;"
	echo "Envoie des donnees de $COM2 vers $COM3"
	$MYSQLBIN/mysql -h $SERVEURMYSQL $3 -f --port=$PORT -u root --password=$MYSQLPASSWD --exec="source $DIREXPORTMYSQL.sql"
	echo "Fin de la copie"
breaksw


#---------------------------------------------#
#   Se connecter à une base de donnees MySQL  #
#---------------------------------------------#

case mysqlConnect:             <nom-serveur> Se connecter a un serveur mysql en root

	# On verifie la presence du nom du serveur
	if ($2 == "") then
		# Message d'erreur
		echo "Attention, il manque un parametre"
		echo "Usage : gw mysqlConnect <nom-serveur> - Exemple : gw mysqlConnect mysqlserv"
		exit 1
	endif

	$MYSQLBIN/mysql -h $2 -u root --password=$MYSQLPASSWD --port=$PORT
breaksw


#--------------------------------------------------------------------------#
#   Changer le mot de passe d'un utilisateur d'une base de donnees MySQL   #
#--------------------------------------------------------------------------#

case mysqlPassword:            <utilisateur> <mot de passe>  Changer un mot de passe utilisateur de la base de donnees

	# Si il n'y a pas de parametre
	if ($2 == "" || $3 == "") then
		echo "Attention, il manque un parametre"
		echo "Appel : gw mysqlPassword <utilisateur> <mot de passe>"
		exit 1
	endif

	# creation de la requete SQL
	echo "USE mysql ; UPDATE user SET password=PASSWORD('$3') WHERE user='$2' ; FLUSH PRIVILEGES;"  >/tmp/Password$2.sql
	echo    "On lance : USE mysql ; UPDATE user SET password=PASSWORD('$3') WHERE user='$2' ; FLUSH PRIVILEGES;"
	$MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="source /tmp/Password$2.sql"
breaksw

#-----------------------------#
#   Supprime une base MySQL   #
#-----------------------------#

case mysqlDelete:              <base> Supprime une base MySQL

	# Si il n'y a pas de parametre
	if ($2 == "") then
		echo "Attention, il manque un parametre"
		exit 1
	endif

	# dump de la base et sauvegarde
	$GWBIN mysqlDump $2
	mkdir -p $DIREXPORTMYSQL/archive
	mv $DIREXPORTMYSQL/$2.sql.$DATE.gz $DIREXPORTMYSQL/archive
	echo
	echo "Un dump de la base $2 est sauvegarde dans le fichier : $DIREXPORTMYSQL/archive/$2.sql.$DATE.gz"

	# Suppression de la base
	echo "Suppression de la base : $2"
	$MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="DROP DATABASE $2;"

	echo "Supression des sauvegardes ..."
	/bin/rm -Rf $DIRBASEMYSQL/$2
	/bin/rm -Rf $DIREXPORTMYSQL

	echo "Rechargement de la table des privileges ..."
	$MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="FLUSH PRIVILEGES;"

	echo "done"
breaksw


#-----------------------------------#
#   Restauration d'une base MySQL   #
#-----------------------------------#

case mysqlRestaure:            <base> <dumpSQL.gz> Restaure une base de donnees a partir du fichier dumpSQL au format .gz

	# Si il n'y a pas de parametre
	if ($2 == "" || $3 == "") then
		echo "Attention, il manque un parametre"
		exit 1
	endif

	# Si le fichier Dump existe bien
	if (-f $3) then

		# On restaure
		echo "Debut de la restauration :"
		echo "Suppression de la base $2"
		$MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="DROP DATABASE $2;"
		echo "Creation de la base $2"
		$MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="CREATE DATABASE $2;"
		echo "Restauration de la base $2 a partir du fichier $3"
	   	/bin/gunzip < $3 | $MYSQLBIN/mysql --port=$PORT -h $SERVEURMYSQL $2 -f -u root --password=$MYSQLPASSWD
		echo "Fin de la restauration"

	else
		# On indique que le fichier n'existe pas
		echo "le fichier $3 n'existe pas"
		exit 1
	endif
breaksw


#------------------------------------#
#   Création d'une base de données   #
#------------------------------------#

case mysqlCreer:	          <base> [dev password] [vis password] Crée une base de données avec les utilisateurs appropriés

	# Si il n'y a pas de paramètre
	if ($2 == "") then
		echo "Attention, il manque le nom de la base"
		exit 1
	endif

	# On crée la base de donnée
	echo "Creation de la base de donnees $2 :"
	$MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="CREATE DATABASE $2;"

	echo "Fin de la création de la base de donnees"
breaksw


#--------------------------------#
#   Liste des bases postgres     #
#--------------------------------#

case postgresListeBases:       Liste toutes les bases postgres

	echo "Liste de toutes les bases de postgres"

    # Recuperation de toutes les bases de postgres
    su - postgres -c "/usr/bin/psql -l" > /tmp/listeBases
    #essai : cat /tmp/listeBases | tail -n +4 | awk -F ' ' '{print $1}' | grep -E '^[a-zA-Z]'
    cat /tmp/listeBases | awk '{ print $1}' | grep -E '^[a-z]' | grep -vE '^-|^List|^Name|^template'
    #OLD : cat /tmp/listeBases | tail -n +4 | grep -v \( | grep \| |awk -F ' ' '{print $1}'
breaksw


#---------------------------------------#
#   Dump de toutes les bases postgres   #
#---------------------------------------#

case postgresDumpAll:          Dump de toutes les bases postgres

    echo "Dumps de toutes les bases de postgresql"
    # Recuperation de toutes les bases de postgresql
    su - postgres -c "/usr/bin/psql -l" > /tmp/listeBases
    #essai : set BASES=`cat /tmp/listeBases | tail -n +4 | awk -F ' ' '{print $1}' | grep -E '^[a-zA-Z]'`
    #OLD : set BASES=`cat /tmp/listeBases | tail -n +4 | grep -v \( | grep \| |awk -F ' ' '{print $1}'`
    set BASES=`cat /tmp/listeBases | awk '{ print $1}' | grep -E '^[a-z]' | grep -vE '^-|^List|^Name|^template'`
    # On parcours l'ensemble des bases et on fait le dump
    foreach BASE ($BASES)
        $GWBIN postgresDump $BASE
    end
breaksw


#------------------------------#
#   Dump de la base postgres   #
#------------------------------#

case postgresDump:             <base> Dump de la base postgres

        # Si il n'y a pas de paramere
        if ($2 == "") then
                echo "Attention, il manque le nom de la base"
                echo ""
                $GWBIN postgresListeBases
                echo ""
                exit 1
        endif

        mkdir -p $DIREXPORTPGSQL/$2
        chown -R postgres $DIREXPORTPGSQL/$2
        set BACKUP="$DIREXPORTPGSQL/$2/$2.$DATE.$HEUREDUMP.backup"
        echo "Dump de la base $2 en $BACKUP"
        su - postgres -c "/usr/bin/pg_dump -i -F c -b -f $BACKUP $2"
        echo "compression du dump"
        cd $DIREXPORTPGSQL/$2/
        tar cfvz $2.$DATE.$HEUREDUMP.backup.tar.gz $2.$DATE.$HEUREDUMP.backup
        rm -f $2.$DATE.$HEUREDUMP.backup
breaksw


#----------------------------------------#
#   Liste des dumps des bases postgres   #
#----------------------------------------#

case postgresListeDump:        Liste tous les dumps disponibles

        set BASES=`ls -F $DIREXPORTPGSQL | grep "/" | sed -e "s%/%%"`
        foreach BASE ($BASES)
            echo "Dumps de la base : $BASE"
            echo "-----------------"
            set LISTE=`ls -1 $DIREXPORTPGSQL/$BASE`
            foreach DUMP ($LISTE)
                echo "$DIREXPORTPGSQL/$BASE/$DUMP"
            end
			echo ""
        end
breaksw

#--------------------------------------#
#   Restauration d'une base postgres   #
#--------------------------------------#

case postgresRestaure:         <base> <dumpSQL.tar.gz> Restaure une base de donnees a partir du fichier dumpSQL au format tar.gz
        # Si il n'y a pas de parametre
        if ($2 == "" || $3 == "") then
            echo "Attention, il manque un parametre"
            exit 1
        endif
        # Si le fichier Dump existe bien
        if (-f $3) then
            # On restaure
            echo "Restauration de la base $2 a partir du fichier $3"
            cp $3 /tmp/backup.tar.gz
            cd /tmp/
            /bin/gunzip backup.tar.gz
            set DUMP=`/bin/tar -tf backup.tar`
            /bin/tar -xf backup.tar
            su - postgres -c "pg_restore -c -d $2 /tmp/$DUMP"
            echo "Fin de la restauration"
            echo ""
            echo "nettoyage fichier tmp"
            /bin/rm /tmp/backup.tar
            /bin/rm $DUMP
			echo ""
        else
            # On indique que le fichier n'existe pas
            echo "le fichier $3 n'existe pas"
            exit 1
        endif
breaksw

#----------------------------------------------------#
#   Recharger la configuration du serveur postgres   #
#----------------------------------------------------#

case postgresReload:           Recharge la configuration du serveur postgres

	echo "Rechargement de la configuration :"
	$POSTGRESDIR reload
breaksw


#-------------------------------------#
#   Redémarrage du serveur postgres   #
#-------------------------------------#

case postgresRestart:	  Redemarre le serveur postgres

	echo
	echo "Redémarrage de postgres"
	echo "-----------------------"
	echo
	$GWBIN postgresStop
	$GWBIN postgresStart
breaksw


#-----------------------------------#
#   Demarrage du serveur postgres   #
#-----------------------------------#

case postgresStart:	          Demarrage du serveur postgres

	echo "Démarrage de postgres :"
	$POSTGRESDIR start
breaksw


#-------------------------------#
#   Arret du serveur postgres   #
#-------------------------------#

case postgresStop:		  Arreter le serveur postgres

	echo "Arrêt de postgres :"
	$POSTGRESDIR stop
breaksw


#--------------------------------#
#   Demarrage d'un serveur FTP   #
#--------------------------------#

case ftpStart:                 Demarrer le serveur FTP

	# on recharge la config vsftpd
	$FTPDIR start

	# Message d'information
	sleep 1
	echo
	echo "Processus vsftpd"
	echo "-----------------"
	set COMPTEGREP = `ps -ef | grep vsftpd | grep -v grep | wc -l`
	if ($COMPTEGREP > 0) then
		ps -ef | grep vsftpd | grep -v grep
	else
		echo "Aucun processus vsftpd"
	endif
	echo
	echo "Extrait du fichier de log de vsftpd"
	echo "-------------------------------------"

	tail -6 $FTPLOGDIR

	echo
	echo "Le serveur vsftpd est démarré"
	echo
breaksw


#-----------------------------#
#   Arret  d'un serveur FTP   #
#-----------------------------#

case ftpStop                   Arrete le serveur FTP

	# on recharge la config vsftpd
	$FTPDIR stop

	# Message d'information
	sleep 1
	echo
	echo "Processus vsftpd"
	echo "-----------------"
	set COMPTEGREP = `ps -ef | grep vsftpd | grep -v grep | wc -l`
	if ($COMPTEGREP > 0) then
		ps -ef | grep vsftpd | grep -v grep
	else
		echo "Aucun processus vsftpd"
	endif
	echo
	echo "Extrait du fichier de log de vsftpd"
	echo "-------------------------------------"

	tail -6 $FTPLOGDIR

	echo
	echo "Le serveur vsftpd est arrêté"
	echo
breaksw


#----------------------------------#
#   Redémarrage d'un serveur FTP   #
#----------------------------------#

case ftpRestart:               Redemarrer le serveur FTP

	# On arrete et on redemarre
	$GWBIN ftpStop
	sleep 10
	$GWBIN ftpStart
breaksw


#-----------------------------------------------------#
#   Rechargement de la configuration du serveur FTP   #
#-----------------------------------------------------#

case ftpReload:                Recharge la configuration du serveur FTP

	# on recharge la config vsftpd
	$FTPDIR reload

	# Message d'information
	sleep 1
	echo
	echo "Processus vsftpd"
	echo "-----------------"
	set COMPTEGREP = `ps -ef | grep vsftpd | grep -v grep | wc -l`
	if ($COMPTEGREP > 0) then
		ps -ef | grep vsftpd | grep -v grep
	else
		echo "Aucun processus vsftpd"
	endif
	echo
	echo "Extrait du fichier de log de vsftpd"
	echo "-------------------------------------"

	tail -6 $FTPLOGDIR

	echo
	echo "La configuration du serveur vsftpd est rechargée"
	echo
breaksw

#----------------------------#
#   Infos serveur FTP		 #
#----------------------------#

case ftpInfo:                  Affiche des information sur le serveur FTP

	echo "Voulez-vous afficher quelques stats sur le serveur ftp ?"
	echo "Appuyez sur 'Ctrl+C' pour sortir de cet écran"
	echo
	echo "Validez en tapant oui :"
	set VALIDSTAT=$<
	if ($VALIDSTAT == "oui") then
		watch ps -C vsftpd -o user,pid,stime,cmd
	else
		echo "Entrée non égale à oui, on arrête"
		exit 1
	endif
breaksw


#--------------------------------#
#   Création d'utilisateur FTP   #
#--------------------------------#

case ftpCreer:                 Creer un utilisateur FTP

	# On demande le nom de l'utilisateur
	echo
	echo "Identifiant de l'utilisateur :"
	set USERFTP=$<
	if ($USERFTP == "") then
		echo "Entree vide, donc on arrete"
		exit 1
	else
		echo $USERFTP >> $FTPUSERDBDIR/login.txt
	endif

	# On demande le mot de passe
	echo "Mot de passe :"
	set MDPFTP=$<
	if ($MDPFTP == "") then
		echo "Entree vide, donc on arrete"
		exit 1
	else
		echo $MDPFTP >> $FTPUSERDBDIR/login.txt
	endif

	# On demande la description
	#echo "Description de l'utilisateur :"
	#set DESCRI=$<
	#if ($DESCRI == "") then
		#echo "Entree vide, donc on arrete"
		#exit 1
	#else
		#echo $DESCRI >> /home/toto/test.sh
	#endif

	# On demande le chemin d'acces
	#echo "Chemin d'acces de l'utilisateur :"
	#set CHEM=$<
	#if ($CHEM == "") then
		#echo "Entree vide, donc on arrete"
		#exit 1
	#else
		#echo $CHEM >> /home/toto/test.sh
	#endif

	# Mise à jour de la base de données des utilisateurs
	db4.6_load -T -t hash -f $FTPUSERDBDIR/login.txt $FTPUSERDBDIR/login.db
	chmod 600 $FTPUSERDBDIR/login.*

	echo "Utilisateur "$USERFTP" créé."
breaksw



#--------------------------#
#   Lister les processus   #
#--------------------------#

case ps:                       Lister tous les processus qui sont actifs sur la machine

	# On veut tout les processus inclus dans le script
	if ($2 == "") then
		echo
		# On liste les processus apache
		set NB=`ps -ef | grep apache2 | grep -v grep | wc -l`
		if ($NB != 0) then
			echo "Processus Apache2"
			echo "---------------"
			ps -ef | grep apache2 | grep -v grep
			echo
		endif

		# On liste les processus tomcat
		set NB=`ps -ef | grep tomcat | grep -v grep | wc -l`
		if ($NB != 0) then
			echo "Processus Tomcat"
			echo "----------------"
			ps -ef | grep tomcat | grep -v grep
			echo
		endif

		# On liste les processus MySQL
		set NB=`ps awux | grep mysql | grep -v grep | wc -l`
		if ($NB != 0) then
			echo "Processus MySQL"
			echo "---------------"
			ps awux | grep mysql | grep -v grep
			echo
		endif

		# On liste les processus Postgres
		set NB=`ps awux | grep postgres | grep -v grep | wc -l`
		if ($NB != 0) then
			echo "Processus Postgres"
			echo "------------------"
			ps awux | grep postgres | grep -v grep
			echo
		endif

		# On liste les processus FTP
		set NB=`ps awux | grep vsftpd | grep -v grep | wc -l`
		if ($NB != 0) then
			echo "Processus FTP"
			echo "-------------"
			ps -ef | grep vsftpd | grep -v grep
			echo
		endif

		# On liste les processus de serveurs d'impression
		set NB=`ps -ef | grep PrintManager | grep -v grep | wc -l`
		if ($NB != 0) then
			echo "Processus Serveur d'impression"
			echo "------------------------------"
			ps -ef | grep PrintManager | grep -v grep
			echo
		endif

	# On veut tester un pattern particulier
	else
		echo
		set NB=`ps -ef | grep $2 | grep -v grep | grep -v "gw ps" | wc -l`
		if ($NB != 0) then
			echo "Processus $2"
			echo "---------------"
			ps -ef | grep $2 | grep -v grep | grep -v "gw ps"
			echo
		else
			echo "Aucun processus $2"
		endif
	endif

breaksw

#-----------------------------------------------------#
#   Demarrer des serveurs d'impression de contextes   #
#-----------------------------------------------------#

case serveurImpressionListe:	  Affiche la liste des serveur d'impression disponibles

	#------------------------------------------------
	#Recherche des processus d'impression deja lances
	set PROCESS=`ps awwxx | grep PrintManager | grep -v grep`

	#------------------------------------
	#Usage non conforme ou demande d'aide
	if ( $2 == "-h" || $2 == "-help" || $2 == "--h" || $2 == "--help" ) then
        	#Message d'information sur l'usage du script
	        echo ""
        	echo "Usage :  gw serveurImpressionListe [-h] [-help] [--h] [--help] "
	        echo ""
        	echo "  gw serveurImpressionListe	affiche la liste des serveurs d'impression disponibles"
	        echo ""
        	echo "  -h, -help, --h, --help		affiche ce message"
		exit 1
	else
		if ( $2 != "" ) then
			echo ""
			echo "Erreur : argument invalide"
		        echo ""
		        echo "Usage :  gw serveurImpressionListe [-h] [-help] [--h] [--help] "
	        	exit 1
		endif
	endif
	
	#------------------------------------------------------
	#Enregistre la liste de tous les contextes d'impression
	cd $PRINTDIR/
        set LISTE=`ls -d */|cut -d"/" -f1`
	
	#---------------------
	#Listage des contextes
	foreach CONTEXTE ($LISTE)
		#Le processus du contexte est-il actif ?
                if ( -f "$PRINRDIR/$CONTEXTE/start_impression.sh" ) then
			#Oui, on l'affiche
			echo "$CONTEXTE"
		endif
	end
breaksw

#-----------------------------------------------------#
#   Demarrer des serveurs d'impression de contextes   #
#-----------------------------------------------------#

case serveurImpressionStart:	  Demarrer les serveurs d impression des contextes demandes

	#----------------------
	#Decalage des arguments
	shift
	
	#-----------------------
	#Code d'erreur de sortie
	set EXITCODE=0
	#Recherche des processus d'impression deja lances
	set PROCESS=`ps awwxx | grep PrintManager | grep -v grep`
	#Conversion des arguments en minuscules
	set ARG=`echo $* | tr '[:upper:]' '[:lower:]'`
	
	#------------------------------------
	#Usage non conforme ou demande d'aide
	if ( "$1" == "" || "$1" == "-h" || "$1" == "-help" || "$1" == "--h" || "$1" == "--help" ) then
        #Message d'information sur l'usage du script
        echo ""
        echo "Usage :  gw serveurImpressionstart [-h] [-help] [--h] [--help] [all] [contexte1 ...]"
        echo ""
        echo "  -h, -help, --h, --help  affiche ce message"
        echo ""
        echo "  all                     demarre les serveurs d'impression de tous les"
        echo "                          contextes"
        echo ""
        echo "  contexte1 ...           demarre les serveurs d'impression des contextes"
        echo "                          rentres en parametres"
        exit 1
	endif
	
	#-----------------------------------------------------------
	#Detection de la presence de la presence de l'argument "all"
	if ( "$ARG" == "all" ) then
        #Oui, remplacement automatique des arguments du script par tous les contextes
        cd $PRINTDIR/
        set ARG=`ls -d */|cut -d"/" -f1`
	endif
	
	#------------------------
	#Traitement des contextes
	foreach CONTEXTE ($ARG)
        #Le processus du contexte est-il deja en cours d'execution ?
        if ( `echo "$PROCESS" | grep $CONTEXTE | grep -v grep | grep -v "gw serveurImpressionStart"` == "" ) then
                #Non, on le lance
                if ( -f "$PRINTDIR/$CONTEXTE/start_impression.sh" ) then
                        cd $PRINTDIR/$CONTEXTE/
                       (./start_impression.sh > /var/log/serveurImpression/$CONTEXTE.log) >& /var/log/serveurImpression/$CONTEXTE.out &
                endif
        else
                #Oui, message d'avertissement
                echo "Serveur d'impression du contexte $CONTEXTE deja lance"
                set EXITCODE=`expr $EXITCODE + 1`
                continue
        endif
        sleep 1
        #Le processus est-il correctement execute ?
        if (( `ps awwxx | grep PrintManager | grep $CONTEXTE | grep -v grep | grep -v "gw serveurImpressionStart"` != "" )) then
                #Oui, on valide le lancement
                echo "Processus $CONTEXTE correctement lance"
        else
		#Non, le contexte existe-t-il ?
                if ( -f "/opt/serveurImpression/$CONTEXTE/start_impression.sh" ) then
                	#Non, message d'avertissement car pas de lancement
	                echo "Erreur de lancement du serveur d'impression $CONTEXTE."
	                set EXITCODE=`expr $EXITCODE + 1`
		endif
        endif
	end
	exit $EXITCODE

breaksw

#-----------------------------------------------------#
#   Arreter des serveurs d'impression de contextes    #
#-----------------------------------------------------#

case serveurImpressionStop:	  Arreter les processus des serveurs d impression des contextes demandes

	#Decalage des arguments
	shift
	
	#-----------------------
	#Code d'erreur de sortie
	set EXITCODE=0
	#------------------------------------------------
	#Recherche des processus d'impression deja lances
	set PROCESS=`ps awwxx | grep PrintManager | grep -v grep | grep -v "gw serveurImpressionStop"`

	#--------------------------------------
	#Conversion des arguments en minuscules
	set ARG=`echo $* | tr '[:upper:]' '[:lower:]'`

	#------------------------------------
	#Usage non conforme ou demande d'aide
	if ( $1 == "" || $1 == "-h" || $1 == "-help" || $1 == "--h" || $1 == "--help" ) then
		#Message d'information sur l'usage du script
	        echo ""
        	echo "Usage : gw serveurImpressionStop [-h] [-help] [--h] [--help] [all] [contexte1 ...]"
	        echo ""
	        echo "  -h, -help, --h, --help  affiche ce message"
	        echo ""
	        echo "  all                     stoppe les serveurs d'impression de tous les"
	        echo "                          contextes en cours d'execution"
	        echo ""
	        echo "  contexte1 ...           stoppe les serveurs d'impression des contextes"
	        echo "                          rentres en parametres"
        	exit 1
	endif

	#--------------------------------------------
	#Detection de la presence de l'argument "all"
	if ( "$ARG" == "all" ) then
		#Oui, remplacement automatique de $ARG par tous les contextes et conservation de la donnee du parametre all
	        if ( "$PROCESS" == "" ) then
			echo "Aucun processus a arreter. Fin du script"
			exit $EXITCODE
		else
		        cd  $PRINTDIR/
		        set ARG=`ls -d */|cut -d"/" -f1`
			set ARGALL="1"
		endif
	else
		set ARGALL=""
	endif

	#------------------------------------------------------------------------------
	#Terminaison des processus de serveurs d'impression pour les contextes demandes
	foreach CONTEXTE ($ARG)
		#Le contexte saisi est-il valide ?
                if ( -f "$PRINTDIR/$CONTEXTE/start_impression.sh" ) then
			#Oui, est-il en cours d'execution ?
                	if ( `echo "$PROCESS" | grep $CONTEXTE | grep -v grep | grep -v "gw serveurImpressionStop"` != "") then
				#Oui, arret du process
				kill -9 `echo "$PROCESS"| grep $CONTEXTE | awk -F' ' '{print $1}'`
        		else
				if ( "$ARGALL" == "" ) then
					#Non, il n'y a rien a stopper alors que le serveur etait specifie
					echo "Aucun processus d'impression pour le contexte $CONTEXTE actif. Aucune action a effectuer"
					set EXITCODE=`expr $EXITCODE + 1`
					continue
				else
					#Non mais l'argument all specifiant de rechercher parmi tous les contextes, il est normal
					#de tomber sur un contexte non lance, donc on ignore l'erreur
					continue
				endif
			endif
			#Le processus est-il correctement stoppe ?
		        if ( `ps awwxx | grep PrintManager | grep $CONTEXTE | grep -v grep | grep -v "gw serveurImpressionStop"` == "" ) then
				#Oui, on valide l'arret
				echo "Processus $CONTEXTE correctement arrete"
		        else
				#Non, message d'avertissement
				echo "Erreur d'arret du processus du serveur d'impression $CONTEXTE. Veuillez relancer le script"
				set EXITCODE=`expr $EXITCODE + 1`
		        endif
                else 	if ( "$ARGALL" == "1" ) then
				#Non, cas de l'argument "all" : les contextes en erreur sont ignores
				continue
			else
				#Non, contexte explicitement specifie : on signale l' erreur
				echo "Le contexte $CONTEXTE n'existe pas ou il ne dispose pas de serveur d'impression"
			endif
		endif
	end
	exit $EXITCODE

breaksw

#----------------------------------#
#   Gestion mémoire - processus    #
#----------------------------------#

case appmem:                      _Affiche l'empreinte mémoire d'un ou plusieurs process

	if ($2 == "") then
		echo "Attention, il manque un parametre"
		echo "Usage : gw appmem <processus> - Exemple : gw appmem apache2"
		exit 1
	else
		set SWAPUSED=`ps aux | grep $2 | grep -v grep | grep -v "gw appmem" | awk '{print $5}'`
		set RAMUSED=`ps aux | grep $2 | grep -v grep | grep -v "gw appmem" | awk '{print $6}'`
		set COUNT_PID=`ps -ef | grep $2 | grep -v grep | grep -v "gw appmem" | wc -l`

		if ($COUNT_PID > 0) then
			set SWAP_MEM=0
			set RAM_MEM=0

			foreach RAM ($RAMUSED)
				@ RAM_MEM = $RAM + $RAM_MEM
			end

			foreach VIRT ($SWAPUSED)
				@ SWAP_MEM = $VIRT + $SWAP_MEM
			end

			@ SWAP_MEM = $SWAP_MEM / $COUNT_PID
			@ SWAP_MEM = $SWAP_MEM / 1024

			@ RAM_MEM = $RAM_MEM / 1024
			@ TOTAL_PID = ($RAM_MEM + $SWAP_MEM) / $COUNT_PID

			echo ""
			echo "----- Rapport d'utilisation mémoire de $2 -----"
			echo ""
			echo "Nombre de processus : $COUNT_PID"
			echo "Taille swap utilisé ~= $SWAP_MEM Mo"
			echo "Taille RAM utilisée ~= $RAM_MEM Mo"
			echo "Total RAM + Swap / processus ~= $TOTAL_PID Mo"
			echo ""
		else
			echo "Aucun processus ne correspond à $2"
			exit 1
		endif
	endif
breaksw



#------------------------------------------------#
#   Affichage des infos sur la machine en cours  #
#------------------------------------------------#

case systeme:                     _Infos complètes sur le système

	if ($USER == "root") then
		echo ""
		echo "Configuration système"
		echo "====================="

		if ($PLATEFORME == "i386") then
			set PLATEFORME="32bit"
		else if ($PLATEFORME == "x86_64") then
			set PLATEFORME="64bit"
		else if ($PLATEFORME == "unknown") then
			set PLATEFORME="unknown (peut-être une machine virtuelle ?)"
		endif

		# Infos
		set RAMTOTAL=`vmstat -s -S M | grep 'total memory' | sed 's/total memory/mémoire totale/' | sed 's/M/Mo/'`
		set RAMUTILISE=`vmstat -s -S M | grep 'used memory' | sed 's/used memory/mémoire utilisée/' | sed 's/M/Mo/'`
		set SWAPTOTAL=`vmstat -s -S M | grep 'total swap' | sed 's/total swap/swap total/' | sed 's/M/Mo/'`
		set SWAPUTILISE=`vmstat -s -S M | grep 'used swap' | sed 's/used swap/swap utilisé/' | sed 's/M/Mo/'`
		set NBCPU=`cat /proc/cpuinfo | grep processor | wc -l`
		set CPU=`cat /proc/cpuinfo | grep 'model name' | sed -e 's/:/\n/g' | grep -v model | head -1`
		# TODO : Disque(s) dur modèle, SMART, etc par ex. ?

		echo ""
		echo "Nom de machine : $HOSTNAME"
		echo "Nom de l'OS : $OS"
		echo "Description de l'OS : $OSNAME"
		echo "Platforme matérielle : $PLATEFORME"
		echo "Date & Heure système : $DATETIME"
		echo "Addresse(s) IP : $IP"
		echo "CPU(s) : $NBCPU $CPU"
		echo "Infos disque :"
		df -h | grep -v tmpfs
		echo "Infos RAM et SWAP :"
		echo $RAMTOTAL
		echo $RAMUTILISE
		echo $SWAPTOTAL
		echo $SWAPUTILISE
	else
		echo ""
		echo " ::: Connectez-vous en root :::"
		echo ""
	endif

breaksw



#-------------------------------#
#   Affichage de l'aide de gw   #
#-------------------------------#

case aide:                     Comment utiliser GW ?

      echo "Sur quoi souhaitez-vous de l'aide ?"
      echo " 1 : comment savoir ce que fait une commande de gw ?"
      set REP=$<
      if ($REP == "1") then
		echo
        echo "Comment savoir ce que fait une commande de gw ?"
		echo
		echo "Il vous suffit de taper :"
		echo "  gw maCommande --help ou gw maCommande -h"
		echo
      endif
breaksw


#-----------------------#
#   Commandes annexes   #
#-----------------------#

case annexes:                  Liste complete des commandes

	# Afficahge de l'aide
    if ($2 == "--help" | $2 == "-h") then
		echo
		echo "Pas d'aide disponible"
		echo
		exit 1
	endif

	# Affichage des commandes annexes
	echo
	echo "Commandes de gestion des serveurs"
	echo "---------------------------------"
	echo
	cat $0 | grep -E "^case " | grep -v "_" | sed -e "s/case //" |sort
	echo
	echo "Conventions de syntaxe"
	echo "----------------------"
	echo "[paramètre] : paramètre optionnel"
	echo "<paramètre> : paramètre obligatoire"
	echo
	echo "Commandes annexes"
	echo "-----------------"
	echo
	cat $0 | grep -E "^case " | grep "_" | sed -e "s/case //" |sort
	echo
breaksw


#-----------------------------#
#   Affichage du menu de gw   #
#-----------------------------#

case default:

	clear
	echo "Commandes de gestion des serveurs"
	echo "---------------------------------"
	echo
	# On recupere la configuration en fonction de la machine
	set CONFMACHINE=`cat $FICHIERCONFGW | grep -w $HOSTNAME | awk -F'=' '{print $NF}'`
	set CONFTOUS=`cat $FICHIERCONFGW | grep tous | awk -F'=' '{print $2}'`

	echo "Toutes machines"
	echo "---------------"
	cat $0 | grep -E "^case " | grep -v "_" | sed -e "s/case //" | sed -e "s/:/ /" | grep -v "default" | sort | grep $CONFTOUS
	echo
	echo "Spécifique $HOSTNAME"
	echo "--------------------"
	cat $0 | grep -E "^case " | grep -v "_" | sed -e "s/case //" | sed -e "s/:/ /" | grep -v "default" | sort | grep $CONFMACHINE
	echo
	echo "Conventions de syntaxe"
	echo "----------------------"
	echo "[paramètre] : paramètre optionnel"
	echo "<paramètre> : paramètre obligatoire"
	echo
breaksw
endsw

#-----------------------#
# Conservé pour info	#
#-----------------------#

# Construction d'un mail
#	cat > /tmp/mail.$$ <<FINMAIL
#Mime-version: 1.0
#Content-type: text/plain; charset=iso-8859-1
#Content-transfer-encoding: 8bit
#From: <$WEBMASTER>
#To: localhost@localhost.fr
#Subject: Info redémarrage application SI : $2

#Bonjour, l'application $2 vient d'etre relancee.
#Voici le log d'erreur :

#FINMAIL
