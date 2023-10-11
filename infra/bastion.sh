#!/usr/bin/env bash

set -euo pipefail

current_user=$(whoami)
echo "Current user is: $current_user"

export HOME=$(eval echo "~$(whoami)")

# update
dnf update -y

# install jq
dnf install -y jq

# install git
dnf install -y git

# install openssl
dnf install -y openssl

# enable ssm agent
echo "export AWS_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)" >> /etc/bashrc
echo "export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)" >> /etc/bashrc
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# install aws cli
dnf install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && ./aws/install

# install eksctl
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin

# install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

echo "helm version --short | cut -d + -f 1"

# install psql
dnf install -y postgresql15
psql --version

# install docker
dnf install -y docker
systemctl start docker
systemctl enable docker

# install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.5/2023-09-14/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
kubectl version --short --client

# write kubectl configuration to file
echo "aws eks update-kubeconfig --region eu-north-1 --name eks-cluster" > /tmp/kubeconfig.sh
chmod +x /tmp/kubeconfig.sh

# install k9s
curl -sS https://webinstall.dev/k9s | bash


