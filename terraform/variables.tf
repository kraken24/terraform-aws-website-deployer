variable "backend_bucket_name" {
  description = "The AWS S3 bucket to store terraform state"
  type        = string
}
variable "backend_bucket_region" {
  description = "The AWS S3 bucket to store terraform state"
  type        = string
}

variable "aws_acm_region" {
  description = "The AWS region to create ACM certificate in"
  type        = string
}

variable "domain_bucket_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "domain_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "route53_domain_name" {
  description = "The domain name registered with the Route 53"
  type        = string
}

variable "route53_hosted_zone_id" {
  description = "The ID of the Route 53 Hosted Zone"
  type        = string
}

variable "route53_record_ttl" {
  description = "The TTL of records created in the Route 53"
  type        = number
}