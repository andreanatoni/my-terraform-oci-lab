#!/bin/bash
sudo dnf install httpd --assumeyes --quiet
sudo systemctl enable httpd
sudo systemctl start httpd
sudo firewall-offline-cmd --add-service=http
sleep 10
sudo systemctl restart firewalld
echo "<!doctype html><html><body><h1>This is SPARTAAAA! from: $(hostname)</h1></body></html>" | sudo tee /var/www/html/index.html