<#
.SYNOPSIS
    Generate Ansible inventory from Terraform outputs (PowerShell version)
.DESCRIPTION
    Reads Terraform JSON output from stdin and generates an Ansible inventory file.
.USAGE
    cd terraform; terraform output -json | ..\scripts\Generate-Inventory.ps1 > ..\ansible\inventory.ini
#>

param()

$TF_OUTPUT = $input | Out-String | ConvertFrom-Json

$JENKINS_MASTER_IP = $TF_OUTPUT.jenkins_master_ip.value
$JENKINS_MASTER_PRIVATE_IP = $TF_OUTPUT.jenkins_master_private_ip.value
$JENKINS_AGENT_IP = $TF_OUTPUT.jenkins_agent_ip.value
$JENKINS_AGENT_PRIVATE_IP = $TF_OUTPUT.jenkins_agent_private_ip.value
$SONARQUBE_IP = $TF_OUTPUT.sonarqube_ip.value
$SONARQUBE_PRIVATE_IP = $TF_OUTPUT.sonarqube_private_ip.value
$EKS_CLUSTER_NAME = $TF_OUTPUT.eks_cluster_name.value
$EKS_CLUSTER_ENDPOINT = $TF_OUTPUT.eks_cluster_endpoint.value
$VPC_ID = $TF_OUTPUT.vpc_id.value
$PRIVATE_SUBNET_IDS = ($TF_OUTPUT.private_subnet_ids.value -join ",")
$PUBLIC_SUBNET_IDS = ($TF_OUTPUT.public_subnet_ids.value -join ",")

$SSH_USER = $env:SSH_USER ?? "ec2-user"
$SSH_KEY = $env:SSH_KEY ?? "~/.ssh/advanced-cicd.pem"

@"
# Auto-generated Ansible inventory from Terraform outputs
# Generated on: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
# DO NOT EDIT MANUALLY - Run: cd terraform; terraform output -json | ..\scripts\Generate-Inventory.ps1 > ..\ansible\inventory.ini

[jenkins_master]
$JENKINS_MASTER_IP ansible_user=$SSH_USER ansible_ssh_private_key_file=$SSH_KEY ansible_host=$JENKINS_MASTER_IP private_ip=$JENKINS_MASTER_PRIVATE_IP

[jenkins_agent]
$JENKINS_AGENT_IP ansible_user=$SSH_USER ansible_ssh_private_key_file=$SSH_KEY ansible_host=$JENKINS_AGENT_IP private_ip=$JENKINS_AGENT_PRIVATE_IP

[sonarqube]
$SONARQUBE_IP ansible_user=$SSH_USER ansible_ssh_private_key_file=$SSH_KEY ansible_host=$SONARQUBE_IP private_ip=$SONARQUBE_PRIVATE_IP

[all:vars]
# Terraform-provided values
eks_cluster_name=$EKS_CLUSTER_NAME
eks_cluster_endpoint=$EKS_CLUSTER_ENDPOINT
vpc_id=$VPC_ID
private_subnet_ids=$PRIVATE_SUBNET_IDS
public_subnet_ids=$PUBLIC_SUBNET_IDS

# SSH settings
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30'
ansible_python_interpreter=/usr/bin/python3
"@