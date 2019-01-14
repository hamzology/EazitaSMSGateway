#!/bin/bash

user=$1
domain=$2

owner=$(who am i | awk '{print $1}')
userdir="/home/$user"
userpublicdir="/home/$user/public_html"


if [ "$(whoami)" != 'root' ]; then
	echo $"You have no permission to run $0 as non-root user. Use sudo"
		exit 1;
fi

while [ "$domain" == "" ]
do
	echo -e $"Please provide domain. e.g.dev,staging"
	read domain
done

mkdir -p $userdir
mkdir -p $userpublicdir

chown -R apache: /home/$domain/


