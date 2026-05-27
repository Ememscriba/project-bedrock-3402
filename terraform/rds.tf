resource "aws_db_subnet_group" "db_subnets" {
  name       = "project-bedrock-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  tags = {
    Name = "project-bedrock-db-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "project-bedrock-db-sg"
  description = "Allow inbound database traffic from EKS"
  vpc_id      = aws_vpc.bedrock_vpc.id

  ingress {
    description = "MySQL port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.bedrock_vpc.cidr_block]
  }

  ingress {
    description = "PostgreSQL port"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.bedrock_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-bedrock-db-sg"
  }
}

resource "aws_ssm_parameter" "mysql_pass" {
  name  = "/retail-app/mysql/password"
  type  = "SecureString"
  value = "BedrockSecureMySql2025!"
}

resource "aws_ssm_parameter" "postgres_pass" {
  name  = "/retail-app/postgres/password"
  type  = "SecureString"
  value = "BedrockSecurePostgres2025!"
}

resource "aws_db_instance" "mysql" {
  identifier             = "bedrock-mysql"
  allocated_storage      = 20
  max_allocated_storage  = 50
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro"
  db_name                = "orders"
  username               = "retail_admin"
  password               = aws_ssm_parameter.mysql_pass.value
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  tags = {
    Name = "bedrock-mysql"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "bedrock-postgres"
  allocated_storage      = 20
  max_allocated_storage  = 50
  engine                 = "postgres"
  engine_version         = "15.8"
  instance_class         = "db.t4g.micro"
  db_name                = "catalog"
  username               = "retail_admin"
  password               = aws_ssm_parameter.postgres_pass.value
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  tags = {
    Name = "bedrock-postgres"
  }
}

resource "aws_dynamodb_table" "carts" {
  name         = "bedrock-carts-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "bedrock-carts-table"
  }
}
