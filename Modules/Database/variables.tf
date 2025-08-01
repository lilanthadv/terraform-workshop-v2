variable "app_name" {
  type        = string
  description = "The application name"
}

variable "app_version" {
  type        = string
  description = "The application version"
}

variable "environment" {
  type        = string
  description = "The environment"
}

variable "name" {
  description = "The name for the resource"
  type        = string
}

variable "engine" {
  type        = string
  description = "The database engine to use"
}

variable "engine_mode" {
  type        = string
  description = "The engine mode of the DB cluster"
}

variable "engine_version" {
  type        = string
  description = "The version of the database engine"
}

variable "database_name" {
  type        = string
  description = "The name of the database to create"
}

variable "master_username" {
  type        = string
  description = "The username for the master user"
}

variable "master_password" {
  type        = string
  description = "The password for the master user"
}

variable "port" {
  type        = string
  description = "The port for the master user"
}

variable "deletion_protection" {
  type        = bool
  description = "The deletion protection of the database"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "The skip final snapshot of the database"
}

variable "enable_http_endpoint" {
  type        = bool
  description = "The enable http endpoint of the database"
}

variable "max_capacity" {
  type        = number
  description = "The maximum capacity units for the DB cluster"
}

variable "min_capacity" {
  type        = number
  description = "The minimum capacity units for the DB cluster"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones where the DB cluster will be created"
}

variable "vpc_id" {
  type        = string
  description = "The vpc id to assign to the DB cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A map of subnet ids to assign to the DB cluster"
}
