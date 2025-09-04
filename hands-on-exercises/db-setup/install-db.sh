

#!/usr/bin/env bash
set -euo pipefail

# ===== Config =====
BASE_DIR="/opt/mysql-multi"
PORTS=(15000 16000 17000 18000)

# One strong root password for all instances (override by exporting MYSQL_ROOT_PASSWORD before running)
randpw() { tr -dc 'A-Za-z0-9!@#%^*-_=+' </dev/urandom | head -c 24; echo; }
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-$(randpw)}"

need_cmd(){ command -v "$1" >/dev/null 2>&1; }

echo "[+] Ubuntu 24 detected (assuming). Installing Docker if missing..."
if ! need_cmd docker; then
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker
fi

# Ensure docker starts on boot (extra safety)
sudo systemctl enable docker >/dev/null 2>&1 || true

echo "[+] Creating folders and configuration..."
sudo mkdir -p "${BASE_DIR}"
sudo chown "$USER":"$USER" "${BASE_DIR}"

for p in "${PORTS[@]}"; do
  mkdir -p "${BASE_DIR}/mysql${p}/data" "${BASE_DIR}/mysql${p}/conf.d"
  cat > "${BASE_DIR}/mysql${p}/conf.d/zz-custom.cnf" <<EOF
[mysqld]
default_authentication_plugin=mysql_native_password
# max_connections=256
EOF
done

cat > "${BASE_DIR}/.env" <<ENV
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
ENV

# docker-compose.yml with correct healthchecks using container env var
cat > "${BASE_DIR}/docker-compose.yml" <<'YAML'
services:
  mysql15000:
    image: mysql:8.0
    container_name: mysql-15000
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "15000:3306"
    volumes:
      - ./mysql15000/data:/var/lib/mysql
      - ./mysql15000/conf.d:/etc/mysql/conf.d
    healthcheck:
      test: ["CMD-SHELL","mysqladmin ping -h 127.0.0.1 -p\"$MYSQL_ROOT_PASSWORD\""]
      interval: 10s
      timeout: 5s
      retries: 10

  mysql16000:
    image: mysql:8.0
    container_name: mysql-16000
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "16000:3306"
    volumes:
      - ./mysql16000/data:/var/lib/mysql
      - ./mysql16000/conf.d:/etc/mysql/conf.d
    healthcheck:
      test: ["CMD-SHELL","mysqladmin ping -h 127.0.0.1 -p\"$MYSQL_ROOT_PASSWORD\""]
      interval: 10s
      timeout: 5s
      retries: 10

  mysql17000:
    image: mysql:8.0
    container_name: mysql-17000
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "17000:3306"
    volumes:
      - ./mysql17000/data:/var/lib/mysql
      - ./mysql17000/conf.d:/etc/mysql/conf.d
    healthcheck:
      test: ["CMD-SHELL","mysqladmin ping -h 127.0.0.1 -p\"$MYSQL_ROOT_PASSWORD\""]
      interval: 10s
      timeout: 5s
      retries: 10

  mysql18000:
    image: mysql:8.0
    container_name: mysql-18000
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    ports:
      - "18000:3306"
    volumes:
      - ./mysql18000/data:/var/lib/mysql
      - ./mysql18000/conf.d:/etc/mysql/conf.d
    healthcheck:
      test: ["CMD-SHELL","mysqladmin ping -h 127.0.0.1 -p\"$MYSQL_ROOT_PASSWORD\""]
      interval: 10s
      timeout: 5s
      retries: 10
YAML

echo "[+] Starting containers..."
cd "${BASE_DIR}"
if docker compose version >/dev/null 2>&1; then
  docker compose up -d
else
  # Very unlikely on Ubuntu 24, but just in case:
  sudo curl -fsSL -o /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/2.29.2/docker-compose-$(uname -s)-$(uname -m)"
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose up -d
fi

# Optional: open UFW ports if UFW is active
if command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -qi "Status: active"; then
  echo "[+] UFW is active; opening MySQL ports..."
  for p in "${PORTS[@]}"; do
    sudo ufw allow "${p}/tcp" || true
  done
fi

PUB_IP=$(curl -s http://checkip.amazonaws.com || echo "<YOUR_EC2_PUBLIC_IP>")
echo
echo "================= DONE ================="
echo "Data root: ${BASE_DIR}"
echo "Root password (all 4 instances): ${MYSQL_ROOT_PASSWORD}"
echo
echo "Connect (replace with your EC2 public IP if needed):"
echo "  mysql -h ${PUB_IP} -P 15000 -u root -p"
echo "  mysql -h ${PUB_IP} -P 16000 -u root -p"
echo "  mysql -h ${PUB_IP} -P 17000 -u root -p"
echo "  mysql -h ${PUB_IP} -P 18000 -u root -p"
echo
echo "Auto-start is handled by: systemd(docker) + restart: unless-stopped."


echo ${MYSQL_ROOT_PASSWORD}
echo ${MYSQL_ROOT_PASSWORD}
echo ${MYSQL_ROOT_PASSWORD}

