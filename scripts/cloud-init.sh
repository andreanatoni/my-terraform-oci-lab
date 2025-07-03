#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

echo "### Installing Apache"
sudo dnf install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd

echo "### Opening firewall"
sudo firewall-offline-cmd --add-service=http
sleep 10
sudo systemctl restart firewalld

echo "<!doctype html><html><body><h1>This is SPARTAAAA! from: $(hostname)</h1></body></html>" | sudo tee /var/www/html/index.html
