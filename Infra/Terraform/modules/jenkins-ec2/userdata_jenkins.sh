#!/bin/bash
set -euo pipefail

LOG="/var/log/user-data-jenkins.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== Jenkins EC2 userdata: start ==="

# -----------------------------
# Base packages
# -----------------------------
apt-get update -y
apt-get upgrade -y
apt-get install -y \
  ca-certificates curl gnupg lsb-release unzip apt-transport-https \
  git jq

# -----------------------------
# Java (Jenkins needs Java)
# Ubuntu Jammy repo provides Java 17
# -----------------------------
apt-get install -y openjdk-17-jdk

# -----------------------------
# Additional utilities
apt-get install -y unzip curl git jq netcat-openbsd


# -----------------------------
# AWS CLI v2 (ECR login / push, etc.)
# -----------------------------
curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -rf /tmp/aws /tmp/awscliv2.zip

# ----------------------------------
# Terraform (HashiCorp official repo)
# ----------------------------------
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| tee /etc/apt/sources.list.d/hashicorp.list

apt-get update -y
apt-get install -y terraform

# -----------------------------
# Jenkins (official repo)
# -----------------------------
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | tee /etc/apt/keyrings/jenkins-keyring.asc >/dev/null

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | tee /etc/apt/sources.list.d/jenkins.list >/dev/null

apt-get update -y
apt-get install -y jenkins

# -----------------------------
# Docker CE + buildx (FORCE UPGRADE)  ✅
# -----------------------------

# Remove any potentially old/conflicting Docker packages first
apt-get remove -y docker docker-engine docker.io containerd runc docker-compose docker-compose-plugin podman-docker || true
apt-get purge  -y docker docker-engine docker.io containerd runc docker-compose docker-compose-plugin podman-docker || true
apt-get autoremove -y || true
rm -f /etc/apt/sources.list.d/docker.list || true
rm -f /etc/apt/keyrings/docker.gpg || true

# Docker official repo
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

CODENAME="$(. /etc/os-release; echo "$VERSION_CODENAME")"
ARCH="$(dpkg --print-architecture)"

echo "deb [arch=$${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $${CODENAME} stable" \
  | tee /etc/apt/sources.list.d/docker.list >/dev/null

apt-get update -y

# Force install/upgrade to latest from Docker repo
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
apt-get install -y --only-upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin || true

# Enable BuildKit by default
mkdir -p /etc/docker
cat >/etc/docker/daemon.json <<'JSON'
{
  "features": { "buildkit": true }
}
JSON

# Ensure docker group exists + add jenkins
getent group docker || groupadd docker
usermod -aG docker jenkins

systemctl daemon-reload
systemctl enable docker
systemctl restart docker

# Make sure Jenkins picks up docker group membership
systemctl restart jenkins || true

# Quick debug in cloud-init logs
docker version || true
docker info || true


# -----------------------------
# kubectl (client)
# -----------------------------
KUBECTL_VERSION="$(curl -sL https://dl.k8s.io/release/stable.txt)"
curl -sL "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

# -----------------------------
# Helm
# -----------------------------
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# -----------------------------
# Enable & start Jenkins
# -----------------------------
systemctl enable jenkins
systemctl restart jenkins

echo "=== Jenkins EC2 userdata: done ==="
echo "Jenkins should be on port 8080."
