resource "aws_secretsmanager_secret" "catalog_db" {
  name = "bedrock/catalog-db"
}

resource "aws_secretsmanager_secret_version" "catalog_db" {
  secret_id = aws_secretsmanager_secret.catalog_db.id
  secret_string = jsonencode({
    username = "retail_admin"
    password = random_password.db_password.result
    endpoint = "bedrock-mysql.cufyuakkkh0e.us-east-1.rds.amazonaws.com:3306"
    dbname   = "retailcatalog"
  })
}

data "aws_iam_policy_document" "eso_secrets_read" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [aws_secretsmanager_secret.catalog_db.arn]
  }
}

resource "aws_iam_policy" "eso_secrets_read" {
  name   = "bedrock-eso-secrets-read"
  policy = data.aws_iam_policy_document.eso_secrets_read.json
}

data "aws_iam_policy_document" "eso_assume_role" {
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
      values   = ["system:serviceaccount:external-secrets:external-secrets", "system:serviceaccount:retail-app:external-secrets"]
    }
  }
}

resource "aws_iam_role" "eso" {
  name               = "bedrock-eso-role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eso_secrets_read" {
  policy_arn = aws_iam_policy.eso_secrets_read.arn
  role       = aws_iam_role.eso.name
}
