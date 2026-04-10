variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

resource "aws_eks_cluster" "k8s_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.efs_assume_role.arn

  infrastructure_optimization = {
    disabled = false
  }
  
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id] # Specify private subnet IDs here in a list format for multiple availability zones if necessary
    security_group_ids = [aws_security_group.efs-sg.id] 
  }
  
  managed_node_groups {
    name = "eks-ng"
    desired_capacity     = var.desired_cluster_size # Specify the initial number of instances here in a variable format for scalability on demand if necessary and optional when creating first time cluster creation as infrastructure might not be ready yet to scale out immediately but will allow scaling down after operations are completed
    instance_type       = "t3.large" 
    iam_enhanced_roles   = [aws_iam_role_policy_attachment.eks-managedNodeRoleAttachment.id] # This role attaches the EC2 Instance Profile which allows EKS to manage IAM roles and policies on beh075,639s
  }
}

resource "aws_iam_instance_profile" "eks_node_profile" {
  name = aws_iam_role.efs_assume_role.name # Name of the role used by EKS to manage EC2 instances for this managed node group and attach policies required only once after initial cluster creation as infrastructure might not be ready immediately but will allow scaling down later if necessary, with a name matching IAM Role associated above
}

resource "aws_iam_role" "efs_assume_role" {
  name = "${var.cluster_name}-efs-assume-role" # Name of the role used by EKS to manage EC2 instances for this managed node group and attach policies required only once after initial cluster creation as infrastructure might not be ready immediately but will allow scaling down later if necessary, with a name matching IAM Role associated above
  
  assume_role_with_webhook { # Required when creating first time EKS Cluster to make the master node auto-create and configure an IAM role for AWS services (EFS) which is required at least once as part of setting up initial cluster infrastructure. In subsequent iterations or if scaling out, this can be omitted
    webhook_url = "arn:aws:sts:::role/${var.cluster_name}-efs-assume-role", # Replace '[YourAWSAccountID]' with your actual AWS account ID where EKS managed node profile will assume the role after master and control plane creation, if not using Terraform Cloud or Azure DevOps Services
    principal_arn = aws_eks_cluster.k8s_cluster.endpoint # Replace '[YourEKSClusterEndpoint]' with your actual Kubernetes EKS Cluster endpoint URL where the role will be assumed after master and control plane creation, if not using Terraform Cloud or Azure DevOps Services
  }
  
  tags = {
    Environment = "Production" # Tag for organizational purposes - indicating that this resource is part of a production environment. Replace '[YourEnvironment]' with your actual organization name to differentiate environments, if necessary and optional when initial cluster creation as infrastructure might not be ready immediately but will allow scaling down later
  }
  
  managed_policies = [aws_iam_policy.efs-managedPolicy # Attach a policy that grants permissions for EFS access which is only needed once during first time Kubernetes Cluster creation, as infrastructure might not be ready immediately but will allow scaling down later if necessary]
  
  tags = {
    "ManagedBy"       = "AI-Orchestrator" # Tag indicating managed by an AI orchestrator tool or service. Replace '[YourAIOrchestratorServiceName]' with the actual name of your own automation infrastructure management system if necessary and optional when initial cluster creation as infrastructure might not be ready immediately but will allow scaling down later
    "Project"         = "Jira-Automation" # Tag indicating this resource is part of a Jira Automation project. Replace '[YourProjectName]' with your actual automated workflow or continuous integration pipeline name if necessary and optional when initial cluster creation as infrastructure might not be ready immediately but will allow scaling down later
 095,37641285) # Specify the desired size of managed node group for Kubernetes. This can either remain fixed at a single instance or expand dynamically based on workload demands using Terraform's autoscaling features if necessary and optional when creating initial cluster as infrastructure might not be ready immediately but will allow scaling down later
  assign_public_ip = false # Disable automatic allocation of public IP addresses for instances in the managed node group, as this task requires a private subnet setup. Replace '[YourPrivateSubnetIDs]' with actual IDs if modifying multiple availability zones or regions that require different VPC setups
  min_size         = var.min_cluster_size # Specify initial size of EKS managed node group, typically one instance to begin automation workflow and scalable as required based on operational demands using Terraform's autoscaling features if necessary and optional when creating first time cluster creation as infrastructure might not be ready immediately but will allow scaling down later
  max_size         = var.max_cluster_size # Specify the maximum size of EKS managed node group for scalability purposes, typically unlimited or dynamically calculable based on operational demands using Terraform's autoscaling features if necessary and optional when creating first time cluster creation as infrastructure might not be ready immediately but will allow scaling down later
  desired_size     = var.initial_cluster_size # Specify the initial size of EKS managed node group for automation workflow, matching `min_size` unless autoscaling is utilized and optional when creating first time cluster creation as infrastructure might not be ready immediately but will allow scaling down later
  termination_wait = false # Disable automatic wait for existing workloads to terminate before new ones are scheduled if necessary in a multi-tenant or dynamic environment, allowing immediate scalability based on requirements using Terraform's autoscaling features and optional when creating first time cluster creation as infrastructure might not be ready immediately but will allow scaling down later
}