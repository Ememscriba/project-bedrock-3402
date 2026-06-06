resource "aws_cloudwatch_log_group" "eks_log_group" {
  name              = "/aws/eks/project-bedrock-cluster/cluster"
  retention_in_days = 7
  tags = {
    Name = "project-bedrock-eks-logs"
  }
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = aws_eks_cluster.bedrock.name
  addon_name   = "amazon-cloudwatch-observability"

  depends_on = [
    aws_eks_node_group.bedrock_nodes
  ]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.bedrock.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.bedrock.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "lb_controller_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lb_controller" {
  name               = "project-bedrock-lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role.json
}

data "http" "lb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.lb_controller_policy.response_body
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  policy_arn = aws_iam_policy.lb_controller.arn
  role       = aws_iam_role.lb_controller.name
}
