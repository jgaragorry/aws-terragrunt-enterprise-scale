#!/bin/bash
set -e # Detener si hay error

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Verificando requisitos del sistema...${NC}"

# 1. Verificar si ya existe
if command -v terragrunt &> /dev/null; then
    CURRENT_VERSION=$(terragrunt --version)
    echo -e "${GREEN}✅ Terragrunt ya está instalado: $CURRENT_VERSION${NC}"
    exit 0
fi

echo -e "${YELLOW}⬇️  Terragrunt no detectado. Iniciando instalación automática...${NC}"

# 2. Obtener última versión oficial
TG_TAG=$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\, | xargs)

if [ -z "$TG_TAG" ]; then
    echo -e "${RED}❌ Error: No se pudo detectar la última versión en GitHub.${NC}"
    exit 1
fi

echo "📦 Descargando versión: $TG_TAG"
wget -q --show-progress https://github.com/gruntwork-io/terragrunt/releases/download/${TG_TAG}/terragrunt_linux_amd64 -O terragrunt

# 3. Instalar
chmod +x terragrunt
echo "🔑 Moviendo binario a /usr/local/bin (Se requiere password de sudo)..."
sudo mv terragrunt /usr/local/bin/

# 4. Verificación final
if command -v terragrunt &> /dev/null; then
    echo -e "${GREEN}✅ Instalación completada exitosamente!${NC}"
    terragrunt --version
else
    echo -e "${RED}❌ Algo falló en la instalación.${NC}"
    exit 1
fi
