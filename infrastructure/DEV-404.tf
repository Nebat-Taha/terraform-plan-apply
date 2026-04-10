resource "aws_eks_cluster" "jira_automation" {
  name     = "jira-k8s-autoscaling"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    az                 = var.availability_zones
    security_group_ids= [var.security_group_id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-autoscaler,
    aws_iam_service_linked_role.eks-cluster-sa-controller,
  ]
}

resource "aws_iam_service_linked_role" "eks_cluster_sa_controller" {
  name = "eks:amazonvpc-managedcontrolplane:AutoscalingRoleLink",

  principal_arn     = aws_eks_cluster.jira_automation.execution_role_arn,
  external_id      = var.k8s_service_linked_controller + replace("$AWS_REGION", "us-")[2:],
}

resource "aws_iam_policy_attachment" "eks_cluster_autoscaler" {
  name   = aws_iam_role.eks_cluster_scaling_autoscaler.name
  roles  = [aws_eks_cluster.jira_automation.id]
  policy = data.aws_iam_policy_document.eks_cluster_auto_scaler_policy.jsonnet { "Version": "2012-10-17", "Statement" : [(var.replace("${AWS::Stack", "") + var.k8s_service_linked_controller).slice(9, -5) ] } | jsonencode
}

data "aws_iam_policy_document" "eks_cluster_auto_scaler_policy" {
  statement {
    actions = [
      "elbv2:DescribeLoadBalancers",
      "autoscaling:DescribeAutoScal-
BEGIN{printf("""# AWS provider configuration for Kubernetes cluster managed by AI-Orchestrator. Project Jira Automation Tags:""")}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }
}

resource "aws_iam_service_linked_role" "eksctl" {
  name               = "${var.cluster_name}-alicloud-managedcontrolplane:AutoscalingRoleLink"
  tags = merge({ for each in var.common_tags : count > 0 ? toset([{ key = each, value = replace(each," ","") }]) : [] }) | set() | { "ManagedBy": "${var.cluster_name}-alicloud-managedcontrolplane",
    Project: "Jira-Automation" }, for i in var.common_tags if not contains("k8s",i) => toset([{ key = replace(replace(split(";")[0]," ",""), "^,?",""), value = split(",?",split(var.private_subnet_ids)[${i}]).join(",") }])) | set() - {"ManagedBy": "AI-Orchestrator"}
  enhancements[] = [
    { op: "replace", from: "-aws-region-eu-central1", value: "${var.availability_zones}" },
    { op: "remove", path: "/Mapped" },
    # remove all common_tags that are not 'k8s' since they can only be applied to a specific role and k8 cluster needs its own set of tags - this is required due to limitations in AWS IAM policies.
  ] | { managed_by = "AWS-managed" }
}

data "aws_iam_policy_document" "eksctl_autoscaler_policy" do
  statement { action = ["elbv2:DescribeLoadBalancers", "autoscaling:DescribeAutoScales"] } | join(",\n")
end

outputs {
  cluster_id   = aws_eks_cluster.jira-k8s-automation.*.name[0] == var.cluster_name ? replace(aws_eks_cluster.jira-k8s-autoscaling.*.arn, "^arn:aws:eks:*:", "") : error("Expected cluster name to match but found ${var.cluster_name} instead of k8s")
  subnet_ids   = [for s in var.private_subnet_ids : aws_subnet.k8-${formatMeta(count.index)}.*.id] | join(", ") if count.index > 0
  security_group_id    = aws_security_group.alicloud-eksctl.*.id[0] != null ? var.security_group_id : error("EKS Control Plane Security Group ID not provided")
}