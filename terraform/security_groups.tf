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
    description = "Allow outbound traffic to VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
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
    description = "Allow outbound traffic to VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
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
    description = "Allow outbound traffic to VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ansible-controller-sg"
  }
}

# Security group for the EKS cluster control plane.
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
  description = "Security group for the EKS cluster control plane."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow Kubernetes API access from approved CIDRs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Allow worker nodes to communicate with control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    description = "Allow outbound traffic to VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-cluster-sg"
  }
}

# Security group for the EKS worker nodes.
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-${var.environment}-eks-nodes-sg"
  description = "Security group for the EKS worker nodes."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all traffic from cluster control plane"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    description = "Allow node-to-node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  ingress {
    description = "Allow SSH access from approved CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic to VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-nodes-sg"
  }
}
