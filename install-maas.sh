#!/bin/bash

HOST="$1"
MAAS_DBPASS="$2"
ADMIN_PASS="$3"
ADMIN_EMAIL="$4"

if [ -z $HOST ]; then
   echo -e "Must provide hostname or IP to this machine."
   exit 1;
fi

if [ -z $MAAS_DBPASS ]; then
	echo -e "Must provide database password to use."
	exit 1;
fi

if [ -z $ADMIN_PASS ]; then
	echo -e "Must provide admin password for MAAS."
	exit 1;
fi

if [ -z $ADMIN_EMAIL ]; then
	echo -e "Must provide admin email to use."
	exit 1;
fi

echo -e "Setting up MAAS at ${HOST} with DB pass of '${MAAS_DBPASS}', admin pass of '${ADMIN_PASS}' and admin email of '${ADMIN_EMAIL}'."
read -p "Ok to proceed? (Y/N)" response

if [ ${response} == "Y" ] || [ ${response} == "y" ]; then

  apt update -y
  apt install -y postgresql

  export MAAS_DBUSER="cortex"
  export MAAS_DBNAME="maas"

  POST_CMD="CREATE USER \"${MAAS_DBUSER}\" WITH ENCRYPTED PASSWORD '${MAAS_DBPASS}'"
  echo ${POST_CMD}
  sudo -u postgres psql -c "${POST_CMD}"
  sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
 
  echo "host    maas            cortex          0/0                     md5" >> /etc/postgresql/10/main/pg_hba.conf

  snap install maas --channel=2.8/candidate
  maas init --mode region+rack --maas-url http://${HOST}:5240/MAAS/ --database-uri "postgres://${MAAS_DBUSER}:${MAAS_DBPASS}@localhost/${MAAS_DBNAME}"
  maas createadmin --username=admin --password=${ADMIN_PASS} --email=${ADMIN_EMAIL}

  echo -e "Open browser at http://localhost:5240 to access MAAS and finish configuration."

else
	echo -e "Aborting installation."
fi

