#!/bin/bash
# ==============================================================================
# 💰 FINOPS AUDITOR - MONITOREO POR REPOSITORIO
# ==============================================================================
# Buscamos por el tag "Repo" que es común a todos los entornos (dev, qa, prod)

# CAMBIO AQUÍ: Usamos el tag global del repo en lugar del nombre del proyecto
TAG_KEY="Repo"
TAG_VALUE="aws-terragrunt-enterprise-scale"

REGION="us-east-1"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "🔍 AUDITANDO RECURSOS DEL REPO: $TAG_VALUE"
echo "----------------------------------------------------------------"

check_resource() {
    RESOURCE_NAME=$1
    CMD=$2
    
    echo -n "Auditando $RESOURCE_NAME... "
    IDS=$(eval $CMD)
    
    if [ -z "$IDS" ] || [ "$IDS" == "None" ]; then
        echo -e "${GREEN}LIMPIO (0 recursos)${NC}"
    else
        echo -e "${RED}⚠️  ACTIVOS: $IDS${NC}"
    fi
}

# 1. INSTANCIAS EC2
check_resource "Instancias EC2" \
    "aws ec2 describe-instances --filters \"Name=tag:$TAG_KEY,Values=$TAG_VALUE\" \"Name=instance-state-name,Values=running,stopped,pending\" --region $REGION --query 'Reservations[].Instances[].InstanceId' --output text"

# 2. VOLÚMENES EBS
check_resource "Volúmenes EBS" \
    "aws ec2 describe-volumes --filters \"Name=tag:$TAG_KEY,Values=$TAG_VALUE\" --region $REGION --query 'Volumes[].VolumeId' --output text"

# 3. GRUPOS DE SEGURIDAD
check_resource "Security Groups" \
    "aws ec2 describe-security-groups --filters \"Name=tag:$TAG_KEY,Values=$TAG_VALUE\" --region $REGION --query 'SecurityGroups[].GroupId' --output text"

echo "----------------------------------------------------------------"
echo "🏁 Fin de la auditoría."
