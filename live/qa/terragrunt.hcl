include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/compute-instance"
}

# ==============================================================================
# 🧪 VARIABLES ESPECÍFICAS DE QA
# ==============================================================================
inputs = {
  env           = "qa"
  instance_type = "t3.micro"
  service_port  = 80 
  
  # Usamos la misma VPC que encontraste
  vpc_id        = "vpc-02f1bc9f309b82125"

  tags = {
    Owner       = "QA-Team"
    Project     = "Beta-Release"
    CostCenter  = "Quality-Assurance"
    Tester      = "Automated-Bot"
  }
}
