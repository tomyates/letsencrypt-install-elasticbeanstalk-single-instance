#!/usr/bin/env bash
# Bash script to install lets encrypt SSL certificate as a POST HOOK
# For use with Single instance PHP Elastic Beanstalk

# Loadvars
. /opt/elasticbeanstalk/support/envvars

if [ "$LE_INSTALL_SSL_ON_DEPLOY" = true ] ; then

    # Install mod_ssl
    sudo yum -y install mod24_ssl

    # Install json query and get document root
    sudo yum -y install jq

    # Assign value to DOCUMENT_ROOT
    DOCUMENT_ROOT=`sudo /opt/elasticbeanstalk/bin/get-config optionsettings | jq '."aws:elasticbeanstalk:container:php:phpini"."document_root"' -r`


    # Install certbot
    sudo mkdir /certbot
    cd /certbot
    wget https://dl.eff.org/certbot-auto;chmod a+x certbot-auto

    # Create certificate
    sudo ./certbot-auto certonly -d $LE_SSL_DOMAIN --agree-tos --email $LE_EMAIL --webroot --webroot-path /var/app/current$DOCUMENT_ROOT --debug --non-interactive --renew-by-default

    # Configure ssl.conf
    sudo mv /etc/httpd/conf.d/ssl.conf.template /etc/httpd/conf.d/ssl.conf
    sudo sed -i -e "s/{DOMAIN}/$LE_SSL_DOMAIN/g" /etc/httpd/conf.d/ssl.conf

    # Install crontab
    sudo crontab /tmp/cronjob

    # Restart apache
    sudo service httpd restart

fi
