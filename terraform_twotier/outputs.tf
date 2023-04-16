output "db_instance_endpoint" {
  description = "The DB instance endpoint"
  value       = aws_db_instance.dbinstance.endpoint
}