# Dynamic AMI selection using Amazon Linux 2 or Amazon Linux 2023.
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  selected_ami = data.aws_ami.amazon_linux_2.id
}

# Jenkins master instance that hosts the CI/CD controller.
resource "aws_instance" "jenkins_master" {
  ami                         = local.selected_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_master.id]
  associate_public_ip_address = true
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  volume_tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-master-root"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-master"
    role = "jenkins_master"
  }
}

# Jenkins agent instance used for distributed build and deployment workloads.
resource "aws_instance" "jenkins_agent" {
  ami                         = local.selected_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_agent.id]
  associate_public_ip_address = true
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  volume_tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-agent-root"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-agent"
    role = "jenkins_agent"
  }
}

# Ansible controller instance used to manage remote configuration tasks.
resource "aws_instance" "ansible_controller" {
  ami                         = local.selected_ami
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ansible_controller.id]
  associate_public_ip_address = true
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 16
    encrypted   = true
  }

  volume_tags = {
    Name = "${var.project_name}-${var.environment}-ansible-controller-root"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ansible-controller"
    role = "ansible_controller"
  }
}
