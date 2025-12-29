# ==============================================================================
# 🎮 CONFIGURACIÓN RAÍZ DE TERRAGRUNT (DRY BACKEND)
# ==============================================================================
# Este archivo define la configuración remota (S3) una sola vez.

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # 👇 TU BUCKET CORRECTO
    bucket         = "terragrunt-enterprise-state-533267117128"
    
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Generamos el provider de AWS automáticamente
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      ManagedBy = "Terragrunt"
      Repo      = "aws-terragrunt-enterprise-scale"
    }
  }
}
EOF
}
