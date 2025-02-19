module "cloudflare" {
  count = var.cloudflare_api_token == "" ? 0 : 1

  source = "./cloudflare"

  providers = {
    cloudflare = cloudflare
  }

  external_name = var.domain_name
  internal_name = local.internal_name
}
