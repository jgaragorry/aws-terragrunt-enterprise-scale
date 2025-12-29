#!/bin/bash
set -e # Detener ejecución si hay error

# ==============================================================================
# 🛡️ CONFIGURACIÓN DE SEGURIDAD Y NOMENCLATURA
# ==============================================================================
# Usamos el ID de cuenta para garantizar unicidad global (Requisito S3)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
PROJECT_NAME="terragrunt-enterprise"
BUCKET_NAME="${PROJECT_NAME}-state-${ACCOUNT_ID}"

# Colores para pedagogía visual
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🏗️  INICIANDO PREPARACIÓN DEL BACKEND (S3 NATIVE LOCKING)${NC}"
echo "----------------------------------------------------------------"
echo "🌍 Región Objetivo: $REGION"
echo "📦 Bucket State:    $BUCKET_NAME"
echo "🔐 Cifrado:         AES256 (Server Side)"
echo "🔄 Versionado:      Activado (Recovery Point)"
echo "----------------------------------------------------------------"

# ==============================================================================
# 1. CREACIÓN IDEMPOTENTE DEL BUCKET
# ==============================================================================
# Verificamos si existe antes de intentar crearlo para no generar errores
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo -e "${GREEN}✅ El bucket ya existe. Omitiendo creación.${NC}"
else
    echo "⏳ Creando bucket..."
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" >/dev/null
    
    # Bloqueo de Acceso Público (Security Best Practice)
    echo "🔒 Aplicando 'Block Public Access'..."
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    
    # Habilitar Versionado (Protección contra corrupción de tfstate)
    echo "🔄 Habilitando Versionado..."
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
    
    # Cifrado por Defecto (Compliance)
    echo "🔐 Habilitando Encriptación..."
    aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

    echo -e "${GREEN}✅ Bucket creado y asegurado exitosamente.${NC}"
fi

# ==============================================================================
# 2. SALIDA PARA TERRAGRUNT
# ==============================================================================
echo ""
echo -e "${YELLOW}📋 COPIA ESTO PARA TU 'live/terragrunt.hcl' (Ya está generado abajo):${NC}"
echo "----------------------------------------------------------------"
echo "bucket = \"$BUCKET_NAME\""
echo "----------------------------------------------------------------"
