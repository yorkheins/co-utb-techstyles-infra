# ============================================================
# SNS – Tema para notificaciones de alertas
# ============================================================

resource "aws_sns_topic" "alertas" {
  name = "${local.prefix}-alertas"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alertas.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ============================================================
# CLOUDWATCH – Alarmas de monitoreo CloudFront
# ============================================================

# Alarma: tasa de errores 5xx en CloudFront
resource "aws_cloudwatch_metric_alarm" "errores_5xx" {
  alarm_name          = "${local.prefix}-errores-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300 # 5 minutos
  statistic           = "Average"
  threshold           = var.alarm_threshold_5xx
  alarm_description   = "Tasa de errores 5xx superior al ${var.alarm_threshold_5xx}% en CloudFront"
  alarm_actions       = [aws_sns_topic.alertas.arn]
  ok_actions          = [aws_sns_topic.alertas.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.cdn.id
    Region         = "Global"
  }
}

# Alarma: tasa de errores 4xx en CloudFront
resource "aws_cloudwatch_metric_alarm" "errores_4xx" {
  alarm_name          = "${local.prefix}-errores-4xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300 # 5 minutos
  statistic           = "Average"
  threshold           = var.alarm_threshold_4xx
  alarm_description   = "Tasa de errores 4xx superior al ${var.alarm_threshold_4xx}% en CloudFront"
  alarm_actions       = [aws_sns_topic.alertas.arn]
  ok_actions          = [aws_sns_topic.alertas.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.cdn.id
    Region         = "Global"
  }
}

# Alarma: tasa total de errores en CloudFront
resource "aws_cloudwatch_metric_alarm" "errores_total" {
  alarm_name          = "${local.prefix}-errores-total"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TotalErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 60 # 1 minuto
  statistic           = "Average"
  threshold           = var.alarm_threshold_total_errors
  alarm_description   = "Tasa total de errores superior al ${var.alarm_threshold_total_errors}% – revisar disponibilidad"
  alarm_actions       = [aws_sns_topic.alertas.arn]
  ok_actions          = [aws_sns_topic.alertas.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.cdn.id
    Region         = "Global"
  }
}

# ============================================================
# CLOUDWATCH – Dashboard de monitoreo
# ============================================================

resource "aws_cloudwatch_dashboard" "principal" {
  dashboard_name = "${var.project_name}-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Solicitudes totales CloudFront"
          metrics = [["AWS/CloudFront", "Requests", "DistributionId",
            aws_cloudfront_distribution.cdn.id, "Region", "Global"]]
          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "Tasa de errores 4xx y 5xx"
          metrics = [
            ["AWS/CloudFront", "4xxErrorRate", "DistributionId",
            aws_cloudfront_distribution.cdn.id, "Region", "Global"],
            ["AWS/CloudFront", "5xxErrorRate", "DistributionId",
            aws_cloudfront_distribution.cdn.id, "Region", "Global"]
          ]
          period = 300
          stat   = "Average"
          view   = "timeSeries"
        }
      }
    ]
  })
}
