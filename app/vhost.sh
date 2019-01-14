#!/bin/bash

user=$1
domain=$2

sitesAvailable='/etc/apache2/sites-available/'
userDir='/var/www/'
sitesAvailabledomain=$sitesAvailable$domain.conf

owner=$(who am i | awk '{print $1}')
userdir="/home/$user"
userpublicdir="/home/$user/public_html"


if [ "$(whoami)" != 'root' ]; then
	echo -e $"You have no permission to run $0 as non-root user. Use sudo"
		exit 1;
fi

while [ "$domain" == "" ]
do
	echo -e $"Please provide domain."
		exit 1;
done

if [ -e $sitesAvailabledomain ]; then
	echo -e $"This domain already exists.\nPlease Try Another one"
		exit;
fi

if ! [ -d $userdir ]; then
	mkdir -p $userdir
	mkdir -p $userpublicdir
	chmod 755 $userdir
fi

chown -R apache: /home/$domain/


