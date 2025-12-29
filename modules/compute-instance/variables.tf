variable "env" {
  description = "Nombre del entorno (dev, qa, prod)"
  type        = string
}

variable "instance_type" {
  description = "Tamaño de la instancia (t3.micro, t3.medium, etc)"
  type        = string
}

variable "service_port" {
  description = "Puerto de servicio expuesto (SecOps)"
  type        = number
  default     = 80
}

variable "vpc_id" {
  description = "ID de la VPC donde desplegar"
  type        = string
  # Nota: En un entorno real, esto vendría de un data source o remote state
}

variable "tags" {
  description = "Etiquetas base para FinOps (Project, CostCenter, Owner)"
  type        = map(string)
}
