output "access_id" {
  value = aws_iam_access_key.user_key.id
}

output "secret_key" {
  value = aws_iam_access_key.user_key.secret
  sensitive = true
}
