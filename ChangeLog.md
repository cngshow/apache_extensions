apache extensions changelog 

This changelog summarizes changes and fixes which are a part of each revision.  For more details on the fixes, refer tracking numbers 
where provided, and the git commit history.  Note that this repository contains system configuration files - not software that is 
deployed.

THIS IS THE DEVEOPMENT BRANCH

* 2017/09/12 - 5.1
	* All configuration changes required for release 5 - including NTRT, etc, and new ansible scripts to ease deployments.

* 2017/03/21 - 1.9
	* renamed:server_config.yml-PRE -> server_config.yml-PRE-R2
    * renamed:server_config.yml-PROD -> server_config.yml-PROD-R2
    * renamed:ssl.conf-PRE -> ssl.conf-PRE-R2
    * renamed:ssl.conf-PROD -> ssl.conf-PROD-R2
    * Production build for Release 3

* 2017/03/02 - 1.8
    * updates to server index pages
    * updates to cleanup multi-deploy config files

* 2017/01/26 - 1.7 
    * New files: index.html-DEV, index.html-SQA, index.html-TEST
    * Changes to: ssl.conf-SQA (newciphers), ssl.conf-TEST (newcyphersuites)

* 2017/01/19 - 1.6 
    * Changes to be committed:multi-deploy
    * New file:server_config.yml-SQA-multi-deploy
    * New file:ssl.conf-SQA-multi-deploy

* 2017/01/05 - 1.5: 
    * Changes to be committed:proxy-multiple instances
    * modified:ssl.conf-DEV
    * modified:server_config.yml-DEV
    
* 2016/11/13 - 1.4: 
    * Added missing yaml files

* 2016/12/02 - 1.3: 
    * Config updates
    
* 2016/11/17 - 1.2: 
    * Config updates

* 2016/11/03 - 1.1: 
    * See the GIT changelog for updates prior to this release.
