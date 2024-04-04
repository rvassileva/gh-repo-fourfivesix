output "instance_ids" {
  description = "Ids of the EC2 instances."
  value       = aws_instance.ec2_test[*].id
}

output "sg_id" {
  description = "The ID of the security group."
  value       = aws_security_group.test_ec2_access.id
}
