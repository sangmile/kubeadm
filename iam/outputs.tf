output "instance_profile_arn" {
    value = aws_iam_instance_profile.k8s.arn
}

output "autoscaling_role_arn" {
    value = aws_iam_service_linked_role.autoscaling.arn
}