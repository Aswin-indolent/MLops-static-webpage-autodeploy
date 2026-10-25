#!/bin/bash
set -e

APP_DIR="/opt/ml-cicd-demo"

test -f "$APP_DIR/index.html"
test -f "$APP_DIR/app.py"
test -f "$APP_DIR/model.py"

if [ ! -f "$APP_DIR/iris_model.joblib" ]; then
    cd "$APP_DIR"
    "$APP_DIR/venv/bin/python" model.py
fi

mkdir -p /var/www/html
cp "$APP_DIR/index.html" /var/www/html/index.html

cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html

    ProxyPreserveHost On

    ProxyPass /predict http://127.0.0.1:5000/predict
    ProxyPassReverse /predict http://127.0.0.1:5000/predict

    ProxyPass /health http://127.0.0.1:5000/health
    ProxyPassReverse /health http://127.0.0.1:5000/health

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

cat > /etc/systemd/system/ml-cicd-demo.service <<'EOF'
[Unit]
Description=ML CI/CD Flask API
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/ml-cicd-demo
ExecStart=/opt/ml-cicd-demo/venv/bin/gunicorn --workers 2 --bind 127.0.0.1:5000 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ml-cicd-demo
systemctl restart ml-cicd-demo
systemctl restart apache2

sleep 2
systemctl is-active --quiet ml-cicd-demo
systemctl is-active --quiet apache2
