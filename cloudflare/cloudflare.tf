resource "cloudflare_zone" "this" {
  account = {
    id = data.cloudflare_account.current.account_id
  }
  name = var.external_name
  type = "full"
}

resource "cloudflare_dns_record" "this" {
  zone_id = cloudflare_zone.this.id
  comment = "tracker"
  content = var.internal_name
  name    = var.external_name
  proxied = true
  settings = {
    ipv4_only = true
  }
  ttl  = 300
  type = "A"
}
