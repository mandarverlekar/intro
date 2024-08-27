#!/bin/bash
sudo apt update
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo chmod 777 -R /var/www/html
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
