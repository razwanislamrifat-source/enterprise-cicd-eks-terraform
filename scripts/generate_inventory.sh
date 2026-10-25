#!/usr/bin/env bash
set -euo pipefail

# Generate Ansible inventory from Terraform outputs
# Usage: cd terraform && terraform output -json | ../scripts/generate_inventory.sh > ../ansible/inventory.ini

# Read JSON from stdin
TF_OUTPUT=$(cat)

# Extract values using jq
JENKINS_MASTER_IP=$(echo "${TF_OUTPUT}" | jq -r '.jenkins_master_ip.value // empty')
JENKINS_MASTER_PRIVATE_IP=$(echo "${TF_OUTPUT}" | jq -r '.jenkins_master_private_ip.value // empty')
JENKINS_AGENT_IP=$(echo "${TF_OUTPUT}" | jq -r '.jenkins_agent_ip.value // empty')
JENKINS_AGENT_PRIVATE_IP=$(echo "${TF_OUTPUT}" | jq -r '.jenkins_agent_private_ip.value // empty')
SONARQUBE_IP=$(echo "${TF_OUTPUT}" | jq -r '.sonarqube_ip.value // empty')
SONARQUBE_PRIVATE_IP=$(echo "${TF_OUTPUT}" | jq -r '.sonarqube_private_ip.value // empty')
EKS_CLUSTER_NAME=$(echo "${TF_OUTPUT}" | jq -r '.eks_cluster_name.value // empty')
EKS_CLUSTER_ENDPOINT=$(echo "${TF_OUTPUT}" | jq -r '.eks_cluster_endpoint.value // empty')
VPC_ID=$(echo "${TF_OUTPUT}" | jq -r '.vpc_id.value // empty')
PRIVATE_SUBNET_IDS=$(echo "${TF_OUTPUT}" | jq -r '.private_subnet_ids.value // [] | join(",")')
PUBLIC_SUBNET_IDS=$(echo "${TF_OUTPUT}" | jq -r '.public_subnet_ids.value // [] | join(",")')

# Default SSH user and key
SSH_USER="${SSH_USER:-ec2-user}"
SSH_KEY="${SSH_KEY:-~/.ssh/advanced-cicd.pem}"

cat <<EOF
# Auto-generated Ansible inventory from Terraform outputs
# Generated on: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# DO NOT EDIT MANUALLY - Run: cd terraform && terraform output -json | ../scripts/generate_inventory.sh > ../ansible/inventory.ini

[jenkins_master]
${JENKINS_MASTER_IP} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY} ansible_host=${JENKINS_MASTER_IP} private_ip=${JENKINS_MASTER_PRIVATE_IP}

[jenkins_agent]
${JENKINS_AGENT_IP} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY} ansible_host=${JENKINS_AGENT_IP} private_ip=${JENKINS_AGENT_PRIVATE_IP}

[sonarqube]
${SONARQUBE_IP} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY} ansible_host=${SONARQUBE_IP} private_ip=${SONARQUBE_PRIVATE_IP}

[all:vars]
# Terraform-provided values
eks_cluster_name=${EKS_CLUSTER_NAME}
eks_cluster_endpoint=${EKS_CLUSTER_ENDPOINT}
vpc_id=${VPC_ID}
private_subnet_ids=${PRIVATE_SUBNET_IDS}
public_subnet_ids=${PUBLIC_SUBNET_IDS}

# SSH settings
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30'
ansible_python_interpreter=/usr/bin/python3
EOF