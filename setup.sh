#!/bin/bash

echo "=== Setting up PostgreSQL ==="
apt-get install -y postgresql redis-server > /dev/null 2>&1
service postgresql start
service redis-server start

# Setup postgres without password prompt
su - postgres -c "psql -c \"CREATE USER \\\"someUser\\\" WITH PASSWORD 'somePassword';\"" 2>/dev/null || true
su - postgres -c "psql -c \"CREATE DATABASE cetus OWNER \\\"someUser\\\";\"" 2>/dev/null || true

echo "=== PostgreSQL and Redis ready ==="

echo "=== Setting up Backend ==="
cd /workspaces/bookish-eureka/backend

# Fix .env
cat > .env << 'EOF'
NODE_ENV = production
port = 4000

dbHost = 127.0.0.1
dbPort = 5432
dbUsername = someUser
dbPassword = somePassword
db = cetus
dbSync = true

redisPassword =

verificationApiKey = sekret
internalKey = sekret
sendgridKey = SG.placeholder

backendUrl = http://localhost:4000
frontendUrl = http://localhost:1234
discordBotUrl = http://localhost:5000
cookieDomain = localhost

discordClientId = 123
discordClientSecret = placeholder
discordBotApiKey = sekret

discordInvite = https://discord.gg/placeholder

stripeKey = placeholder
paymentCompleteStripeSecret = placeholder
subscriptionDeleteStripeSecret = placeholder

alertWebhook = https://discord.com/placeholder
EOF

npm install --legacy-peer-deps
npm start &
BACKEND_PID=$!
echo "Backend running on port 4000 (PID $BACKEND_PID)"

echo "=== Setting up Frontend ==="
cd /workspaces/bookish-eureka/frontend

# Get the codespace name for the backend URL
CODESPACE_URL="https://${CODESPACE_NAME}-4000.app.github.dev"
echo "Backend URL: $CODESPACE_URL"

cat > .env << EOF
BACKEND_URL=${CODESPACE_URL}
discordInvite=https://discord.gg/placeholder
STRIPE_PK=placeholder
EOF

npm install --legacy-peer-deps
npm run dev