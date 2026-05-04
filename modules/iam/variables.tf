variable "project_name" {
  description = "Nom du projet pour les tags"
  type        = string
}

variable "env" {
  description = "Environnement"
  type        = string
}

variable "owner" {
  description = "Propriétaire des ressources"
  type        = string
}

variable "secret_arn" {
  description = "ARN du secret Secrets Manager"
  type        = string
}