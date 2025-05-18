#!/bin/sh
set -e

export STEP_NO_TTY=1

echo "🚀 Starting Root CA setup…"

echo "nopass" > /tmp/ca-password.txt

if [ ! -f /home/step/config/ca.json ]; then
  echo "🔧 Running step ca init for Root CA…"
  step ca init \
    --name="Root CA" \
    --dns="root-ca" \
    --address=":9000" \
    --provisioner="admin" \
    --with-ca-url="https://root-ca:9000" \
    --no-db \
    --deployment-type="standalone" \
    --password-file="/tmp/ca-password.txt" \
    --provisioner-password-file="/tmp/ca-password.txt"
fi

cp /home/step/certs/root_ca.crt /shared-data/root_ca.crt
cp /home/step/secrets/root_ca_key /shared-data/root_ca_key
chmod 644 /shared-data/root_ca.crt
chmod 600 /shared-data/root_ca_key

echo "✅ Root CA ready and keys exported"
exec step-ca /home/step/config/ca.json --password-file=/tmp/ca-password.txt
