# Backend de Estado de Terraform

Este directorio usa un backend S3 para almacenar el estado de Terraform.

## Prerrequisitos

Antes de ejecutar Terraform, debes crear un bucket S3 para el almacenamiento del estado.

### Crear Bucket S3 (Configuración única)

**Vía Consola AWS:**

1. Ir a la Consola AWS S3
2. Crear bucket con estas configuraciones:
   - **Nombre del bucket:** `tu-bucket-estado-terraform` (elegir un nombre único)
   - **Región:** `us-east-1` (o tu región preferida)
   - **Bloquear todo acceso público:** ✅ Habilitado
   - **Versionado:** ✅ Habilitado (recomendado)
   - **Cifrado:** ✅ SSE-S3 o SSE-KMS

**Vía AWS CLI:**

```bash
# Establecer nombre del bucket
BUCKET_NAME="tu-bucket-estado-terraform"
AWS_REGION="us-east-1"

# Crear bucket
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $AWS_REGION

# Habilitar versionado
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Bloquear acceso público
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Habilitar cifrado
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
```

## Desarrollo Local

### Inicializar Terraform con configuración de backend

```bash
cd 02-reverse-tunnel/terraform

terraform init \
  -backend-config="bucket=tu-bucket-estado-terraform" \
  -backend-config="key=ssh-tips/02-reverse-tunnel/terraform.tfstate" \
  -backend-config="region=eu-west-1"
```

### Planificar y Aplicar

```bash
# Planificar
terraform plan -out=tfplan

# Aplicar
terraform apply tfplan

# Destruir
terraform destroy
```

## GitHub Actions

El workflow `.github/workflows/02-reverse-tunnel.yml` configura automáticamente el backend usando secrets:

**Secrets Requeridos:**

- `TF_STATE_BUCKET`: Nombre del bucket S3 para el estado de Terraform
- `AWS_ROLE_ARN`: ARN del rol IAM para OIDC de GitHub Actions
- `SSH_PUBLIC_KEY`: Clave pública SSH predeterminada para acceso a EC2

**Para ejecutar el workflow:**

1. Ir a la pestaña GitHub Actions
2. Seleccionar "Deploy Case 1 - Reverse SSH Tunnel Infrastructure"
3. Hacer clic en "Run workflow"
4. Elegir acción: `apply` o `destroy`
5. (Opcional) Proporcionar clave pública SSH

## Notas

- El bucket S3 se comparte entre todos los casos de esta presentación
- Ruta del archivo de estado: `ssh-tips/02-reverse-tunnel/terraform.tfstate`
- Este es uno de los pocos prerrequisitos de infraestructura para la presentación
