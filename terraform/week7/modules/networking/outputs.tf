output "vpc_name" {
  description = "The name of the created VPC"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {
  description = "The self-link of the VPC"
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "The name of the public subnet"
  value       = google_compute_subnetwork.public.name
}

output "subnet_cidr" {
  description = "The CIDR range of the subnet"
  value       = google_compute_subnetwork.public.ip_cidr_range
}
