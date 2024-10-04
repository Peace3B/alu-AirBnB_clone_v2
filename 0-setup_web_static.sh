#!/usr/bin/env bash
# Script that sets up web servers for the deployment of web_static

# Exit on any error
set -e

# Install Nginx if it is not already installed
if ! dpkg -l | grep -q nginx; then
    sudo apt-get update -y
    sudo apt-get install nginx -y
fi

# Create required directories if they don't exist
sudo mkdir -p /data/web_static/releases/test/
sudo mkdir -p /data/web_static/shared/

# Create a fake HTML file in /data/web_static/releases/test/index.html
echo "<html>
  <head>
  </head>
  <body>
    Holberton School
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null

# Remove existing symbolic link and create a new one
if [ -L /data/web_static/current ]; then
    sudo rm /data/web_static/current
fi
sudo ln -s /data/web_static/releases/test/ /data/web_static/current

# Give ownership of /data/ folder to ubuntu user and group recursively
sudo chown -R ubuntu:ubuntu /data/

# Update Nginx configuration to serve content of /data/web_static/current/ to /hbnb_static/
if ! grep -q "location /hbnb_static/" /etc/nginx/sites-available/default; then
    sudo sed -i '/server_name _;/a \\n\tlocation /hbnb_static/ {\n\t\talias /data/web_static/current/;\n\t}' /etc/nginx/sites-available/default
fi

# Restart Nginx to apply changes
sudo service nginx restart

# Ensure the script exits successfully
exit 0
