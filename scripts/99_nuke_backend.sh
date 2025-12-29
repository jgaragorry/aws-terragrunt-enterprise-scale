#!/bin/bash
set -e

# Configuración
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
PROJECT_NAME="terragrunt-enterprise"
BUCKET_NAME="${PROJECT_NAME}-state-${ACCOUNT_ID}"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}☢️  ATENCIÓN: ESTE SCRIPT DESTRUIRÁ EL BACKEND S3 PERMANENTEMENTE ☢️${NC}"
echo "Bucket objetivo: $BUCKET_NAME"
echo "----------------------------------------------------------------"

# Verificar si existe
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo -e "${GREEN}✅ El bucket no existe. Ya estás limpio.${NC}"
    exit 0
fi

echo -e "${YELLOW}⏳ Eliminando todas las versiones de objetos y marcadores...${NC}"

# Borrar todas las versiones de objetos (Loop para manejar paginación si hay muchos)
aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query 'Versions[].{Key:Key,VersionId:VersionId}' | \
jq -r '.[] | [.Key, .VersionId] | @tsv' | \
while IFS=$'\t' read -r key versionId; do
    if [ "$key" != "null" ]; then
        echo "Borrando versión: $key ($versionId)"
        aws s3api delete-object --bucket "$BUCKET_NAME" --key "$key" --version-id "$versionId"
    fi
done

# Borrar todos los marcadores de eliminación (Delete Markers)
aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' | \
jq -r '.[] | [.Key, .VersionId] | @tsv' | \
while IFS=$'\t' read -r key versionId; do
    if [ "$key" != "null" ]; then
        echo "Borrando marcador: $key ($versionId)"
        aws s3api delete-object --bucket "$BUCKET_NAME" --key "$key" --version-id "$versionId"
    fi
done

echo -e "${YELLOW}🗑️  Eliminando el bucket vacío...${NC}"
aws s3 rb "s3://${BUCKET_NAME}" --force

echo -e "${GREEN}✅ BACKEND DESTRUIDO. COSTE $0 GARANTIZADO.${NC}"
