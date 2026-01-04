#!/bin/bash
set -e

echo "===== BOOTSTRAP ANSIBLE MANAGER ====="

# -----------------------------
# System update
# -----------------------------
apt-get update -y
apt-get install -y curl unzip wget software-properties-common jq

# -----------------------------
# Install AWS CLI v2
# -----------------------------
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
./aws/install

# -----------------------------
# Install Ansible
# -----------------------------
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible git

# -----------------------------
# Install CloudWatch Agent
# -----------------------------
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/ec2/ansible-manager/syslog",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF


# Proper permissions (good practice)
chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# Check if AWS CLI is installed
aws --version

# Wait for Jenkins SSH to be reachable (avoid racing Jenkins userdata)
JENKINS_IP="10.0.1.100"
echo "⏳ Waiting for Jenkins SSH on $JENKINS_IP:22 ..."
for i in {1..30}; do
  nc -z "$JENKINS_IP" 22 && echo "✅ Jenkins SSH reachable." && break
  echo "⏳ Still waiting for SSH... ($i/30)"
  sleep 10
done

# If still not reachable, stop (otherwise playbook will fail anyway)
if ! nc -z "$JENKINS_IP" 22; then
  echo "❌ Jenkins SSH not reachable after timeout."
  exit 1
fi

# -----------------------------
# Sync Ansible files from S3
# -----------------------------
ANSIBLE_DIR="/home/ubuntu/ansible"
mkdir -p $ANSIBLE_DIR

# 🔴 CHANGE ONLY THIS BUCKET NAME
S3_BUCKET="${ansible_bucket_name}"

aws s3 sync "s3://$S3_BUCKET" "$ANSIBLE_DIR"

chown -R ubuntu:ubuntu $ANSIBLE_DIR

# -----------------------------
# Fetch SSH key from SSM (keep REAL filename)
# -----------------------------
SSH_DIR="/home/ubuntu/.ssh"
KEY_PATH="$${SSH_DIR}/main_pfs_key.pem"     # ✅ EXACT name
SSM_PARAM="/pfs/ansible/ssh_key"

mkdir -p "$${SSH_DIR}"
chown ubuntu:ubuntu "$${SSH_DIR}"
chmod 700 "$${SSH_DIR}"

for i in {1..10}; do
  aws ssm get-parameter --name "$SSM_PARAM" --with-decryption \
    --query "Parameter.Value" --output text > "$${KEY_PATH}" 2>/dev/null || true

  if [ -s "$${KEY_PATH}" ]; then
    chown ubuntu:ubuntu "$${KEY_PATH}"
    chmod 600 "$${KEY_PATH}"
    echo "✅ SSH key ready at $${KEY_PATH}"
    break
  fi

  echo "⏳ SSH key not ready, retrying..."
  rm -f "$${KEY_PATH}"
  sleep 5
done

if [ ! -s "$${KEY_PATH}" ]; then
  echo "❌ Failed to fetch SSH key from SSM"
  exit 1
fi

# quick sanity check (helps debugging in cloud-init logs)
echo "📌 Ansible dir content:"
ls -lah "$ANSIBLE_DIR"
echo "📌 Playbooks:"
ls -lah "$ANSIBLE_DIR/playbooks" || true


# -----------------------------
# Run playbook automatically
# -----------------------------
cd "$${ANSIBLE_DIR}"
sudo -u ubuntu ansible-playbook -i inventory.ini playbooks/jenkins.yml -vv
  

echo "===== ANSIBLE MANAGER READY ====="
