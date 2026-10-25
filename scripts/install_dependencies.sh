#!/bin/bash
set -e

APP_DIR="/opt/ml-cicd-demo"

apt-get update
apt-get install -y python3 python3-venv python3-pip apache2

mkdir -p "$APP_DIR"

cd "$APP_DIR"

python3 -m venv venv

"$APP_DIR/venv/bin/pip" install --upgrade pip
"$APP_DIR/venv/bin/pip" install -r requirements.txt

a2enmod proxy
a2enmod proxy_http
a2enmod rewrite

systemctl enable apache2
