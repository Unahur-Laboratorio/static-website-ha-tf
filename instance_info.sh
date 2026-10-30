#!/bin/bash
set -euo pipefail

TOKEN=$(curl -fsS -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -fsS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -fsS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -fsS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)
LOCAL_HOSTNAME=$(curl -fsS -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-hostname)

cat > /var/www/html/instance-info.html <<EOF
<h2>Hostname: ${LOCAL_HOSTNAME}</h2>
<h2>IP address: ${PRIVATE_IP}</h2>
<h2>Instance ID: ${INSTANCE_ID}</h2>
<h2>AZ: ${AZ}</h2>
EOF

chown apache:apache /var/www/html/instance-info.html
chmod 644 /var/www/html/instance-info.html
systemctl restart httpd