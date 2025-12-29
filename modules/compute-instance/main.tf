# ==============================================================================
# ☁️ MÓDULO DE CÓMPUTO EC2
# ==============================================================================
# Este módulo estandariza la creación de servidores.
# Obliga el uso de Tags y Security Groups específicos.

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

# ------------------------------------------------------------------------------
# 1. SEGURIDAD (SecOps)
# ------------------------------------------------------------------------------
# Creamos un SG específico para esta instancia. 
# Principio de Menor Privilegio: Solo permitimos lo necesario.
resource "aws_security_group" "this" {
  name_prefix = "${var.env}-sg-"
  description = "Security Group managed by Terraform for ${var.env}"
  vpc_id      = var.vpc_id

  # Regla Dinámica: Solo permitimos el puerto que definamos (ej: 80 o 443)
  ingress {
    from_port   = var.service_port
    to_port     = var.service_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # En prod real, esto debería ser más restrictivo (VPN/ALB)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.env}-security-group" })
}

# ------------------------------------------------------------------------------
# 2. CÓMPUTO
# ------------------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  # Asociación de Seguridad
  vpc_security_group_ids = [aws_security_group.this.id]

  # ----------------------------------------------------------------------------
  # 🏷️ FINOPS - ETIQUETADO OBLIGATORIO
  # ----------------------------------------------------------------------------
  # Fusionamos los tags globales con el nombre específico del recurso
  tags = merge(
    var.tags,
    {
      Name        = "${var.env}-server"
      Environment = var.env
      ManagedBy   = "Terragrunt"
    }
  )
}
