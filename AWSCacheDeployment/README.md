# AWSCacheDeployment
Collection of scripts for Automated deployment of InterSystems Caché instances into the Amazon cloud

Scripts would provision three AWS instances with RedHat linux, install Caché on each instance and perform initial configuration of the instance.

Prerequisites - you need to provide your own web server and/or Amazon S3 bucket to store distribution and the script/key files.

Replace 'https://mywebsite.com/' in cloudformation.json and bootstrap.sh with your own website address.

You also need to replace "KeyName" : "mykey" with the name of your own keypar.

Package content:

cloudformation.json Amazon Cloud Formation template that provisions three RedHad Linux instances and kicks in initial instance bootstrapping with bootstrap.sh.

bootstrap.sh opens ports in IPTABLE and performs Caché installation with Installer Manifest and cache.key file.

sninstaller.xml performs initial Caché configuration, so it is ECP-ready.
