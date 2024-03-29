#!/bin/tcsh
#-------------------------------------------------------------------------#
#                                                                         #
#   OS : Linux - Debian (a partir de Lenny)                               #
#   Description : gw est un programme permettant de gerer des serveurs.   #
#                                                                         #
#-------------------------------------------------------------------------#

# !!! Debug !!!
#set echo
#set verbose
# !!! TODO !!!
# Mettre un usage pour chaque mauvaise utilisation (mieux que "Attention, il manque un parametre")

# Infos systeme

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
        set OS="$OS Wheezy"
    breaksw
    case 8:
        set OS="$OS Jessie"
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
set DIREXPORTMYSQL=/var/export-mysql/mysql
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
# Variables de gestion de SignServer
#
set SIGNSERVERDIR=/opt/signserver
set SIGNSERVERCONFIGDIR=/opt/conf_signserver/
set SIGNSERVERBIN=$SIGNSERVERDIR/bin/signserver.sh
set SIGNSERVERJAVAHOME=/opt/jdk1.6.0
set JBOSSDIR=/opt/jboss

#
# Variables de gestion des certificats
#
set prefixeAuthority=/opt/keystore/autorite/cacert
set fichierPassphrase=/opt/keystore/user/passphrase
set fichierExport=/opt/keystore/user/export
set directoryCertificatUser=/opt/keystore/user/

#
# Variables de gestion des serveur FTP
#
set FTPDIR=/etc/init.d/vsftpd
set FTPLOGDIR=/var/log/vsftpd.log
set FTPCONFDIR=/etc/vsftpd.conf
set FTPUSERDBDIR=/etc/vsftpd-login

#
# Variables de gestion des serveur Tomcat
#
set USERIDTEST=`/usr/bin/whoami`
set TOMCATSDIR=/opt
set TOMCATBIN=/opt/apache-tomcat-6


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

    # on demarre apache2
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
    echo "Le serveur Apache est demarre"
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
    echo "Le serveur Apache est arrete"
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
    echo "La configuration du serveur Apache est rechargee"
    echo
breaksw

#-------------------------------------#
#   Redemarrage d'un serveur Apache   #
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
    if ($USER == "root") then
        apache2ctl -S
    else
        echo ""
        echo " ::: Connectez-vous en root :::"
        echo ""
    endif

breaksw


#------------------------------------------------------#
#   Faire une sauvegarde d'une Base de Donnees Mysql   #
#------------------------------------------------------#

case mysqlDump:                <base> Dump de la base MySQL

    # Si il y bien un parametre, on fait le dump de la base passe en argument
    if ($2 != "") then

        echo "Lancement du dump de la base $2"
        /bin/mkdir -p $DIREXPORTMYSQL/$2

        # Dump + desactive les logs binaires
        echo "SET SQL_LOG_BIN=0;" > $DIREXPORTMYSQL/$2/$2.sql.$DATE.$HEUREDUMP
        $MYSQLBIN/mysqldump -h $SERVEURMYSQL --port=$PORT --user=root --password=$MYSQLPASSWD $2 >> $DIREXPORTMYSQL/$2/$2.sql.$DATE.$HEUREDUMP
        gzip -f -9 $DIREXPORTMYSQL/$2/$2.sql.$DATE.$HEUREDUMP
        echo "Dump de la base $2 ok, le fichier est disponible ici :"
        echo $DIREXPORTMYSQL/$2/$2.sql.$DATE.$HEUREDUMP.gz

    else
        # Message d'erreur
        echo "Attention, il manque un parametre"
        exit 1
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
#   Redemarrage du serveur MySQL   #
#----------------------------------#

case mysqlRestart:            Redemarre le serveur MySQL

    echo
    echo "Redemarrage de MySQL"
    echo "--------------------"
    echo
    $GWBIN mysqlStop
    $GWBIN mysqlStart
breaksw


#--------------------------------#
#   Demarrage du serveur MySQL   #
#--------------------------------#

case mysqlStart:              Demarrage du serveur MySQL

    echo "Demarrage de MySQL :"
    $MYSQLDIR start
    $GWBIN mysqlRepair
breaksw


#------------------------------------------------#
#   Check et Repair de toutes les tables MySQL   #
#------------------------------------------------#

case mysqlRepair:         Check et Repair de toutes les bases MySQL

    echo "Check et Repair de toutes les bases MySQL :"
    $MYSQLBIN/mysqlcheck --all-databases -h $SERVEURMYSQL --port=$PORT --user=root --password=$MYSQLPASSWD
    $MYSQLBIN/mysqlrepair --all-databases -h $SERVEURMYSQL --port=$PORT --user=root --password=$MYSQLPASSWD
breaksw


#----------------------------#
#   Arret du serveur MySQL   #
#----------------------------#

case mysqlStop:       Arreter le serveur MySQL

    echo "Arret de MySQL :"
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
    echo "Debut de la copie"
    echo "Suppression de la base cible : $3"
    $MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="DROP DATABASE $3;"
    echo "Creation de la base cible : $3"
    $MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="CREATE DATABASE $3;"
    echo "Envoie des donnees de $COM2 vers $COM3"
    $MYSQLBIN/mysql -h $SERVEURMYSQL $3 -f --port=$PORT -u root --password=$MYSQLPASSWD --exec="source $DIREXPORTMYSQL.sql"
    echo "Fin de la copie"
breaksw


#--------------------------------#
#   Liste des bases MySQL        #
#--------------------------------#

case mysqlListeBases:       Liste toutes les bases MySQL

    echo "Liste de toutes les bases de MySQL :"

    $MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="SHOW DATABASES;" > /tmp/listeMysqlBases
    cat /tmp/listeMysqlBases | grep -Ev 'Database|schema|mysql' | xargs -n 1 echo
breaksw


#---------------------------------------#
#   Dump de toutes les bases MySQL      #
#---------------------------------------#

case mysqlDumpAll:       Dumps de toutes les bases de MySQL

    echo "Debut du dumps de toutes les bases de MySQL..."

    $MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="SHOW DATABASES;" > /tmp/listeMysqlBases
    cat /tmp/listeMysqlBases | grep -Ev 'Database|schema|mysql|suivi_dev' | xargs -n 1 $GWBIN mysqlDump

    echo "Fin."
breaksw


#---------------------------------------------#
#   Se connecter a une base de donnees MySQL  #
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
    echo "On lance : USE mysql ; UPDATE user SET password=PASSWORD('$3') WHERE user='$2' ; FLUSH PRIVILEGES;"
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
#   Creation d'une base de donnees   #
#------------------------------------#

case mysqlCreer:              <base> [dev password] [vis password] Cree une base de donnees avec les utilisateurs appropries

    # Si il n'y a pas de parametre
    if ($2 == "") then
        echo "Attention, il manque le nom de la base"
        exit 1
    endif

    # On cree la base de donnee
    echo "Creation de la base de donnees $2 :"
    $MYSQLBIN/mysql -h $SERVEURMYSQL --port=$PORT -u root --password=$MYSQLPASSWD --exec="CREATE DATABASE $2;"

    echo "Fin de la creation de la base de donnees"
breaksw


#--------------------------------#
#   Liste des bases postgres     #
#--------------------------------#

case postgresListeBases:       Liste toutes les bases postgres

    echo "Liste de toutes les bases de postgres"

    # Recuperation de toutes les bases de postgres
    if ($USER == "postgres") then
        /usr/bin/psql -l > /tmp/listeBases
    else
        su - postgres -c "/usr/bin/psql -l" > /tmp/listeBases
        chmod 666 /tmp/listeBases
    endif
    #essai : cat /tmp/listeBases | tail -n +4 | awk -F ' ' '{print $1}' | grep -E '^[a-zA-Z]'
    cat /tmp/listeBases | awk '{ print $1}' | grep -E '^[a-z]' | grep -vE '^-|^Liste|^Nom|^template|^List|^Name'
    rm /tmp/listeBases
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
    set BASES=`cat /tmp/listeBases | awk '{ print $1}' | grep -E '^[a-z]' | grep -vE '^-|^List|^Name|^Liste|^Nom|^template'`
    # On parcours l'ensemble des bases et on fait le dump
    foreach BASE ($BASES)
        $GWBIN postgresDump $BASE
    end
breaksw


#------------------------------#
#   Dump de la base postgres   #
#------------------------------#

case postgresDump:             <base> Dump de la base postgres

    # Si il n'y a pas de parametre
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
#   Redemarrage du serveur postgres   #
#-------------------------------------#

case postgresRestart:     Redemarre le serveur postgres

    echo
    echo "Redemarrage de postgres"
    echo "-----------------------"
    echo
    $GWBIN postgresStop
    $GWBIN postgresStart
breaksw


#-----------------------------------#
#   Demarrage du serveur postgres   #
#-----------------------------------#

case postgresStart:           Demarrage du serveur postgres

    echo "Demarrage de postgres :"
    $POSTGRESDIR start
breaksw


#-------------------------------#
#   Arret du serveur postgres   #
#-------------------------------#

case postgresStop:        Arreter le serveur postgres

    echo "Arret de postgres :"
    $POSTGRESDIR stop
breaksw


#-------------------------------#
#     Arret de SignServer       #
#-------------------------------#

case signServerStop:                            Arreter le serveur SignServer

    echo "Arret de SignServer :"
breaksw


#-------------------------------#
#    Reload de SignServer       #
#-------------------------------#

case signServerReload:                        Recharger les config SignServer

    echo "Reload des workers de SignServer :"
    # environnement JAVA
    setenv JAVA_HOME $SIGNSERVERJAVAHOME
    setenv PATH $PATH":$JAVA_HOME/bin"
    # environnement signserver
    setenv APPSRV_HOME $JBOSSDIR
    setenv SIGNSERVER_HOME $SIGNSERVERDIR
    setenv SIGNSERVER_NODEID node1

    set LISTE=`$SIGNSERVERBIN getconfig global | awk -F'WORKER' '{print $2}' | awk -F'.' '{print $1}' | sort -bu`
    foreach WORKER ($LISTE)
        echo ""
        echo "chargement du WORKER numero $WORKER"
        echo ""
        $SIGNSERVERBIN reload $WORKER
    end
breaksw


#---------------------------------------#
#    Suppression worker de SignServer   #
#---------------------------------------#

case signServerRemove:                        <worker> [oui] supprimer un worker + rechargement si OUI

    echo "Suppression du    worker $2 de SignServer :"
    # environnement JAVA
    setenv JAVA_HOME $SIGNSERVERJAVAHOME
    setenv PATH $PATH":$JAVA_HOME/bin"
    # environnement signserver
    setenv APPSRV_HOME $JBOSSDIR
    setenv SIGNSERVER_HOME $SIGNSERVERDIR
    setenv SIGNSERVER_NODEID node1
    $SIGNSERVERBIN removeworker $2

    echo "suppression configuration du worker"
    set CONFSIGNSERVER="$SIGNSERVERCONFIGDIR/$2.properties"
    /bin/rm $CONFSIGNSERVER

    if ($3 == 'oui') then
         $GWBIN signServerReload
    endif
breaksw


#---------------------------------------#
#    Liste les workers de SignServer    #
#---------------------------------------#

case signServerList:                            liste des workers

    # environnement JAVA
    setenv JAVA_HOME $SIGNSERVERJAVAHOME
    setenv PATH $PATH":$JAVA_HOME/bin"
    # environnement signserver
    setenv APPSRV_HOME $JBOSSDIR
    setenv SIGNSERVER_HOME $SIGNSERVERDIR
    setenv SIGNSERVER_NODEID node1
    $SIGNSERVERBIN getstatus complete all | grep NAME
breaksw


#--------------------------------------#
#    Charger une config de SignServer  #
#--------------------------------------#

case signServerChargeConfig:        <configuration> Recharger une config SignServer

    # environnement JAVA
    setenv JAVA_HOME $SIGNSERVERJAVAHOME
    setenv PATH $PATH":$JAVA_HOME/bin"
    # environnement signserver
    setenv APPSRV_HOME $JBOSSDIR
    setenv SIGNSERVER_HOME $SIGNSERVERDIR
    setenv SIGNSERVER_NODEID node1
    echo ""
    echo "chargement de la configuration    $2"
    $SIGNSERVERBIN setproperties $2
breaksw


#-------------------------------#
#    Creation des certificats   #
#-------------------------------#

case _certificatCreate:                     creer les certificats

    $GWBIN _certificatCreate
    if ($? == 10) then
        $GWBIN certificatCharge
    endif
    if ($? == 0) then
        $GWBIN signServerReload
    endif
breaksw


case certificatCreate:                        creer les certificats

    echo "--------------------------"
    echo "Creation des certificats :"

    set LISTE=`find $directoryCertificatUser -name "*.spool"`
    foreach CERTIF ($LISTE)
        set RACINE=`echo $CERTIF | awk -F'.spool' '{print $1}'`
        echo ""
        echo "creation du certificat en attente $RACINE"
        echo ""

        openssl genrsa -des3 -out $RACINE.key -passout file:$fichierPassphrase
        if ($? == 0) then
            openssl req -batch -new -key $RACINE.key -out $RACINE.csr -config $CERTIF
            if ($? == 0) then
                openssl x509 -req -days 3650 -in $RACINE.csr -CA $prefixeAuthority.pem -CAkey $prefixeAuthority.key -set_serial 01 -out $RACINE.pem -passin file:$fichierPassphrase
                if ($? == 0) then
                    openssl pkcs12 -export -inkey $RACINE.key -in $RACINE.pem -name signature -out $RACINE.p12 -passin file:$fichierPassphrase -password file:$fichierExport
                    if ($? == 0) then
                        mv $CERTIF $RACINE.config
                        echo "OK $RACINE.config"
                        endif
                    endif
                endif
            endif
        endif
    end
    exit 10
breaksw


#---------------------------------#
#    Suppression de certificats   #
#---------------------------------#

case certificatDelete:        <Application> <ID>    supprime le certificat

    set DIRCERTIF="$directoryCertificatUser/$2/$3"
    set CERTIF="$directoryCertificatUser/$2/$3/$3.p12"
    set CONFSIGNSERVER="$SIGNSERVERCONFIGDIR/$2_$3_signer.properties"
    set NAMEWORKER="$2_$3_signer"
    if (-f $CERTIF) then
        echo "suppression de $DIRCERTIF"
        /bin/rm $DIRCERTIF/*
        /bin/rmdir $DIRCERTIF
    else
        echo "$DIRCERTIF n'existe pas"
    endif
    if (-f $CONFSIGNSERVER) then
        echo "une configuration de signserver est disponible"
        echo "on supprime aussi le worker signserver"
        $GWBIN signServerRemove $NAMEWORKER oui
    endif
breaksw


#--------------------------------------#
#    Verif. existance de certificats   #
#--------------------------------------#

case certificatExiste:        <Application> <ID>    verifie si le certificat existe

    set CERTIF="$directoryCertificatUser/$2/$3/$3.p12"
    set SPOOLCERTIF="$directoryCertificatUser/$2/$3/$3.spool"
    set CONFSIGNSERVER="$SIGNSERVERCONFIGDIR/$2_$3_signer.properties"
    set NAMEWORKER="$2_$3_signer"
    if (-f $CERTIF) then
        echo "OK"
    else
        if (-f $SPOOLCERTIF) then
            echo "SPOOL"
        else
            echo "NOK"
        endif
    endif
breaksw


#--------------------------------------#
#    Chargement de certificats         #
#--------------------------------------#

case certificatCharge:        charger les certificats dans SignServer

    echo "--------------------------------------------"
    echo "Chargement des certificats dans SignServer :"

    set LISTE=`find $directoryCertificatUser -name "*.properties"`
    foreach CERTIF ($LISTE)
        set FICHIER=`basename $CERTIF`
        echo ""
        echo "Chargement du certificat $FICHIER"
        echo ""
        mv $CERTIF $SIGNSERVERCONFIGDIR$FICHIER
        $GWBIN signServerChargeConfig $SIGNSERVERCONFIGDIR$FICHIER
    end
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
    echo "Le serveur vsftpd est demarre"
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
    echo "Le serveur vsftpd est arrete"
    echo
breaksw


#----------------------------------#
#   Redemarrage d'un serveur FTP   #
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
    echo "La configuration du serveur vsftpd est rechargee"
    echo
breaksw

#----------------------------#
#   Infos serveur FTP        #
#----------------------------#

case ftpInfo:                  Affiche des information sur le serveur FTP

    echo "Voulez-vous afficher quelques stats sur le serveur ftp ?"
    echo "Appuyez sur 'Ctrl+C' pour sortir de cet ecran"
    echo
    echo "Validez en tapant oui :"
    set VALIDSTAT=$<
    if ($VALIDSTAT == "oui") then
        watch ps -C vsftpd -o user,pid,stime,cmd
    else
        echo "Entree non egale a oui, on arrete"
        exit 1
    endif
breaksw


#--------------------------------#
#   Creation d'utilisateur FTP   #
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

    # Mise a jour de la base de donnees des utilisateurs
    db4.6_load -T -t hash -f $FTPUSERDBDIR/login.txt $FTPUSERDBDIR/login.db
    chmod 600 $FTPUSERDBDIR/login.*

    echo "Utilisateur "$USERFTP" cree."
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


#----------------------------------#
#   Demmarer une instance tomcat   #
#----------------------------------#

case tomcatStart:         <nomApplication>  demarre une instance de tomcat
        # On test si il a bien un nom d'application
        if($2 == "") then
                echo
                echo "ATTENTION : Il faut donner le nom de l'instance en parametre"
                echo "liste des instances disponibles sur la machine :"
                echo
                ls  $TOMCATSDIR | grep -v apache | grep tomcat | awk -F@ '{print $1}'
                echo
                exit 1
        else if("$COM2" == "all") then
            set CONTEXTES=`ls  $TOMCATSDIR | grep -v apache | grep tomcat | awk -F@ '{print $1}'`
            foreach CONTEXTE ($CONTEXTES)
                $GWBIN $COM $CONTEXTE
            end
        else
                # On verifie la presence du dossier de l'instance
                if (! -e $TOMCATSDIR/$2) then
                        echo "Cette instance est introuvable."
                        exit 1
                endif
                # On verifie la presence de la config de l'instance
                if (! -f $TOMCATSDIR/$2/config.properties) then
                        echo "la configuration de cette instance est introuvable."
                        echo "le fichier $TOMCATSDIR/$2/config.properties n'est pas present"
                        exit 1
                endif


                # On test si on est bien Tomcat ou pas
                if ($USERIDTEST != "tomcat6") then
                        chown -R tomcat6:tomcat6 $TOMCATSDIR/$2/*
                        su tomcat6 -c "$GWBIN tomcatStart $2"
                else
                        # On verifie si l'application n'a pas deja ete lancee
                        set PID=`ps awwux | grep java | grep tomcat | grep $2 | awk -F' ' '{print $2}'`
                        if ("$PID" != "") then
                                # On indique que l'instance est deja lancee
                                echo
                                echo "Pocessus   : $PID <==> $2"
                                echo "Erreur     : cette instance semble deja demarree (ou plantee)"
                                echo "Solution   : gw tomcatStop $2"
                                echo
                                exit 1
                  else
                                # On vide le work et le temp par securite
                                rm -Rf $TOMCATSDIR/$2/work/* > & /dev/null
                                rm -Rf $TOMCATSDIR/$2/temp/* > & /dev/null

                                # On definit les variables
                                setenv CATALINA_HOME $TOMCATBIN
                                setenv CATALINA_BASE $TOMCATSDIR/$2/
                                setenv CATALINA_TMPDIR $TOMCATSDIR/$2/temp
                                setenv JAVA_HOME `cat $TOMCATSDIR/$2/config.properties | head -n 1 | awk -F "#" '{print $2}'`
                                setenv JAVA_OPTS `cat $TOMCATSDIR/$2/config.properties | head -n 1 | awk -F "#" '{print $3}'`" -Djava.io.tmpdir=$CATALINA_TMPDIR"

                                # on demarre Tomcat
                                echo
                                echo "Options de Tomcat"
                                echo "-----------------"
                                $CATALINA_HOME/bin/startup.sh

                                # On test si cela c'est bien passe
                                if ($? == 0) then
                                        # Message indiquant le bon fonctionnement
                                        echo
                                        echo "Information complementaire"
                                        echo "--------------------------"
                                        echo "Demarrage de l'instance $2             [ ok ]"
                                        echo
                                else
                                        # Message indiquant le mauvais fonctionnement
                                        echo
                                        echo "Demarrage de l'instance $2             [ echec ]"
                                        echo "L'instance a rencontre une erreur et n'a pas pu demarer, essaye de la demarrer manuellement avec la commande :"
                                        echo "$CATALINA_HOME/bin/startup.sh"
                                        echo
                                        exit 1
                                endif
                        endif
                endif
        endif
breaksw


#--------------------------------#
#   Arreter une instance tomcat  #
#--------------------------------#

case tomcatStop:          <nominstance>  arrete une instance JAVA
        # On test si il a bien un nom d'instance
        if($2 == "") then
                echo
                echo "ATTENTION : Il faut donner le nom de l'instance en parametre"
                echo "Exemple d'instance disponible sur la machine :"
                echo
                ls  $TOMCATSDIR | grep -v apache | grep tomcat | awk -F@ '{print $1}'
                echo
                exit 1
        else if("$COM2" == "all") then
            set CONTEXTES=`ls  $TOMCATSDIR | grep -v apache | grep tomcat | awk -F@ '{print $1}'`
            foreach CONTEXTE ($CONTEXTES)
                $GWBIN $COM $CONTEXTE
            end
        else
               # On verifie la presence de la config de l'instance
                if (! -f $TOMCATSDIR/$2/config.properties) then
                        echo "la configuration de cette instance est introuvable."
                        echo "le fichier $TOMCATSDIR/$2/config.properties n'est pas present"
                        exit 1
                endif

                # On recupere le numero de processus
                set PID=`ps awwux | grep java | grep $2 | awk -F' ' '{print $2}'`
                # Si l'instance n'est pas lancee
                if ("$PID" == "") then
                        # Message d'inofrmation
                        echo
                        echo "Erreur   : l'instance $2 n'est pas demarree !"
                        echo "Solution : gw tomcatStart $2"
                        echo
                        exit 1
                else
                        # On definit les variables
                        setenv CATALINA_HOME $TOMCATBIN
                        setenv CATALINA_BASE $TOMCATSDIR/$2/
                        setenv CATALINA_TMPDIR $TOMCATSDIR/$2/temp
                        setenv JAVA_HOME `cat $TOMCATSDIR/$2/config.properties | head -n 1 | awk -F "#" '{print $2}'`
                        setenv JAVA_OPTS `cat $TOMCATSDIR/$2/config.properties | head -n 1 | awk -F "#" '{print $3}'`" -Djava.io.tmpdir=$CATALINA_TMPDIR"

                        # On stop l'instance
                        $CATALINA_HOME/bin/shutdown.sh > & /dev/null
                        sleep 2
                        # On recupere le numero de processus
                        set PID=`ps awwux | grep java | grep tomcat | grep $2 | awk -F' ' '{print $2}'`
                        if ("$PID" == "") then
                                # Message indiquant le bon fonctionnement
                                echo
                                echo "Arret de l'instance $2             [ ok ]"
                                echo
                                echo "Vous pouvez verifier que l'instance est bien arretez avec la commande :"
                                echo "gw ps | grep $2"
                                echo
                                exit
                        else
                                # On commence une boucle de 10 minutes
                                set CPT=0
                                while ($CPT < 60)
                                        # On attend 10 secondes
                                        sleep 10
                                        # On recupere le numero de processus
                                        set PID=`ps awwux | grep java | grep tomcat | grep $2 | awk -F' ' '{print $2}'`
                                        if ("$PID" == "") then
                                                # Message indiquant le bon fonctionnement
                                                echo
                                                echo "Arret de l'instance $2             [ ok ]"
                                                echo
                                                echo "Vous pouvez verifier que l'instance est bien arretez avec la commande :"
                                                echo "gw ps | grep $2"
                                                echo
                                                exit
                                        else
                                                # On incremente cpt
                                                @ CPT++
                                                echo "Tentative d'arret $CPT"
                                        endif
                                end
                        endif
                        # Si on a fait 10 passage on force le kill
                        if($CPT == 60) then
                                # Message indiquant le mauvais fonctionnement
                                echo
                                echo "L'instance a rencontre une erreur lors de l'arret !"
                        endif
                endif
        endif
breaksw


#--------------------------------------#
#   Redemarrer une instances tomcat    #
#--------------------------------------#

case tomcatRestart:     Redemarrer une instances tomcat

    echo
    echo "Redemarrer une instances tomcat"
    echo "-------------------------------"
    echo
    if($2 == "") then
        echo
        echo "ATTENTION : Il faut donner le nom de l'instance en parametre"
        echo "Exemple d'instance disponible sur la machine :"
        echo
        ls  $TOMCATSDIR | grep -v apache | grep tomcat | awk -F@ '{print $1}'
        echo
        exit 1
    else
        $GWBIN tomcatStop $2
        $GWBIN tomcatStart $2
    endif
breaksw



#-----------------------------------------------------#
#   Demarrer des serveurs d'impression de contextes   #
#-----------------------------------------------------#

case serveurImpressionListe:      Affiche la liste des serveur d'impression disponibles

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
        echo "  gw serveurImpressionListe   affiche la liste des serveurs d'impression disponibles"
        echo ""
        echo "  -h, -help, --h, --help      affiche ce message"
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
                if ( -f "$PRINTDIR/$CONTEXTE/start_impression.sh" ) then
            #Oui, on l'affiche
            echo "$CONTEXTE"
        endif
    end
breaksw

#-----------------------------------------------------#
#   Demarrer des serveurs d'impression de contextes   #
#-----------------------------------------------------#

case serveurImpressionStart:      <all|nomDuContexte> Demarrer les serveurs d impression des contextes demandes


        #------------------------------------
        #Usage non conforme ou demande d'aide
        if ("$COM2" == "" || "$COM2" == "-h" || "$COM2" == "--help") then
                #Message sur l'usage du script
                echo ""
                echo "Usage :  gw serveurImpressionStart <all|contexte>"
                echo ""
                echo "  all                     demarre les serveurs d'impression de tous les contextes"
                echo "  nomDuContexte           demarre le serveur d'impression du contexte demande"
                exit 1
        endif

        cd $PRINTDIR
        if ("$COM2" == "all") then
          set CONTEXTES=`ls`
          foreach CONTEXTE ($CONTEXTES)
             if ( -f "$PRINTDIR/$CONTEXTE/start_impression.sh" ) then
                 $GWBIN $COM $CONTEXTE
             endif
          end
        else
           if ( -f "$PRINTDIR/$COM2/start_impression.sh" ) then
                  echo "demarrage de $COM2"
                  if ((`ps awwxx | grep PrintManager | grep $COM2 | grep -v grep | grep -v "gw serveurImpressionStart"` == "" )) then
                    cd $PRINTDIR/$COM2
                    ./start_impression.sh >& /var/log/serveurImpression/$COM2.log &
                  else
                    echo "$COM2 deja demarre"
                  endif
            else
                 echo "Le contexte $COM2 n'est pas correct"
            endif
        endif

breaksw


#-----------------------------------------------------#
#   Arreter des serveurs d'impression de contextes    #
#-----------------------------------------------------#

case serveurImpressionStop:       <all|nomDuContexte> Arreter les processus des serveurs d impression des contextes demandes

        #------------------------------------
        #Usage non conforme ou demande d'aide
        if ( $COM2 == "" || $COM2 == "-h" || $COM2 == "--help" ) then
                #Message d'information sur l'usage du script
                echo ""
                echo "Usage : gw serveurImpressionStop <all|contexte>"
                echo ""
                echo "  all                     stoppe l'ensemble des contextes lances"
                echo "  nomDuContexte                stoppe le serveur d'impression du contexte specifie"
                exit 1
        endif
        cd $PRINTDIR
        if ("$COM2" == "all") then
          set CONTEXTES=`ls`
          foreach CONTEXTE ($CONTEXTES)
                 $GWBIN $COM $CONTEXTE
          end
        else
           set PID=`ps awwxx | grep PrintManager | grep $COM2 | grep -v grep  | awk -F' ' '{print $1}'`
           if ($PID == "") then
             echo "$COM2 pas demarre"
           else
             echo "arret de $COM2"
             kill $PID
           endif
        endif

breaksw



#--------------------------------------------------------#
#   Redemarrage des serveurs d'impression de contextes   #
#--------------------------------------------------------#

case serveurImpressionRestart:     Redemarrer des serveurs d'impressions GEO

    echo
    echo "Redemarrage des serveurs impressions GEO"
    echo "----------------------------------------"
    echo
    if($2 == "") then
        echo
        echo "ATTENTION : Il faut donner le nom de l'instance en parametre"
        echo "Exemple d'instance disponible sur la machine :"
        echo
        ls  $TOMCATSDIR | grep -v apache | grep tomcat | awk -F@ '{print $1}'
        echo
        exit 1
    else
        $GWBIN serveurImpressionStop $2
        $GWBIN serveurImpressionStart $2
    endif
breaksw


#----------------------------------#
#   Gestion memoire - processus    #
#----------------------------------#

case appmem:                      _Affiche l'empreinte memoire d'un ou plusieurs process

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
            echo "----- Rapport d'utilisation memoire de $2 -----"
            echo ""
            echo "Nombre de processus : $COUNT_PID"
            echo "Taille swap utilise ~= $SWAP_MEM Mo"
            echo "Taille RAM utilisee ~= $RAM_MEM Mo"
            echo "Total RAM + Swap / processus ~= $TOTAL_PID Mo"
            echo ""
        else
            echo "Aucun processus ne correspond a $2"
            exit 1
        endif
    endif
breaksw



#------------------------------------------------#
#   Affichage des infos sur la machine en cours  #
#------------------------------------------------#

case systeme:                     _Infos completes sur le systeme

    if ($USER == "root") then
        echo ""
        echo "Configuration systeme"
        echo "====================="

        if ($PLATEFORME == "i386") then
            set PLATEFORME="32bit"
        else if ($PLATEFORME == "x86_64") then
            set PLATEFORME="64bit"
        else if ($PLATEFORME == "unknown") then
            set PLATEFORME="unknown (peut-etre une machine virtuelle ?)"
        endif

        # Infos
        set RAMTOTAL=`vmstat -s -S M | grep 'total memory' | sed 's/total memory/memoire totale/' | sed 's/M/Mo/'`
        set RAMUTILISE=`vmstat -s -S M | grep 'used memory' | sed 's/used memory/memoire utilisee/' | sed 's/M/Mo/'`
        set SWAPTOTAL=`vmstat -s -S M | grep 'total swap' | sed 's/total swap/swap total/' | sed 's/M/Mo/'`
        set SWAPUTILISE=`vmstat -s -S M | grep 'used swap' | sed 's/used swap/swap utilise/' | sed 's/M/Mo/'`
        set NBCPU=`cat /proc/cpuinfo | grep processor | wc -l`
        set CPU=`cat /proc/cpuinfo | grep 'model name' | sed -e 's/:/\n/g' | grep -v model | head -1`
        # TODO : Disque(s) dur modele, SMART, etc par ex. ?

        echo ""
        echo "Nom de machine : $HOSTNAME"
        echo "Nom de l'OS : $OS"
        echo "Description de l'OS : $OSNAME"
        echo "Platforme materielle : $PLATEFORME"
        echo "Date & Heure systeme : $DATETIME"
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
    echo "[parametre] : parametre optionnel"
    echo "<parametre> : parametre obligatoire"
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
    echo "Specifique $HOSTNAME"
    echo "--------------------"
    cat $0 | grep -E "^case " | grep -v "_" | sed -e "s/case //" | sed -e "s/:/ /" | grep -v "default" | sort | grep $CONFMACHINE
    echo
    echo "Conventions de syntaxe"
    echo "----------------------"
    echo "[parametre] : parametre optionnel"
    echo "<parametre> : parametre obligatoire"
    echo
breaksw
endsw

#-----------------------#
# Conserve pour info    #
#-----------------------#

# Construction d'un mail
#   cat > /tmp/mail.$$ <<FINMAIL
#Mime-version: 1.0
#Content-type: text/plain; charset=iso-8859-1
#Content-transfer-encoding: 8bit
#From: <$WEBMASTER>
#To: localhost@localhost.fr
#Subject: Info redemarrage application SI : $2

#Bonjour, l'application $2 vient d'etre relancee.
#Voici le log d'erreur :

#FINMAIL
