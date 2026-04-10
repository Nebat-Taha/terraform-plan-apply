provider "aws" {
    region = "us-east-1" # Specify desired AWS region here, e.g., us-west-2 or ap-southeast-1
}

resource "aws_eks_cluster" "managed-k8s-cluster" {
  name     = "jirasupported-k8s-cluster" # Name of the Kubernetes cluster to avoid conflicts within AWS accounts and regions. Replace with a preferred unique identifier if necessary, typically including project information as standard tags for traceability (e.g., JiraAutomationManagedK8SCluster).
  name_prefix         = "jirasupported-k8s" # Name prefix helps to identify the resources associated in AWS account and region logs/outputs when using names like 'JiraSupportedK8SKube'. Replace with a preferred unique identifier if necessary.
  
  vpc_config {
    subnet_ids         = var.subnet_ids        # Specify your Subnet IDs for the EKS cluster to reside in, typically managed through an associated VPC and appropriate route tables within AWS. These are provided as input variables or configuration files (e.g., tfvars). Replace with actual values based on environment setup; use only authorized subnets from a trusted source such as your organization's infrastructure-as-code repository for consistency in production environments, e.g., JiraAutomationSubnetIds
    security_group_ids = var.security_group_ids # Security group IDs to control traffic into and out of the EKS cluster; it’s recommended these are managed externally through IAM policies or similar mechanisms for centralized identity management (e.g., JiraAutomationSecurityGroupIds). Replace with actual values based on environment setup, ensuring only authorized access patterns align with your organization's security policy and compliance requirements
  }
  
  role_arn = var.role_arn            # Assume an IAM Role for EKS to manage the cluster (e.g., JiraAutomationEksRole). Replace it based on environment setup, ensuring trusted entities or managed identities can assume this ARN without risking misuse of resources
  name_tag = {
    Name = "JiraSupportedK8S" # EKS cluster tag for easier identification in AWS console and logs (e.g., JiraAutomationManagedEksCluster) with standard tags like Project or Component when necessary: ManagedBy, project-code here to include additional metadata; replace these as needed
  }
  
  managed_secrets = { # Define the Kubernetes secrets required by this cluster (e.g., JiraAutomationKubeDashboard) with standard tags like Project or Component when necessary: ManagedBy, project-code here to include additional metadata; replace these as needed
    jiraautomationkubedashboard = {  # Example secret for Kubernetes dashboard access (you might not need this in a production environment if accessed via IAM roles and policies)
      data = {
        password   = var.dashboard_password           # Replace with the actual generated or secured value as needed; can be retrieved from an external secrets manager like AWS Secrets Manager, encrypted into KMS for additional security within EKS cluster using Terraform variables (e.g., dashboardPassword) and avoiding hardcoding sensitive information
        username = "admin"                           # Example admin credentials or use IAM roles/credentials managed by your CI system; ensure these are rotated regularly in production settings to maintain robust security posture 
      }
    }
  }
  
  depends_on     = [ aws_iam_role.eks_cluster_assume_role ] # Depend on a role with EKS permissions (e.g., JiraAutomationEksRole) for creation, ensuring that the cluster has necessary rights to operate; replace `aws_iam_role` resource reference as needed
  enable_addon = [ "Kubectl", "AmazonEKSFargateDefaultAddonConfiguration" ] # Enable add-ons like Kubectl and EKS Fargate Default Configuration for ease of cluster management, ensuring they are also managed in your infrastructure-as-code repository; replace with actual identifiers or names if not using default AWS naming conventions
  
  tags = { ManagedBy                       # Standard tag to identify the resource created by AI Orchestrator (e.g., JiraAutomation) and related project/component metadata for consistent traceability within infrastructure management systems; replace with actual values if necessary based on standard naming conventions used in your organization
    "Project" = var.project_code # Variable representing the code name of a Terraform module or script that manages resources associated to this specific project (e.g., JiraAutomation) within an AWS account, ensuring maintainability and reusability across different projects; replace with actual unique identifier for your organization
    "Environment" = var.environment # Variable representing the environment where this cluster should reside or is currently deployed such as 'dev', 'staging', or 'prod' (e.g., JiraAutomationDevCluster); can be managed through different infrastructure-as-code repositories for isolated development, testing, and production deployments
  }
}
