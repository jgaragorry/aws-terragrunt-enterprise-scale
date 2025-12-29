include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/compute-instance"
}

# ==============================================================================
# 🚀 VARIABLES ESPECÍFICAS DE PRODUCCIÓN
# ==============================================================================
inputs = {
  env           = "prod"
  instance_type = "t3.micro" # En real sería t3.large o cluster
  service_port  = 80
  
  # Misma VPC para el lab, en real sería otra cuenta/VPC
  vpc_id        = "vpc-02f1bc9f309b82125" # <--- REEMPLAZA CON TU VPC ID REAL

  tags = {
    Owner       = "SRE-Team"
    Project     = "Mission-Critical"
    CostCenter  = "Operations"
    Compliance  = "PCI-DSS"
  }
}
