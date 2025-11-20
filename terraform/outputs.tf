output "spark_master_public_ip" {
  value = google_compute_instance.spark_master.network_interface[0].access_config[0].nat_ip
}

output "spark_worker_public_ips" {
  value = [for instance in google_compute_instance.spark_workers : instance.network_interface[0].access_config[0].nat_ip]
}
