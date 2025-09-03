output "cluster_id" {
    value = aws_ecs_cluster.ecs.id
  
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.ecs_task.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}