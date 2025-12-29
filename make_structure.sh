# 1. Scripts de Automatización y FinOps
mkdir -p scripts

# 2. Módulos (El Código Terraform Puro - Reutilizable)
#    Aquí definimos "CÓMO" se crea un servidor, pero no "CUÁNTOS" ni "DÓNDE".
mkdir -p modules/compute-instance

# 3. Live (La Implementación Terragrunt - DRY)
#    Aquí definimos los entornos y solo inyectamos valores.
mkdir -p live/dev
mkdir -p live/qa
mkdir -p live/prod

# Archivos base
touch live/terragrunt.hcl
touch .gitignore
touch README.md
