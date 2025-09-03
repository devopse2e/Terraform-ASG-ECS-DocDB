
variable "task_family" {
    description = "task family for the ecs"
    type = string
  
}
variable "cpu" {
    description = "container cpu resource value"
    type = string
  
}
variable "memory" {
    description = "container memory resource value"
    type = string
  
}
variable "task_execution_role" {
    description = "iam task role of ecs"
    type = string
  
}
variable "container_name" {
    description = "container name"
    type = string
  
}
variable "container_image" {
    description = "container image name"
    type = string
  
}
variable "container_port" {
    description = "container port"
    type = number
  
}
variable "environment_vars" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
variable "name_prefix" {
    description = "name prefix"
    type = string
  
}
variable "desired_count" {
    description = "desired count of ecs containers"
    type = number
  
}
variable "subnets" {
    description = "subnets for the ecs"
    type = list(string)
  
}
variable "security_groups" {
    description = "sg for the ecs"
    type = string
  
}

variable "target_group_arn" {
    description = "alb target group arn"
    type = string
  
}
variable "enable_cert_mount" {
  type        = bool
  default     = false  # Off by default (for frontend)
  description = "Enable mounting RDS CA cert from host"
}
