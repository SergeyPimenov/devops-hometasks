#!/bin/bash

if [ "${OUR_SITE}" == "static" ]
then

cat <<PAST | tee /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/static
        DirectoryIndex index.html
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
PAST

fi

apache2ctl -D FOREGROUND

