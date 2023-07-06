# WebUI URL
output "web_ui" {
  value = "https://${aws_eip.eip.public_ip}:7860"
}