output "arn_task_definition" {
  value = aws_ecs_task_definition.ecs_task_definition.arn
}

output "task_definition_family" {
  value = aws_ecs_task_definition.ecs_task_definition.family
}

output "task_definition_id" {
  value = aws_ecs_task_definition.ecs_task_definition.id
}

output "task_definition_memory" {
  value = aws_ecs_task_definition.ecs_task_definition.memory
}

output "task_definition_cpu" {
  value = aws_ecs_task_definition.ecs_task_definition.cpu
}

output "container_name" {
  value = local.container_name
}
