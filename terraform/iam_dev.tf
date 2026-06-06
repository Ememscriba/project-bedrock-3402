resource "aws_iam_user" "dev_user" {
  name = "bedrock-dev-view"
  tags = {
    Name = "bedrock-dev-view"
  }
}

resource "aws_iam_user_policy_attachment" "dev_readonly" {
  user       = aws_iam_user.dev_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy" "dev_s3_put" {
  name = "bedrock-dev-s3-put"
  user = aws_iam_user.dev_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:PutObject"
      Resource = "arn:aws:s3:::bedrock-assets-3402/*"
    }]
  })
}

resource "aws_iam_user_login_profile" "dev_login" {
  user                    = aws_iam_user.dev_user.name
  password_reset_required = false
}

resource "aws_iam_access_key" "dev_keys" {
  user = aws_iam_user.dev_user.name
}
