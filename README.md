# Magento 2 Zero Downtime 



**Hi everyone hopes you guys are doing well**





So This is my first time I'm uploading my script on the internet so if you find any error or spelling mistakes please do let me know I'll be really grateful of yours.



This Script is only for **Magento 2** I'm working on another platform also so that everyone who having a hard time with applications like Magento 2 or any other PHP application.





Details

-----

## Set Variable For Project 

You can simply download the script file and give the executable permission.

```

LANGUAGES='en_US en_GB'                                 # Set language here which your project support

WORKING_DIR=`pwd`                                       # this allows you to configure this project wherever the script run

MAGENTO_DIR='releases'                                  # this is where build got created 

LIVE_DIRECTORY_ROOT='public_html'                       # code live location this is where the code gets executed from the browser

date=`date '+%d%b%Y'_%H%M%S`                            # for version control which uses date and time once the build got created 

GIT_REPO=${WORKING_DIR}/GIT_REPO                        # Git code using Rsync goes in this location 

KEEP_RELEASES=3                                         # This is only to keep the last three back-ups of Code

KEEP_DB_BACKUPS=3                                       # This is only to keep the last three back-ups of DB 

project=Name_$date                                      # Name your Project Make sure only Change the NAME value not the date variable 

LIVE=${WORKING_DIR}/${LIVE_DIRECTORY_ROOT}              # this is for the soft link which will be created after everything goes fine

TARGET=$WORKING_DIR/$MAGENTO_DIR/$project               # this will become the source so that we can make a soft link between LIVE from TARGET

PHP='/usr/bin/php7.4'                                   # change the version of PHP as you want 



# For PHP version each server is diffrent for finding the php location as per your version search it or do google

# IN ubuntu the location is /usr/bin/php, /usr/bin/php7.1,  /usr/bin/php7.2,  /usr/bin/php7.3,  /usr/bin/php7.4,  /usr/bin/php8.0,

# for Cpanle /opt/cpanel/ea-php74/root/usr/bin/php, /opt/cpanel/ea-php73/root/usr/bin/php,  /opt/cpanel/ea-php72/root/usr/bin/php,  /opt/cpanel/ea-php71/root/usr/bin/php and so on.....

# Just change ea-php version as you want just make sure the version of php is installed and running 

```

### Please dont change the line number upside down or else it will not work.

#### For PHP version each server is diffrent for finding the php location as per your version search it or do google

#### in OS like ubuntu the location is mention below 

 * PHP Location in ubuntu.

    * /usr/bin/php,

    * /usr/bin/php7.1,

    * /usr/bin/php7.2,  

    * /usr/bin/php7.3,  

    * /usr/bin/php7.4,  

    * /usr/bin/php8.0,



#### in Cpanel the location is mention below 

 * PHP Location in Cpanel.

    * /opt/cpanel/ea-php56/root/usr/bin/php

    * /opt/cpanel/ea-php70/root/usr/bin/php

    * /opt/cpanel/ea-php71/root/usr/bin/php 

    * /opt/cpanel/ea-php72/root/usr/bin/php 

    * /opt/cpanel/ea-php73/root/usr/bin/php 

    * /opt/cpanel/ea-php70/root/usr/bin/php





    

#### it's quite easy to change the ea-PHP version as you want just make sure the version of PHP is installed and running.



Structure Of Zero Downtime

-----

### The Script will create below mention directory



```

releases

shared

shared/magento

backups



```



#### The script will exit with an error code after that you need to copy some files over there in the shared/magento folder list is mention below:



```

config.php file location (project)/app/etc/ 

env.php  file location (project)/app/etc/ 

media   folder location (project)/pub/media

var/log  folder location (project)/var/log

vendor    folder location (project)/vendor 





```

#### Copy all the files and folder in the Magento folder under the shared folder 



### Databases config include varibles 



```

dbhost=`grep -E "host|dbname|username|password"   $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php | awk   '{gsub(/" /, "", $1); print $1, $3; }' |  awk 'NR==1{print $2}' | sed 's/\,$//' | tr -d \'\" |  awk '{host=$1 ; print host ; }'`

dbname=`grep -E "host|dbname|username|password"   $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php | awk   '{gsub(/" /, "", $1); print $1, $3; }' |  awk 'NR==2{print $2}' | sed 's/\,$//' | tr -d \'\" | awk '{host=$1 ; print host ; }'` 

username=`grep -E "host|dbname|username|password" $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php | awk   '{gsub(/" /, "", $1); print $1, $3; }' |  awk 'NR==3{print $2}' | sed 's/\,$//' | tr -d \'\" |  awk '{host=$1 ; print host ; }'`

password=`grep -E "host|dbname|username|password" $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php | awk   '{gsub(/" /, "", $1); print $1, $3; }' |  awk 'NR==4{print $2}' | sed 's/\,$//' | tr -d \'\" |  awk '{host=$1 ; print host ; }'`



```



#### You don't need to mention the DB access details in the script cause the above mention commands will collect the details its self so you don't need to worry about it.



###  Composer install 

```

cd $WORKING_DIR/$MAGENTO_DIR/$project/ && pwd && /opt/cpanel/ea-php74/root/usr/bin/php -dmemory_limit=-1    /opt/cpanel/composer/bin/composer install --no-dev --prefer-dist --optimize-autoloader



```







### DATABASE UPDATE



```

cd $WORKING_DIR/$MAGENTO_DIR/$project/ && /opt/cpanel/ea-php74/root/usr/bin/php -dmemory_limit=-1   bin/magento setup:db:status && UPGRADE_NEEDED=0 || UPGRADE_NEEDED=1

if [[ 1 == ${UPGRADE_NEEDED} ]]; then



    mysqldump -h $dbhost -u $username -p$password  $dbname | gzip -c > ${WORKING_DIR}/backups/$dbname`date '+%d%b%Y'_%H%M%S`.tar.gz

  /opt/cpanel/ea-php74/root/usr/bin/php -dmemory_limit=-1  	bin/magento setup:upgrade 

fi



```



### GENERATE FILES



```

cd $WORKING_DIR/$MAGENTO_DIR/$project/

/opt/cpanel/ea-php74/root/usr/bin/php -dmemory_limit=-1 bin/magento setup:di:compile

/opt/cpanel/ea-php74/root/usr/bin/php -dmemory_limit=-1   bin/magento setup:static-content:deploy -f ${LANGUAGES} 

find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec chmod g+w {} \;



```





### SWITCH LIVE



```

cd ${WORKING_DIR}

if [[ -L "${LIVE}" ]]

then

    echo "${LIVE} unlinking the symlink "

    unlink ${LIVE}

fi

sleep 2



ln -sf ${TARGET} ${LIVE}



sleep 2



if [[ -L "${LIVE}" ]]

then

    echo "${LIVE}  the symlink has created  "

    

fi



```



### UPDATE CRONTAB



```

cd ${LIVE} &&  bin/magento cron:install --force

```



### CLEAR ALL CACHES

```

cd ${LIVE} &&  bin/magento cache:clear

```



### CLEAN UP

```

KEEP_RELEASES_TAIL=`expr ${KEEP_RELEASES} + 1`

cd ${WORKING_DIR}/releases && rm -rf `ls -t | tail -n +${KEEP_RELEASES_TAIL}`

KEEP_DB_BACKUPS_TAIL=`expr ${KEEP_DB_BACKUPS} + 1`

cd ${WORKING_DIR}/backups && rm -rf `ls -t | tail -n +${KEEP_DB_BACKUPS_TAIL}`

```

### RETURN TO WORKING DIR

```
cd ${WORKING_DIR}
```
### unset the var which this script created 
unset {dbhost,dbname,username,password}

