variable "aws_region" {
  description = "Region donde existen la AMI y el key pair"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Dos zonas diferentes dentro de aws_region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "Indicar exactamente dos zonas diferentes."
  }
}

variable "ami_id" {
  description = "ID de staticweb-ami con Apache y el sitio instalado"
  type        = string
}

variable "key_pair_name" {
  description = "Nombre del key pair existente, no la ruta del archivo PEM"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia permitido en el laboratorio"
  type        = string
  default     = "t2.nano"
}
