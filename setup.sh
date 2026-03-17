#!/bin/bash
  set -e
  echo "=== Jigar Alpha Scanner — Vultr Mumbai Setup ==="

  # 1. Update system
  apt-get update -y && apt-get upgrade -y

  # 2. Install Docker
  apt-get install -y ca-certificates curl gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | tee /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable docker && systemctl start docker

  # 3. Open port 8080
  ufw allow 22/tcp
  ufw allow 8080/tcp
  ufw --force enable

  # 4. Create app folder
  mkdir -p ~/jigar-alpha/dist
  cd ~/jigar-alpha

  # 5. Download built server from GitHub
  curl -L https://github.com/jigarn90/jigar-scanner/raw/main/dist/index.cjs -o dist/index.cjs
  echo "Downloaded dist/index.cjs: $(du -sh dist/index.cjs | cut -f1)"

  # 6. Write Dockerfile
  cat > Dockerfile << 'DOCKERFILE'
  FROM node:20-alpine
  WORKDIR /app
  COPY dist/index.cjs ./dist/
  ENV NODE_ENV=production
  ENV PORT=8080
  EXPOSE 8080
  CMD ["node", "dist/index.cjs"]
  DOCKERFILE

  # 7. Write docker-compose.yml
  cat > docker-compose.yml << 'COMPOSE'
  version: "3.9"
  services:
    scanner:
      image: jigar-alpha-scanner:latest
      container_name: jigar-alpha-scanner
      restart: always
      ports:
        - "8080:8080"
      env_file:
        - .env
  volumes:
    scanner-db:
  COMPOSE

  echo ""
  echo "=== Setup complete! ==="
  echo "Now create your .env file:"
  echo "  nano ~/jigar-alpha/.env"
  echo ""
  echo "Then build and start:"
  echo "  cd ~/jigar-alpha"
  echo "  docker build -t jigar-alpha-scanner ."
  echo "  docker compose up -d"
  echo "  docker compose logs -f"
  