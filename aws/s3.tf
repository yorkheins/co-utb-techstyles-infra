resource "aws_s3_bucket" "sitio" {
  bucket = var.bucket_name
  tags   = local.common_tags
}

# Bloquear acceso público directo al bucket
# (solo CloudFront puede leer los objetos via OAC)
resource "aws_s3_bucket_public_access_block" "sitio" {
  bucket = aws_s3_bucket.sitio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Habilitar versionado para recuperación ante errores
resource "aws_s3_bucket_versioning" "sitio" {
  bucket = aws_s3_bucket.sitio.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Cifrado en reposo (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "sitio" {
  bucket = aws_s3_bucket.sitio.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configuración de sitio web estático (para el endpoint interno)
resource "aws_s3_bucket_website_configuration" "sitio" {
  bucket = aws_s3_bucket.sitio.id
  index_document { suffix = "index.html" }
  error_document { key = "404.html" }
}

# Política de bucket: solo CloudFront (OAC) puede leer objetos
resource "aws_s3_bucket_policy" "sitio" {
  bucket = aws_s3_bucket.sitio.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.sitio.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.sitio]
}
