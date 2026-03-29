# TechStyle – Infraestructura AWS con Terraform

Infraestructura para publicar un sitio estático en AWS usando S3, CloudFront y monitoreo con CloudWatch/SNS.

## Estructura real del repo

```text
.
├── .github/workflows/terraform-aws.yml
├── README.md
└── aws/
    ├── backend.tf
    ├── backend.hcl.example
    ├── cloudfront.tf
    ├── locals.tf
    ├── monitoring.tf
    ├── outputs.tf
    ├── providers.tf
    ├── s3.tf
    ├── terraform.tfvars
    └── variables.tf
```

## Requisitos

- Terraform >= 1.3
- AWS CLI configurada si vas a ejecutar localmente
- Un bucket S3 separado para guardar el `terraform.tfstate` remoto

## Ejecución local

1. Entra a la carpeta de Terraform:

```bash
cd aws
```

2. Edita `aws/backend.tf` con el bucket y la key reales del state remoto. Ajusta `terraform.tfvars` si hace falta.

3. Inicializa Terraform con backend remoto:

```bash
terraform init
```

4. Ejecuta el flujo normal:

```bash
terraform plan
terraform apply
```

Si solo quieres validar sintaxis sin conectar el backend remoto:

```bash
terraform init -backend=false
terraform validate
```

## Pipeline en GitHub Actions

El workflow está en `.github/workflows/terraform-aws.yml` y hace esto:

- `pull_request`: `terraform fmt`, `terraform init -backend=false`, `terraform validate` y `terraform plan` usando backend remoto si el PR no viene de un fork.
- `push` a `main`: ejecuta `plan` y luego `apply`.
- `workflow_dispatch`: permite lanzar `plan` o `apply` manualmente desde GitHub.

## Configuración en GitHub

### Secret

- `AWS_ROLE_TO_ASSUME`: ARN del rol IAM que GitHub Actions va a asumir por OIDC.

### Variables del repositorio

- `AWS_REGION`: recomendada. Región principal de despliegue. Si no la defines, el workflow usa `us-east-1`.
- `TF_VAR_BUCKET_NAME`: recomendada. Nombre único global del bucket del sitio.
- `TF_VAR_ALERT_EMAIL`: recomendada. Correo que recibirá la suscripción SNS.

Las `TF_VAR_*` no son obligatorias por sí mismas. Terraform las lee como overrides de variables. Si no las defines, usará los defaults de `aws/variables.tf`. En este repo conviene definir al menos `TF_VAR_BUCKET_NAME` y `TF_VAR_ALERT_EMAIL` para no depender de valores por defecto que pueden no servir en producción.

El backend remoto ya no se configura con variables de GitHub. El pipeline usa exactamente lo definido en `aws/backend.tf`.

## Rol AWS recomendado para GitHub Actions

Usa OIDC, no access keys estáticas. El rol debe confiar en GitHub OIDC y tener permisos para:

- leer y escribir el estado en el bucket S3 del backend
- crear y actualizar S3, CloudFront, CloudWatch y SNS

Si proteges el environment `production` en GitHub, el job de `apply` puede quedar sujeto a aprobación antes de desplegar.

## Recursos que crea Terraform

- Bucket S3 privado para el sitio
- Versionado y cifrado SSE-S3
- CloudFront con Origin Access Control
- Alarmas CloudWatch para 4xx, 5xx y errores totales
- SNS para notificaciones por correo
- Dashboard de monitoreo

## Destruir infraestructura

```bash
cd aws
terraform init
terraform destroy
```
