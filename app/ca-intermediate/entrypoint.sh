#!/bin/sh
set -ex

export STEP_NO_TTY=1
echo "🚀 Starting Intermediate CA setup…"
echo "nopass" > /tmp/ca-password.txt

echo "🧪 Contents of /shared-data BEFORE:"
ls -lh /shared-data || true

# ========== INIT INTERMEDIATE CA ========== #
if [ ! -f /home/step/config/ca.json ]; then
  echo "🔧 Initializing Intermediate CA using step ca init…"
  step ca init \
    --name "Intermediate CA" \
    --dns "intermediate-ca,localhost" \
    --address ":9000" \
    --provisioner "admin" \
    --with-ca-url "https://root-ca:9000" \
    --password-file "/tmp/ca-password.txt" \
    --provisioner-password-file "/tmp/ca-password.txt" \
    --deployment-type standalone
fi

echo "📂 Contents of /shared-data AFTER INIT:"
ls -lh /shared-data || true

# ========== EXPORT INTERMEDIATE CERT + KEY ========== #
echo "📥 Copying intermediate CA cert and key…"
cp /home/step/certs/intermediate_ca.crt /shared-data/intermediate_ca.crt
cp /home/step/secrets/intermediate_ca_key /shared-data/intermediate_ca_key
chmod 644 /shared-data/intermediate_ca.crt
chmod 600 /shared-data/intermediate_ca_key

# ========== START step-ca SERVER IN BACKGROUND ========== #
echo "🛰 Starting step-ca in background..."
step-ca /home/step/config/ca.json --password-file=/tmp/ca-password.txt &
CA_PID=$!

# ========== WAIT UNTIL INTERMEDIATE CA IS HEALTHY ========== #
echo "⏳ Waiting for Intermediate CA to be ready..."
until curl -kIs https://localhost:9000/health | head -n 1 | grep -q "200"; do
  echo "… still waiting for intermediate-ca to become healthy"
  sleep 2
done

# ========== GENERATE WEB SERVER CERT ========== #
if [ ! -f /shared-data/web.crt ] || [ ! -f /shared-data/web.key ]; then
  echo "🔐 Generating leaf cert for web.itic.lan"
step ca certificate --ca-url https://localhost:9000 --provisioner admin --password-file /tmp/ca-password.txt --san web.itic.lan,itic.lan,www.itic.lan --not-after 24h web.itic.lan /shared-data/web.crt /shared-data/web.key




  chmod 644 /shared-data/web.crt /shared-data/web.key
  echo "✅ Leaf certificate generated"
else
  echo "✅ Leaf cert already exists, skipping generation"
fi

# ========== KEEP step-ca RUNNING ========== #
echo "🚀 Re-attaching to CA server..."
wait "$CA_PID"
