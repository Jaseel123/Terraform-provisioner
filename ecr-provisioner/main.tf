module "primary-ecr" {
  for_each = local.config.ecr

  source = "git::https://github.com/jaseel123/terraform-modules/ecr.git?ref=v1.1.0"
  providers = {
    aws = aws.primary
  }
  repository_name                   = each.key
  tag_mutability                    = lookup(each.value, "tag_mutability", "IMMUTABLE")
  encryption_type                   = lookup(each.value, "encryption_type", "AES256")
  kms_key                           = lookup(each.value, "kms_key", null)
  force_delete                      = lookup(each.value, "force_delete", false)
  scan_on_push                      = lookup(each.value, "scan_on_push", true)
  lifecycle_rules                   = each.value.lifecycle_rules
  repository_read_access_arns       = lookup(each.value, "repository_read_access_arns", [])
  repository_read_write_access_arns = lookup(each.value, "repository_read_write_access_arns", [])
  tags                              = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "secondary-ecr" {
  for_each = local.config.ecr

  source = "git::https://github.com/jaseel123/terraform-modules/ecr.git?ref=v1.1.0"
  providers = {
    aws = aws.secondary
  }
  repository_name                   = each.key
  tag_mutability                    = lookup(each.value, "tag_mutability", "IMMUTABLE")
  encryption_type                   = lookup(each.value, "encryption_type", "AES256")
  kms_key                           = lookup(each.value, "kms_key", null)
  force_delete                      = lookup(each.value, "force_delete", false)
  scan_on_push                      = lookup(each.value, "scan_on_push", true)
  lifecycle_rules                   = each.value.lifecycle_rules
  repository_read_access_arns       = lookup(each.value, "repository_read_access_arns", [])
  repository_read_write_access_arns = lookup(each.value, "repository_read_write_access_arns", [])
  tags                              = merge(local.config.tags, lookup(each.value, "tags", {}))
}
