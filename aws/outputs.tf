output "url_cloudfront" {
  description = "URL pública del sitio web en CloudFront"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

output "url_s3_endpoint" {
  description = "Endpoint directo del bucket S3 (solo uso interno)"
  value       = aws_s3_bucket_website_configuration.sitio.website_endpoint
}

output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.sitio.bucket
}

output "cloudfront_distribution_id" {
  description = "ID de la distribución CloudFront"
  value       = aws_cloudfront_distribution.cdn.id
}
