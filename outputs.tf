output "private_key" {
  value       = tls_private_key.public_key.private_key_pem
  description = "the public key that will be used for ssh"
  sensitive   = true
}

output "launch_config_name" {
  value       = aws_launch_configuration.launch.name
  description = "Name of the launch configuration to be used as input for other modules"
}

output "server_port" {
  value       = var.server_port
  description = "Port for server to be used as input for other modules"
}

output "repo_name" {
  value = var.repo_name
  description = "Name of repository to be used as input for other modules"
}

output "alb_dns_name" {
  value       = aws_lb.load_balancer.dns_name
  description = "The domain name of the load balancer"
}

// output "public_ips" {
//   value = data.aws_instances.workers.public_ips
// }

// data "aws_instances" "workers" {
//   instance_tags = {
//     Name = "react_calculator_asg"
//   }
// }