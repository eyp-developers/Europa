#!/usr/bin/env bash

# Run this as sudo!
# I move this file to /usr/local/bin/vhost and run command 'vhost' from anywhere, using sudo.

#
#   Show Usage, Output to STDERR
#
function show_usage {
cat <<- _EOF_

Create a new vHost in Ubuntu Server
Assumes /etc/apache2/sites-available and /etc/apache2/sites-enabled setup used

    -d    DocumentRoot - i.e. /var/www/yoursite
    -h    Help - Show this menu.
    -s    ServerName - i.e. example.com or sub.example.com
    -a    ServerAlias - i.e. *.example.com or another domain altogether
    -p    File path to the SSL certificate. Directories only, no file name.
          If using an SSL Certificate, also creates a port :443 vhost as well.
          This *ASSUMES* a .crt and a .key file exists
            at file path /provided-file-path/your-server-or-cert-name.[crt|key].
          Otherwise you can except Apache errors when you reload Apache.
          Ensure Apache\'s mod_ssl is enabled via "sudo a2enmod ssl".
    -c    Certificate filename. "xip.io" becomes "xip.io.key" and "xip.io.crt".

    Example Usage. Serve files from /var/www/xip.io at http(s)://192.168.33.10.xip.io
                   using ssl files from /etc/ssl/xip.io/xip.io.[key|crt]
    sudo vhost -d /var/www/xip.io -s 192.168.33.10.xip.io -p /etc/ssl/xip.io -c xip.io

_EOF_
exit 1
}


#
#   Output vHost skeleton, fill with userinput
#   To be outputted into new file
#
function create_vhost {
cat <<- _EOF_
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $serverName
    $serverAlias

    DocumentRoot $documentRoot


    <Directory $documentRoot>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted

        <FilesMatch \.php$>
            # Change this "proxy:unix:/path/to/fpm.socket"
            # if using a Unix socket
            SetHandler "proxy:fcgi://127.0.0.1:9000"
        </FilesMatch>
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$serverName-error.log

    # Possible values include: debug, info, notice, warn, error, crit,
    # alert, emerg.
    LogLevel warn

    CustomLog \${APACHE_LOG_DIR}/$serverName-access.log combined


</VirtualHost>
_EOF_
}

function create_ssl_vhost {
cat <<- _EOF_
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    ServerName $serverName
    $serverAlias

    DocumentRoot $documentRoot

    <Directory $documentRoot>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted

        <FilesMatch \.php$>
            # Change this "proxy:unix:/path/to/fpm.socket"
            # if using a Unix socket
            SetHandler "proxy:fcgi://127.0.0.1:9000"
        </FilesMatch>
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$serverName-error.log

    # Possible values include: debug, info, notice, warn, error, crit,
    # alert, emerg.
    LogLevel warn

    CustomLog \${APACHE_LOG_DIR}/$serverName-access.log combined

    SSLEngine on

    SSLCertificateFile  $certPath/$certName.crt
    SSLCertificateKeyFile $certPath/$certName.key

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>

    BrowserMatch "MSIE [2-6]" \\
        nokeepalive ssl-unclean-shutdown \\
        downgrade-1.0 force-response-1.0
    # MSIE 7 and newer should be able to use keepalive
    BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
</VirtualHost>
_EOF_
}

#Sanity Check - are there two arguments with 2 values?
if [ "$#" -lt 4 ]; then
    show_usage
fi

CertPath=""

# Create some sensible variable names
serverName = $1
documentRoot = $2

#Parse flags
while getopts "a:p:c:h" OPTION; do
    case $OPTION in
        h)
            show_usage
            ;;
        a)
            alias=$OPTARG
            ;;
        p)
            certPath=$OPTARG
            ;;
        c)
            certName=$OPTARG
            ;;
        *)
            show_usage
            ;;
    esac
done

# If alias is set:
if [ "$alias" != "" ]; then
    serverAlias="ServerAlias "$alias
else
    serverAlias=""
fi

# If CertName doesn't get set, set it to ServerName
if [ "$certName" == "" ]; then
     certName=$serverName
fi

if [ ! -d $documentRoot ]; then
    mkdir -p $documentRoot
    #chown USER:USER $DocumentRoot #POSSIBLE IMPLEMENTATION, new flag -u ?
fi

if [ -f "$documentRoot/$serverName.conf" ]; then
    echo 'vHost already exists. Aborting'
    show_usage
else
    create_vhost > /etc/apache2/sites-available/${serverName}.conf

    # Add :443 handling
#    if [ "$CertPath" != "" ]; then
#        create_ssl_vhost >> /etc/apache2/sites-available/${serverName}.conf
#    fi

    # Enable Site
    cd /etc/apache2/sites-available/ && a2ensite $serverName.conf
    service apache2 reload
fi