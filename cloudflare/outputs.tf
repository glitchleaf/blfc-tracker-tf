output "cidrs" {
  value = toset(data.cloudflare_ip_ranges.current.ipv4_cidrs)
}
