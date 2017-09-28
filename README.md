# letsencrypt-install-elasticbeanstalk-single-instance
.ebextensions script for automatically installing letsencrypt SSL on an Elastic Beanstalk single instance running Apache

# Instructions

1. The domain you wish to use must already have an A record pointing to the Elastic IP of your single instance, or by adding an alias record within Amazon Route 53 to your elastic beanstalk address. As long as the site is resolving on the domain you wish to use, you're good.

2. Copy the contents of .ebextensions folder to your project .ebextensions folder

3. Either change the values of environment variables in the config file, or add them to the container option from the console.

4. EB Deploy. The script will:
- Allow incoming traffic on port 443
- Install certbot
- Setup and download a certificate from letsencrypt
- Configure the Apache server with new certificate
- Restart Apache
- Install weekly cron to auto-update certificate

5. After deploying, you can change the environment variable `LE_INSTALL_SSL_ON_DEPLOY` to `false` to prevent script running every deployment which will slow deployment down.


## Get files from command line


```
wget https://raw.githubusercontent.com/tomyates/letsencrypt-install-elasticbeanstalk-single-instance/master/.ebextensions/9-ssl-letsencrypt-single-instance.config
wget https://raw.githubusercontent.com/tomyates/letsencrypt-install-elasticbeanstalk-single-instance/master/.ebextensions/9-letsencrypt-ssl-install.sh
wget https://raw.githubusercontent.com/tomyates/letsencrypt-install-elasticbeanstalk-single-instance/master/.ebextensions/ssl.conf.template
```
