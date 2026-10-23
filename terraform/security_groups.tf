# Security group for the Jenkins master.
resource "aws_security_group" "jenkins_master" {
  name        = "${var.project_name}-${var.environment}-jenkins-master-sg"
  description = "Security group for the Jenkins master instance."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow Jenkins web UI access from approved CIDRs"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Allow SSH access from approved CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  dynamic "ingress" {
    for_each = var.bastion_security_group_id != null ? [1] : []
    content {
      description     = "Allow SSH access from bastion SG"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [var.bastion_security_group_id]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-master-sg"
  }
}

# Security group for the Jenkins build agent.
resource "aws_security_group" "jenkins_agent" {
  name        = "${var.project_name}-${var.environment}-jenkins-agent-sg"
  description = "Security group for the Jenkins agent instance."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH access from approved CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  dynamic "ingress" {
    for_each = var.bastion_security_group_id != null ? [1] : []
    content {
      description     = "Allow SSH access from bastion SG"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [var.bastion_security_group_id]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-agent-sg"
  }
}

# Security group for the Ansible controller host.
resource "aws_security_group" "ansible_controller" {
  name        = "${var.project_name}-${var.environment}-ansible-controller-sg"
  description = "Security group for the Ansible controller instance."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH access from approved CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  dynamic "ingress" {
    for_each = var.bastion_security_group_id != null ? [1] : []
    content {
      description     = "Allow SSH access from bastion SG"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [var.bastion_security_group_id]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ansible-controller-sg"
  }
}
