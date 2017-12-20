#!/usr/bin/env bash
# Bash script to install lets encrypt SSL certificate as a POST HOOK
# For use with Single instance PHP Elastic Beanstalk
set -e
# Loadvars
. /opt/elasticbeanstalk/support/envvars

# Install if no SSL certificate installed or SSL install on deploy is true

if [[ ("$LE_INSTALL_SSL_ON_DEPLOY" = true) || (! -f /etc/httpd/conf.d/ssl.conf) ]] ; then

    # Install mod_ssl
    sudo yum -y install mod24_ssl

    # Install json query and get document root
    sudo yum -y install jq

    # Assign value to DOCUMENT_ROOT
    DOCUMENT_ROOT=$(sudo /opt/elasticbeanstalk/bin/get-config optionsettings | jq '."aws:elasticbeanstalk:container:php:phpini"."document_root"' -r)

   SECONDS=0

    # Wait until domain is resolving to ec2 instance
    echo "Pinging $LE_SSL_DOMAIN until online..."
    while ! timeout 0.2 ping -c 1 -n $LE_SSL_DOMAIN &> /dev/null
    do
        SECONDS=$[$SECONDS +1]
        if [ $SECONDS -gt 30 ]
        then
            echo "$SECONDS seonds timeout waiting to ping, lets exit";
            exit 1;
        fi
    done
    echo "Pinging $LE_SSL_DOMAIN successful"

    # Install certbot
    sudo mkdir -p /certbot
    cd /certbot || exit
    wget https://dl.eff.org/certbot-auto;chmod a+x certbot-auto

    # Create certificate and authenticate
    sudo ./certbot-auto certonly -d "$LE_SSL_DOMAIN" --agree-tos --email "$LE_EMAIL" --webroot --webroot-path /var/app/current"$DOCUMENT_ROOT" --debug --non-interactive --renew-by-default

    # Configure ssl.conf
    sudo mv /etc/httpd/conf.d/ssl.conf.template /etc/httpd/conf.d/ssl.conf
    sudo sed -i -e "s/{DOMAIN}/$LE_SSL_DOMAIN/g" /etc/httpd/conf.d/ssl.conf

    # Install crontab
    sudo crontab /tmp/cronjob

    # Start apache
    sudo service httpd restart

fi
