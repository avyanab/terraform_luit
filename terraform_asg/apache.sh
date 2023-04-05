#!/bin/bash

#Updating all packages and installing Apache, the '&&' will stop next line if preceeding line is unsuccessful
sudo yum update -y &&
sudo yum install -y httpd &&
sudo systemctl enable httpd
sudo systemctl start httpd

#Script for a customized apache webpage
cd /var/www/html
sudo echo "<html><body><h1>Welcome to my Apache webpage!</h1></body></html>" > /var/www/html/index.html