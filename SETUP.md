# Setup and Deployment Guide

## Prerequisites

Ensure all prerequisites are installed:

```bash
# Java 17 JDK
java -version

# Maven 3.9.4
mvn -version

# Docker
docker --version

# Kubernetes CLI
kubectl version --client

# Terraform
terraform version

# Ansible
ansible --version

# AWS CLI
aws --version
```

## Initial Configuration

### 1. AWS Setup

Configure AWS credentials:

```bash
aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region (us-east-1)
# Enter: Default output format (json)
```

Create EC2 key pair if not exists:

```bash
aws ec2 create-key-pair --key-name advanced-cicd --region us-east-1 --query 'KeyMaterial' --output text > ~/.ssh/advanced-cicd.pem
chmod 600 ~/.ssh/advanced-cicd.pem
```

### 2. Terraform Configuration

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Initialize Terraform:

```bash
terraform init
```

Review infrastructure plan:

```bash
terraform plan -var="key_name=advanced-cicd"
```

Apply infrastructure:

```bash
terraform apply -var="key_name=advanced-cicd"
```

Terraform will output instance IPs and DNS names. Save these for next steps.

### 3. Ansible Configuration

Generate inventory automatically from Terraform outputs:

```bash
cd ../ansible
# Linux/macOS:
../scripts/generate_inventory.sh < ../terraform/terraform_output.json > inventory.ini
# Or from terraform directory:
cd ../terraform && terraform output -json | ../scripts/generate_inventory.sh > ../ansible/inventory.ini

# Windows PowerShell:
cd ..\terraform; terraform output -json | ..\scripts\Generate-Inventory.ps1 > ..\ansible\inventory.ini
```

Test connectivity:

```bash
ansible all -i inventory.ini -m ping
```

Run configuration:

```bash
ansible-playbook -i inventory.ini playbooks/site.yml
```

### 4. Jenkins Setup

Access Jenkins at `http://<jenkins-master-ip>:8080`

Initial admin password:

```bash
ssh -i ~/.ssh/advanced-cicd.pem ec2-user@<jenkins-master-ip>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### Install Jenkins Plugins

1. Manage Jenkins → Plugin Manager
2. Install:
   - SonarQube Scanner
   - Artifactory
   - Docker
   - Kubernetes CLI

#### Create Build Agent

1. Manage Jenkins → Manage Nodes and Clouds
2. New Node:
   - Node name: `maven-agent`
   - Type: Permanent Agent
   - Labels: `maven`
   - Launch method: SSH

#### Configure Credentials

1. Jenkins Dashboard → Manage Jenkins → Manage Credentials
2. Add credentials:

   **SonarQube Token** (Kind: Secret text)
   - ID: `sonarqube-token`

   **Docker Registry** (Kind: Username with password)
   - ID: `dockerhub-credentials`

#### Add Pipeline Job

1. New Item → Pipeline
2. Pipeline script from SCM:
   - SCM: Git
   - Repository URL: Your Git repository
   - Branch: `*/main`
   - Script path: `Jenkinsfile`

### 5. Application Build

```bash
cd ../app
mvn clean package
```

Verify JAR creation:

```bash
ls -lh target/advanced-cicd-app-2.0.0.jar
```

### 6. Docker Build

```bash
cd ..
docker build -t advanced-cicd-app:2.0.0 .
```

Verify image:

```bash
docker images | grep advanced-cicd-app
```

### 7. Kubernetes Cluster Setup

Create kubeconfig:

```bash
aws eks update-kubeconfig --region us-east-1 --name advanced-cicd-cluster
```

Verify access:

```bash
kubectl cluster-info
kubectl get nodes
```

Create namespace and secret:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
```

### 8. Deployment

Deploy application:

```bash
./deploy.sh
```

Verify deployment:

```bash
kubectl get deployments -n advanced-cicd
kubectl get pods -n advanced-cicd
kubectl get svc -n advanced-cicd
```

Get LoadBalancer URL:

```bash
kubectl get svc -n advanced-cicd -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

## Verification

### Application Health

```bash
LOAD_BALANCER_URL=$(kubectl get svc -n advanced-cicd -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
curl http://$LOAD_BALANCER_URL
curl http://$LOAD_BALANCER_URL/actuator/health
```

### Pod Logs

```bash
kubectl logs -f deployment/advanced-cicd-app -n advanced-cicd
```

### Resource Usage

```bash
kubectl top nodes
kubectl top pods -n advanced-cicd
```

## Post-Deployment

### Enable Monitoring

Configure Prometheus to scrape Kubernetes metrics:

```bash
kubectl apply -f monitoring/prometheus-values.yaml
```

Configure Grafana dashboards:

```bash
kubectl apply -f monitoring/grafana-dashboard.json
```

### Set Up Notifications

Configure Jenkins email notifications:

1. Manage Jenkins → System → Email Notifications
2. SMTP Server: Your mail server
3. Default user email suffix: @your-domain.com

### Backup Terraform State

Configure S3 backend in `terraform/versions.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "advanced-cicd/prod/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-lock"
  encrypt        = true
}
```

Migrate state:

```bash
terraform init -migrate-state
```

## Troubleshooting

### Terraform Issues

```bash
terraform validate
terraform plan -json | jq '.diagnostics'
```

### Ansible Issues

```bash
ansible-playbook -i inventory.ini playbooks/site.yml -vv
```

### Jenkins Pipeline Failures

- Check build logs in Jenkins UI
- Review application logs: `kubectl logs <pod-name> -n advanced-cicd`
- Verify credentials are correctly configured

### Kubernetes Issues

```bash
kubectl describe pod <pod-name> -n advanced-cicd
kubectl get events -n advanced-cicd
```

## Cleanup

Destroy all infrastructure:

```bash
cd terraform
terraform destroy -var="key_name=advanced-cicd"
```
