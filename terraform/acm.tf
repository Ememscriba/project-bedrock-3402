resource "aws_acm_certificate" "bedrock" {
  domain_name       = "store.saphigen.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

output "acm_validation_records" {
  value = {
    for dvo in aws_acm_certificate.bedrock.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}
