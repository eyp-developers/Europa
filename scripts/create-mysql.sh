#!/usr/bin/env bash

DB=$1;
user=$2;
pw=$3;

mysql -u${user} -p${pw} -e "DROP DATABASE IF EXISTS \`$DB\`";
mysql -u${user} -p${pw} -e "CREATE DATABASE \`$DB\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";

# mysql -uroot -proot -e "DROP DATABASE IF EXISTS \`$DB\`";
# mysql -uroot -proot -e "CREATE DATABASE \`$DB\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";
