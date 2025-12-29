include "root" {
  path = find_in_parent_folders()
}

terraform {
  # Apuntamos a nuestro módulo local (Lógica)
  source = "../../modules/compute-instance"
}

# ==============================================================================
# 📝 VARIABLES ESPECÍFICAS DE DEV
# ==============================================================================
inputs = {
  env           = "dev"
  instance_type = "t3.micro"
  service_port  = 8080 # Dev usa puerto alternativo
  
  # VPC por defecto (us-east-1)
  # Nota: Para este lab usaremos la VPC default de tu cuenta.
  # Puedes obtenerla con: aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text
  vpc_id        = "vpc-02f1bc9f309b82125" # <--- REEMPLAZA CON TU VPC ID REAL

  tags = {
    Owner       = "Junior-Dev"
    Project     = "Alpha-Test"
    CostCenter  = "Research"
  }
}
