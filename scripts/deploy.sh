#!/usr/bin/env bash
set -euo pipefail

echo "=== DevOps Toolkit Deploy ==="

# 1) Create the app
mkdir -p ~/myapp
cat > ~/myapp/server.py << 'EOF'
from http.server import HTTPServer, BaseHTTPRequestHandler
import os, json, datetime

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({
            "service": "devops-toolkit",
            "time": datetime.datetime.now().isoformat(),
            "path": self.path,
        }).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def log_message(self, fmt, *args):
        print(f"{self.address_string()} - {fmt%args}", flush=True)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    print(f"listening on :{port}", flush=True)
    HTTPServer(("127.0.0.1", port), H).serve_forever()
EOF
echo "App created"

# 2) Create systemd service
sudo tee /etc/systemd/system/devops-toolkit.service > /dev/null << EOF
[Unit]
Description=DevOps Toolkit App
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/myapp
ExecStart=/usr/bin/python3 $HOME/myapp/server.py
Restart=on-failure
RestartSec=3
Environment=PORT=8000
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
echo "Systemd service created"

# 3) Generate self-signed cert
sudo openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/ssl/private/devops-toolkit.key \
    -out /etc/ssl/certs/devops-toolkit.crt \
    -days 365 \
    -subj "/CN=localhost" 2>/dev/null
echo "Self-signed cert generated"

# 4) Create nginx config
sudo tee /etc/nginx/sites-available/devops-toolkit > /dev/null << 'EOF'
server {
    listen 80;
    server_name localhost;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate     /etc/ssl/certs/devops-toolkit.crt;
    ssl_certificate_key /etc/ssl/private/devops-toolkit.key;

    add_header X-Powered-By "devops-toolkit" always;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        access_log off;
        return 200 "ok\n";
    }
}
EOF
echo "Nginx config created"

# 5) Enable everything
sudo ln -sf /etc/nginx/sites-available/devops-toolkit /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl daemon-reload
sudo systemctl enable --now devops-toolkit.service
sudo systemctl reload nginx
echo "Services started"

echo ""
echo "=== Deploy Complete ==="
echo "Test with: curl -k https://localhost/hello"
