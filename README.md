# TechStyle – Despliegue AWS con Terraform

## Estructura de archivos

```
terraform-aws/
├── main.tf              ← Toda la infraestructura AWS
├── terraform.tfvars     ← Variables personalizables
├── deploy.sh            ← Script de despliegue automático
└── sitio-web/           ← Carpeta donde van tus archivos HTML/CSS
    ├── index.html
    ├── 404.html
    └── styles.css
```

---

## Paso a paso para ejecutar

### 1. Requisitos previos
- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.3 instalado
- AWS CLI instalada y configurada (`aws configure`)
- Cuenta AWS activa (free tier es suficiente)

### 2. Colocar los archivos del sitio
Copia `index.html`, `404.html` y `styles.css` en la carpeta `sitio-web/`.

### 3. Personalizar variables
Edita `terraform.tfvars`:
```hcl
bucket_name      = "techstyle-tusnombres"   # debe ser único en AWS
alert_email      = "tucorreo@ejemplo.com"
budget_limit_usd = "10"
```

> ⚠️ El nombre del bucket S3 es **globalmente único**. Si el nombre ya está tomado, Terraform dará error. Agrega un sufijo con tus iniciales.

### 4. Ejecutar el despliegue automático
```bash
chmod +x deploy.sh
./deploy.sh
```

O manualmente:
```bash
terraform init
terraform plan
terraform apply
```

### 5. Verificar el sitio
Al finalizar, Terraform imprime la URL de CloudFront:
```
url_cloudfront = "https://dXXXXXXXXX.cloudfront.net"
```

Espera ~15 minutos para que la distribución se propague globalmente.

---

## ¿Qué se crea en AWS?

| Recurso | Descripción |
|---|---|
| **S3 Bucket** | Almacena los archivos del sitio (privado, solo CloudFront accede) |
| **S3 Versioning** | Guarda versiones anteriores de los archivos |
| **S3 Cifrado SSE-S3** | Cifrado en reposo AES-256 |
| **CloudFront OAC** | Permite que CloudFront lea S3 de forma segura |
| **CloudFront Distribution** | CDN global con HTTPS, compresión y caché |
| **Bucket Policy** | Solo CloudFront puede leer objetos (no acceso público directo) |
| **SNS Topic + Email** | Notificaciones de alertas por correo |
| **Alarma 5xx** | Alerta si la tasa de errores del servidor supera el 5% |
| **Alarma 4xx** | Alerta si la tasa de errores de cliente supera el 10% |
| **CloudWatch Dashboard** | Panel visual de solicitudes y errores |
| **AWS Budget** | Alerta al 80% y 100% del presupuesto mensual definido |

---

## Destruir la infraestructura (para no generar costos)
```bash
terraform destroy
```
Confirma con `yes` cuando se solicite.