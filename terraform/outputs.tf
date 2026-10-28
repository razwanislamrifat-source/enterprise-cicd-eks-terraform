# Public IP address of the Jenkins master instance.
output "jenkins_master_ip" {
  description = "Public IP address assigned to the Jenkins master instance."
  value       = aws_instance.jenkins_master.public_ip
}

# Private IP address of the Jenkins master instance.
output "jenkins_master_private_ip" {
  description = "Private IP address assigned to the Jenkins master instance."
  value       = aws_instance.jenkins_master.private_ip
}

# Public IP address of the Jenkins agent instance.
output "jenkins_agent_ip" {
  description = "Public IP address assigned to the Jenkins agent instance."
  value       = aws_instance.jenkins_agent.public_ip
}

# Private IP address of the Jenkins agent instance.
output "jenkins_agent_private_ip" {
  description = "Private IP address assigned to the Jenkins agent instance."
  value       = aws_instance.jenkins_agent.private_ip
}

# Public IP address of the SonarQube instance.
output "sonarqube_ip" {
  description = "Public IP address assigned to the SonarQube instance."
  value       = aws_instance.sonarqube.public_ip
}

# Private IP address of the SonarQube instance.
output "sonarqube_private_ip" {
  description = "Private IP address assigned to the SonarQube instance."
  value       = aws_instance.sonarqube.private_ip
}

# Identifier of the VPC created for the project.
output "vpc_id" {
  description = "ID of the VPC provisioned for the Advanced CI/CD environment."
  value       = aws_vpc.main.id
}

# Public subnet IDs.
output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = aws_subnet.public[*].id
}

# Private subnet IDs (for EKS node groups).
output "private_subnet_ids" {
  description = "List of private subnet IDs for EKS worker nodes."
  value       = aws_subnet.private[*].id
}

# NAT Gateway IDs.
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs."
  value       = aws_nat_gateway.main[*].id
}

# EKS Cluster name.
output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

# EKS Cluster endpoint.
output "eks_cluster_endpoint" {
  description = "Endpoint URL for the EKS cluster control plane."
  value       = aws_eks_cluster.main.endpoint
}

# EKS Cluster ARN.
output "eks_cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.main.arn
}

# EKS Cluster certificate authority data.
output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the EKS cluster."
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

# EKS Node Group name.
output "eks_node_group_name" {
  description = "Name of the EKS node group."
  value       = aws_eks_node_group.main.node_group_name
}

# Security Group IDs.
output "eks_cluster_security_group_id" {
  description = "Security Group ID for the EKS cluster control plane."
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_security_group_id" {
  description = "Security Group ID for the EKS worker nodes."
  value       = aws_security_group.eks_nodes.id
}

output "jenkins_security_group_id" {
  description = "Security Group ID for Jenkins instances."
  value       = aws_security_group.jenkins.id
}

output "sonarqube_security_group_id" {
  description = "Security Group ID for SonarQube instance."
  value       = aws_security_group.sonarqube.id
}