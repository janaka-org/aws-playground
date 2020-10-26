output "ids" {
  description = "Default subnet ids"
  value = data.aws_subnet_ids.default.ids
}