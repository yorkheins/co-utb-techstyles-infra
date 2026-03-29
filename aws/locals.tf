locals {
  prefix = lower(var.project_name)

  common_tags = {
    Proyecto   = var.project_name
    Ambiente   = var.environment
    Gestionado = "Terraform"
  }
}
