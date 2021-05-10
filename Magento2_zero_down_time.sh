#!/usr/bin/env bash
# ============ 
# Bash configuration
# -e exit on first error
# -u error is variable unset
# -x display commands for debugging
set -eux

# Set variable for project 

LANGUAGES='en_US en_GB'                                 # Set lanuage here which your project support
WORKING_DIR=`pwd`                                       # this allow you to configure this project whereever the script run
MAGENTO_DIR='releases'                                  # this is where build got created 
LIVE_DIRECTORY_ROOT='public_html'                       # code live location this is where the code get executed from browser
date=`date '+%d%b%Y'_%H%M%S`                            # for version control which use date and time once the build got created 
GIT_REPO=${WORKING_DIR}/GIT_REPO                        # Git code using Rsync goes in this location 
KEEP_RELEASES=3                                         # This is only to keep last three backup of Code
KEEP_DB_BACKUPS=3                                       # This is only to keep last three backup of DB 
project=Name_$date                                      # Name your Project Make sure only Chnage the NAME valu not the date variable 
LIVE=${WORKING_DIR}/${LIVE_DIRECTORY_ROOT}              # this is for soft link which will be created after everything goes fine
TARGET=$WORKING_DIR/$MAGENTO_DIR/$project               # this will become the source so that we can make a soft link between LIVE from TARGET
PHP='/usr/bin/php7.4'                                   # change the version of php as you want 

# For PHP version each server is diffrent for finding the php location as per your version search it or do google
# IN ubuntu the location is /usr/bin/php, /usr/bin/php7.1,  /usr/bin/php7.2,  /usr/bin/php7.3,  /usr/bin/php7.4,  /usr/bin/php8.0,
# for Cpanle /opt/cpanel/ea-php74/root/usr/bin/php, /opt/cpanel/ea-php73/root/usr/bin/php,  /opt/cpanel/ea-php72/root/usr/bin/php,  /opt/cpanel/ea-php71/root/usr/bin/php and so on.....
# Just change ea-php version as you want just make sure the version of php is installed and running 



# INIT DIRECTORIES
if [ ! -d 'releases' ]; then
  mkdir releases
fi
if [ ! -d 'shared' ]; then
  mkdir shared
fi
if [ ! -d 'shared/magento' ]; then
  mkdir shared/magento
fi
if [ ! -d 'backups' ]; then
  mkdir backups
fi

cp -raf $GIT_REPO $WORKING_DIR/$MAGENTO_DIR/$project

cd ${WORKING_DIR}
cp -rvf ${WORKING_DIR}/shared/magento/config.php $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/config.php
cp -rvf ${WORKING_DIR}/shared/magento/composer.phar $WORKING_DIR/$MAGENTO_DIR/$project/composer.phar
cp -rvf ${WORKING_DIR}/shared/magento/env.php $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php
ln -sf ${WORKING_DIR}/shared/magento/media  $WORKING_DIR/$MAGENTO_DIR/$project/pub/media
ln -sf ${WORKING_DIR}/shared/magento/var/log $WORKING_DIR/$MAGENTO_DIR/$project/var/log
cp -raf ${WORKING_DIR}/shared/magento/vendor $WORKING_DIR/$MAGENTO_DIR/$project/

# Databases config include varibles 
dbhost=`grep -E "host|dbname|username|password"   $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php | awk   '{gsub(/" /, "", $1); print $1, $3; }' |  awk 'NR==1{print $2}' | sed 's/\,$//' | tr -d \'\" |  awk '{host=$1 ; print host ; }'`
dbname=`grep -E "host|dbname|username|password"   $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php | awk   '{gsub(/" /, "", $1); print $1, $3; }' |  awk 'NR==2{print $2}' | sed 's/\,$//' | tr -d \'\" | awk '{host=$1 ; print host ; }'` 
username=`grep -E "host|dbname|username|password" $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php | awk   '{gsub(/" /, "", $1); print $1, $3; }' |  awk 'NR==3{print $2}' | sed 's/\,$//' | tr -d \'\" |  awk '{host=$1 ; print host ; }'`
password=`grep -E "host|dbname|username|password" $WORKING_DIR/$MAGENTO_DIR/$project/app/etc/env.php | awk   '{gsub(/" /, "", $1); print $1, $3; }' |  awk 'NR==4{print $2}' | sed 's/\,$//' | tr -d \'\" |  awk '{host=$1 ; print host ; }'`




# Composer install if needed please uncomment below line

cd $WORKING_DIR/$MAGENTO_DIR/$project/ && pwd && $PHP -dmemory_limit=-1   ./composer.phar install --no-dev --prefer-dist --optimize-autoloader


# DATABASE UPDATE
cd $WORKING_DIR/$MAGENTO_DIR/$project/ && $PHP -dmemory_limit=-1   bin/magento setup:db:status && UPGRADE_NEEDED=0 || UPGRADE_NEEDED=1
if [[ 1 == ${UPGRADE_NEEDED} ]]; 
then
mysqldump -h $dbhost -u $username -p$password  $dbname | gzip -c > ${WORKING_DIR}/backups/$dbname`date '+%d%b%Y'_%H%M%S`.tar.gz
$PHP -dmemory_limit=-1  	bin/magento setup:upgrade 
fi


# # GENERATE FILES
cd $WORKING_DIR/$MAGENTO_DIR/$project/
$PHP -dmemory_limit=-1 bin/magento setup:di:compile
$PHP -dmemory_limit=-1   bin/magento setup:static-content:deploy -f ${LANGUAGES} 
find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec chmod g+w {} \;



# SWITCH LIVE
echo $LIVE





# SWITCH LIVE

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


# # UPDATE CRONTAB
cd ${LIVE} &&  bin/magento cron:install --force

# CLEAR ALL CACHES
cd ${LIVE} &&  bin/magento  c:f


#CLEAN UP
KEEP_RELEASES_TAIL=`expr ${KEEP_RELEASES} + 1`
cd ${WORKING_DIR}/releases && rm -rf `ls -t | tail -n +${KEEP_RELEASES_TAIL}`
KEEP_DB_BACKUPS_TAIL=`expr ${KEEP_DB_BACKUPS} + 1`
cd ${WORKING_DIR}/backups && rm -rf `ls -t | tail -n +${KEEP_DB_BACKUPS_TAIL}`

# RETURN TO WORKING DIR
cd ${WORKING_DIR}




unset {dbhost,dbname,username,password}
