# Magento 2 Zero Down time 

**Hi everyone hope you guys are doing well**


So This is my first time i'm uploading my script on internet so if you find any error or spell mistake please do let me know i'll be really greatful of yours.

This Script is only for **magento 2** I'm working on other platform also so that everyone who having hard time can solve their issue with application like magento 2 or any other PHP application.


Details
-----
## Set Variable For Project 
You can simply download the script file and give the executable permission.
```
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

```

Structure Of Zero Downtime
-----
-The Script will create below mention directory
```

```



