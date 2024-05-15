resource "aws_efs_replication_configuration" "main" {
  source_file_system_id = var.source_file_system_id

  destination {
    file_system_id = var.replication_file_system_id
    region         = var.replication_region
  }
}
