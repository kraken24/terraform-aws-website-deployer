# # method 1
# terraform init && terraform plan && terraform apply -auto-approve
# terraform destroy -auto-approve
# # method 2
# terraform init && terraform plan -out=tfplan.out && terraform apply tfplan.out
# terraform destroy -auto-approve
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }

  backend "s3" {
    key     = "state/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  #   alias      = "primary_hosting_region"
  region = var.domain_bucket_region
}

provider "aws" {
  alias  = "aws_acm_region"
  region = var.aws_acm_region
}

resource "aws_acm_certificate" "certificate" {
  domain_name = var.route53_domain_name
  subject_alternative_names = [
    "www.${var.route53_domain_name}",
    "*.${var.route53_domain_name}"
  ]
  validation_method = "DNS"
  provider          = aws.aws_acm_region

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "domains" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.route53_record_ttl
  type            = each.value.type
  zone_id         = var.route53_hosted_zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.domains : record.fqdn]
  provider                = aws.aws_acm_region
}

resource "aws_s3_bucket" "main" {
  bucket = var.domain_bucket_name
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "s3-cloudfront-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  aliases             = [var.route53_domain_name]
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = true

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    target_origin_id       = aws_s3_bucket.main.bucket
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = aws_s3_bucket.main.bucket
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

data "aws_iam_policy_document" "cloudfront_oac_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = ["${aws_s3_bucket.main.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.cloudfront_oac_access.json
}

resource "aws_route53_record" "main" {
  name    = var.route53_domain_name
  type    = "A"
  zone_id = var.route53_hosted_zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
  }
}
