output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "ALB DNS name"
}

output "instance_public_ips" {
  value = [
    aws_instance.web1.private_ip,
    aws_instance.web2.private_ip
  ]
  description = "EC2 instance private IPs"
}

output "instance_ids" {
  value = [
    aws_instance.web1.id,
    aws_instance.web2.id
  ]
  description = "EC2 instance IDs"
}

output "security_group_id" {
  value       = aws_security_group.ec2.id
  description = "EC2 security group ID"
}
