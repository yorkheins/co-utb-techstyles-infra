variable "aws_region" {
  description = "Región principal de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto (usado en etiquetas y nombres de recursos)"
  type        = string
  default     = "TechStyle"
}

variable "environment" {
  description = "Ambiente de despliegue (Produccion, Staging, etc.)"
  type        = string
  default     = "Produccion"
}

variable "bucket_name" {
  description = "Nombre único del bucket S3 (debe ser globalmente único en AWS)"
  type        = string
  default     = "techstyle-static-site"
}

variable "alert_email" {
  description = "Correo para recibir alertas de CloudWatch"
  type        = string
  default     = "george.resqband98@gmail.com"
}

variable "cloudfront_price_class" {
  description = "Clase de precio de CloudFront (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}

variable "cloudfront_default_ttl" {
  description = "TTL predeterminado del caché de CloudFront en segundos"
  type        = number
  default     = 86400 # 1 día
}

variable "cloudfront_max_ttl" {
  description = "TTL máximo del caché de CloudFront en segundos"
  type        = number
  default     = 31536000 # 1 año
}

variable "alarm_threshold_5xx" {
  description = "Umbral (%) de errores 5xx para activar la alarma"
  type        = number
  default     = 5
}

variable "alarm_threshold_4xx" {
  description = "Umbral (%) de errores 4xx para activar la alarma"
  type        = number
  default     = 10
}

variable "alarm_threshold_total_errors" {
  description = "Umbral (%) de tasa total de errores para activar la alarma"
  type        = number
  default     = 15
}
