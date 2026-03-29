terraform {
  backend "s3" {
    # Este backend lo usan tanto Terraform local como GitHub Actions.
    bucket       = "terraform-state-utb"
    key          = "co-utb-techstyles-infra/aws/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
