module "kms" {
  for_each = local.config.kms

  source                             = "git::https://github.com/jaseel123/terraform-modules/kms.git?ref=v1.1.0"
  bypass_policy_lockout_safety_check = lookup(each.value, "bypass_policy_lockout_safety_check", false)
  customer_master_key_spec           = lookup(each.value, "customer_master_key_spec", "SYMMETRIC_DEFAULT")
  custom_key_store_id                = lookup(each.value, "custom_key_store_id", null)
  deletion_window_in_days            = lookup(each.value, "deletion_window_in_days", 30)
  description                        = lookup(each.value, "description", null)
  enable_key_rotation                = lookup(each.value, "enable_key_rotation", true)
  is_enabled                         = lookup(each.value, "is_enabled", true)
  key_usage                          = lookup(each.value, "key_usage", "ENCRYPT_DECRYPT")
  multi_region                       = lookup(each.value, "multi_region", false)
  enable_default_policy              = lookup(each.value, "enable_default_policy", false)
  policy                             = lookup(each.value, "policy", null)
  alias_use_name_prefix              = lookup(each.value, "alias_use_name_prefix", false)
  key_owners                         = lookup(each.value, "key_owners", [])
  key_administrators                 = lookup(each.value, "key_administrators", [])
  key_users                          = lookup(each.value, "key_users", [])
  key_read_only_users                = lookup(each.value, "key_read_only_users", [])
  key_service_users                  = lookup(each.value, "key_service_users", [])
  key_statements                     = lookup(each.value, "key_statements", {})
  key_alias                          = "${terraform.workspace}-${each.key}"
  tags                               = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "s3" {
  for_each = local.config.s3

  source                     = "git::https://github.com/jaseel123/terraform-modules/s3.git?ref=main"
  bucket_name                = "${terraform.workspace}-${each.key}"
  bucket_prefix              = lookup(each.value, "bucket_prefix", null)
  versioning_enabled         = lookup(each.value, "versioning_enabled", false)
  encryption_mode            = lookup(each.value, "encryption_mode", "AES256")
  kms_key_arn                = lookup(each.value, "kms_key_arn", null)
  force_destroy              = lookup(each.value, "force_destroy", false)
  lifecycle_policy           = lookup(each.value, "lifecycle", null)
  website_configuration      = lookup(each.value, "website_configuration", null)
  public_access              = lookup(each.value, "public_access", {})
  create_bucket_notification = lookup(each.value, "create_bucket_notification", false)
  lambda_notifications       = lookup(each.value, "lambda_notifications", {})
  sqs_notifications          = lookup(each.value, "sqs_notifications", {})
  sns_notifications          = lookup(each.value, "sns_notifications", {})
  create_sns_policy          = lookup(each.value, "create_sns_policy", false)
  create_sqs_policy          = lookup(each.value, "create_sqs_policy", false)
  cors                       = lookup(each.value, "cors", false)
  tags                       = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "dynamodb" {
  for_each = local.config.dynamodb

  source                             = "git::https://github.com/jaseel123/terraform-modules/dynamodb.git?ref=v1.0.1"
  name                               = "${terraform.workspace}-${each.key}"
  billing_mode                       = lookup(each.value, "billing_mode", "PAY_PER_REQUEST")
  deletion_protection_enabled        = lookup(each.value, "deletion_protection_enabled", false)
  hash_key                           = lookup(each.value, "hash_key", null)
  range_key                          = lookup(each.value, "range_key", null)
  read_capacity                      = lookup(each.value, "read_capacity", null)
  write_capacity                     = lookup(each.value, "write_capacity", null)
  stream_enabled                     = lookup(each.value, "stream_enabled", false)
  stream_view_type                   = lookup(each.value, "stream_view_type", null)
  table_class                        = lookup(each.value, "table_class", "STANDARD")
  ttl_enabled                        = lookup(each.value, "ttl_enabled", false)
  ttl_attribute_name                 = lookup(each.value, "ttl_attribute_name", "")
  point_in_time_recovery_enabled     = lookup(each.value, "point_in_time_recovery_enabled", false)
  attributes                         = lookup(each.value, "attributes", [])
  local_secondary_indexes            = lookup(each.value, "local_secondary_indexes", [])
  global_secondary_indexes           = lookup(each.value, "global_secondary_indexes", [])
  replica_regions                    = lookup(each.value, "replica_regions", [])
  server_side_encryption_enabled     = lookup(each.value, "server_side_encryption_enabled", true)
  server_side_encryption_kms_key_arn = lookup(each.value, "server_side_encryption_kms_key_arn", "")
  import_table                       = lookup(each.value, "import_table", {})
  tags                               = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "irsa" {
  for_each = local.config.irsa

  source                        = "git::https://github.com/jaseel123/terraform-modules/irsa.git?ref=main"
  eks_cluster_oidc_provider_url = local.config.eks_cluster_oidc_provider_url
  eks_cluster_oidc_provider_arn = local.config.eks_cluster_oidc_provider_arn
  service_account               = each.value.service_account
  namespace                     = each.value.namespace
  policies                      = lookup(each.value, "policies", {})
  tags                          = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "global-enforcer" {
  source = "git::https://github.com/jaseel123/terraform-modules/global-enforcer.git?ref=main"

  minimum_password_length   = 16
  max_password_age          = 90
  password_reuse_prevention = 5
  tags                      = local.config.tags
}

module "vault-auth-config" {
  source               = "git::https://github.com/jaseel123/terraform-modules/vault.git//kubernetes-auth-backend?ref=v1.2.0"
  cluster_api_endpoint = local.config.cluster_api_endpoint
}

module "vault-rsa" {
  for_each = local.config.vault

  source                  = "git::https://github.com/jaseel123/terraform-modules/vault.git//VRSA?ref=v1.2.0"
  role_bindings           = each.value
  vault_auth_backend_path = module.vault-auth-config.vault_auth_backend_path
}

module "vault-oidc" {
  for_each = local.config.vault_oidc

  source                 = "git::https://github.com/jaseel123/terraform-modules/vault.git//oidc?ref=v1.2.0"
  role_bindings          = each.value
  vault_oidc_accessor_id = local.config.vault_oidc_accessor_id
  vault_endpoint         = local.config.vault_endpoint
}

module "cloudfront" {
  for_each = local.config.cloudfront

  source                 = "git::https://github.com/jaseel123/terraform-modules/cloudfront.git?ref=initial-version"
  aliases                = lookup(each.value, "aliases", null)
  comment                = lookup(each.value, "comment", null)
  custom_error_response  = lookup(each.value, "custom_error_response", {})
  default_cache_behavior = lookup(each.value, "default_cache_behavior", null)
  default_root_object    = lookup(each.value, "default_root_object", null)
  enabled                = lookup(each.value, "enabled", true)
  geo_restriction        = lookup(each.value, "geo_restriction", {})
  s3_bucket_policies     = lookup(each.value, "s3_bucket_policies", {})
  http_version           = lookup(each.value, "http_version", "http2")
  logging_config         = lookup(each.value, "logging_config", {})
  ordered_cache_behavior = lookup(each.value, "ordered_cache_behavior", [])
  origin                 = each.value.origin
  origin_access_control  = lookup(each.value, "origin_access_control", {})
  origin_group           = lookup(each.value, "origin_group", {})
  price_class            = lookup(each.value, "price_class", null)
  retain_on_delete       = lookup(each.value, "retain_on_delete", false)
  tags                   = merge(local.config.tags, lookup(each.value, "tags", {}))
  viewer_certificate = lookup(each.value, "viewer_certificate", {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  })
  wait_for_deployment = lookup(each.value, "wait_for_deployment", true)
  web_acl_id          = lookup(each.value, "web_acl_id", null)
}


module "alb" {
  for_each = local.config.alb

  source                           = "git::https://github.com/jaseel123/terraform-modules/alb.git?ref=initial-ver"
  name                             = "${terraform.workspace}-${each.key}"
  is_internet_facing               = lookup(each.value, "is_internet_facing", true)
  loadbalancer_type                = each.value.loadbalancer_type
  enable_cross_zone_load_balancing = lookup(each.value, "enable_cross_zone_load_balancing", true)
  subnetids                        = lookup(each.value, "subnetids", [])
  security_group_ids               = lookup(each.value, "security_group_ids", [])
  enable_ssl                       = lookup(each.value, "enable_ssl", true)
  listener_port                    = lookup(each.value, "listener_port", 443)
  security_policy                  = lookup(each.value, "security_policy", "ELBSecurityPolicy-TLS13-1-2-2021-06")
  certificate_arn                  = lookup(each.value, "certificate_arn", null)
  target_port                      = lookup(each.value, "target_port", 80)
  target_protocol                  = lookup(each.value, "target_protocol", "http")
  listener_protocol                = lookup(each.value, "listener_protocol", "https")
  target_name                      = lookup(each.value, "target_name", "")
  vpc_id                           = lookup(each.value, "vpc_id", "")
  instance_port                    = lookup(each.value, "instance_port", null)
  target_id                        = lookup(each.value, "target_id", "")
  target_type                      = lookup(each.value, "target_type", "")
  health_check                     = lookup(each.value, "health_check", {})
  tags                             = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "lambda" {
  for_each = local.config.lambda

  source                          = "git::https://github.com/jaseel123/terraform-modules/lambda.git?ref=initial-version"
  name                            = each.key
  s3_bucket                       = lookup(each.value, "s3_bucket", "")
  s3_key                          = lookup(each.value, "s3_key", "")
  handler                         = lookup(each.value, "handler", "")
  runtime                         = lookup(each.value, "runtime", "")
  memory_size                     = lookup(each.value, "memory_size", 128)
  timeout                         = lookup(each.value, "timeout", 3)
  environment_variables           = lookup(each.value, "environment_variables", {})
  vpc_subnet_ids                  = lookup(each.value, "vpc_subnet_ids", [])
  vpc_security_group_ids          = lookup(each.value, "vpc_security_group_ids", [])
  managed_policy                  = lookup(each.value, "managed_policy", [])
  ephemeral_storage               = lookup(each.value, "ephemeral_storage", 512)
  create_additional_policy        = lookup(each.value, "create_additional_policy", false)
  additional_policy               = lookup(each.value, "additional_policy", {})
  create_layer                    = lookup(each.value, "create_layer", false)
  layer_name                      = lookup(each.value, "layer_name", "")
  layer_runtimes                  = lookup(each.value, "layer_runtimes", [])
  layer_source_bucket             = lookup(each.value, "layer_source_bucket", "")
  layer_source_bucket_key         = lookup(each.value, "layer_source_bucket_key", "")
  create_lambda_permission        = lookup(each.value, "create_lambda_permission", false)
  lambda_permission               = lookup(each.value, "lambda_permission", "")
  lambda_permission_principal     = lookup(each.value, "lambda_permission_principal", "")
  lambda_permission_principal_arn = lookup(each.value, "lambda_permission_principal_arn", "")
  tags                            = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "sg" {
  for_each = local.config.sg

  source              = "git::https://github.com/jaseel123/terraform-modules/sg.git?ref=initial-version"
  security_group_name = "${terraform.workspace}-${each.key}"
  vpc_id              = each.value.vpc_id
  description         = lookup(each.value, "description", "security group")
  ingress_rules       = lookup(each.value, "ingress_rules", [])
  egress_rules        = lookup(each.value, "egress_rules", [])
  tags                = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "sns" {
  for_each = local.config.sns

  source                = "git::https://github.com/jaseel123/terraform-modules/sns.git?ref=initial-version"
  name                  = each.key
  kms_master_key_id     = lookup(each.value, "kms_master_key_id", "")
  delivery_policy       = lookup(each.value, "delivery_policy", null)
  enable_default_policy = lookup(each.value, "enable_default_policy", true)
  subscribers           = each.value.subscribers
  tags                  = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "sqs" {
  for_each = local.config.sqs

  source                            = "git::https://github.com/jaseel123/terraform-modules/sqs.git?ref=initial-version"
  name                              = each.key
  visibility_timeout_seconds        = lookup(each.value, "visibility_timeout_seconds", 30)
  delay_seconds                     = lookup(each.value, "delay_seconds", 0)
  kms_data_key_reuse_period_seconds = lookup(each.value, "kms_data_key_reuse_period_seconds", 300)
  kms_master_key_id                 = lookup(each.value, "kms_master_key_id", null)
  max_message_size                  = lookup(each.value, "max_message_size", 262144)
  message_retention_seconds         = lookup(each.value, "message_retention_seconds", 345600)
  receive_wait_time_seconds         = lookup(each.value, "receive_wait_time_seconds", 0)
  redrive_allow_policy              = lookup(each.value, "redrive_allow_policy", {})
  sqs_managed_sse_enabled           = lookup(each.value, "sqs_managed_sse_enabled", false)
  policy                            = lookup(each.value, "policy", null)
  enable_default_policy             = lookup(each.value, "enable_default_policy", true)
  enable_sns_policy                 = lookup(each.value, "enable_sns_policy", false)
  enable_eventbridge_policy         = lookup(each.value, "enable_eventbridge_policy", false)
  tags                              = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "mediaconvert" {
  for_each = local.config.mediaconvert

  source       = "git::https://github.com/jaseel123/terraform-modules/media-convert.git?ref=initial-version"
  name         = "${terraform.workspace}-${each.key}"
  pricing_plan = lookup(each.value, "pricing_plan", "ON_DEMAND")
  description  = lookup(each.value, "description", "media convert queue")
  status       = lookup(each.value, "status", "ACTIVE")
  tags         = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "eventbridge" {
  for_each = local.config.eventbridge

  source            = "git::https://github.com/jaseel123/terraform-modules/eventbridge.git?ref=initial-version"
  create_bus        = lookup(each.value, "create_bus", "true")
  bus_name          = lookup(each.value, "bus_name", "default")
  create_rules      = lookup(each.value, "create_rules", true)
  rules             = lookup(each.value, "rules", {})
  create_targets    = lookup(each.value, "create_targets", true)
  targets           = lookup(each.value, "targets", {})
  event_source_name = lookup(each.value, "event_source_name", "null")
  attach_sfn_policy = lookup(each.value, "attach_sfn_policy", false)
  sfn_target_arns   = lookup(each.value, "sfn_target_arns", [])
  create_role       = lookup(each.value, "create_role", false)
  role_name         = lookup(each.value, "role_name", null)
  role_description  = lookup(each.value, "role_description", null)
  tags              = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "stepfunctions" {
  for_each = local.config.stepfunctions

  source                       = "git::https://github.com/jaseel123/terraform-modules/step-functions.git?ref=main"
  sfn_state_machine_name       = lookup(each.value, "sfn_state_machine_name", "")
  sfn_state_machine_definition = lookup(each.value, "sfn_state_machine_definition", {})
  publish_version              = lookup(each.value, "publish_version", false)
  sfn_state_machine_type       = lookup(each.value, "sfn_state_machine_type", "STANDARD")
  enable_logging               = lookup(each.value, "enable_logging", true)
  enable_xray_tracing          = lookup(each.value, "enable_xray_tracing", false)
  logging_configuration        = lookup(each.value, "logging_configuration", {})
  sfn_state_machine_timeouts   = lookup(each.value, "sfn_state_machine_timeouts", "")
  lambda_functions             = lookup(each.value, "lambda_functions", [])
  region                       = local.config.region
  tags                         = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "apigateway" {
  for_each = local.config.apigateway

  source               = "git::https://github.com/jaseel123/terraform-modules/api-gateway.git?ref=main"
  name                 = "${terraform.workspace}-${each.key}"
  endpoint_type        = lookup(each.value, "endpoint_type", "EDGE")
  binary_media_types   = lookup(each.value, "binary_media_types", [])
  stage_name           = lookup(each.value, "stage_name", "")
  xray_tracing_enabled = lookup(each.value, "xray_tracing_enabled", false)
  enable_vpc_link      = lookup(each.value, "enable_vpc_link", true)
  nlb_arn              = lookup(each.value, "nlb_arn", "")
  api_gw_resources     = lookup(each.value, "api_gw_resources", {})
  api_gw_integrations  = lookup(each.value, "api_gw_integrations", {})
  api_gw_domain        = lookup(each.value, "api_gw_domain", "")
  acm_certificate_arn  = lookup(each.value, "acm_certificate_arn", "")
  log_group_retention  = lookup(each.value, "log_group_retention", 7)
  kms_key_arn          = lookup(each.value, "kms_key_arn", "")
  existing_vpc_link_id = lookup(each.value, "existing_vpc_link_id", "")
  enable_custom_role   = lookup(each.value, "enable_custom_role", true)
  existing_role_arn    = lookup(each.value, "existing_role_arn", "")
  tags                 = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "efs" {
  for_each = local.config.efs

  source                          = "git::https://github.com/jaseel123/terraform-modules/efs.git?ref=main"
  name                            = "${terraform.workspace}-${each.key}"
  efs_performance_mode            = lookup(each.value, "efs_performance_mode", "generalPurpose")
  kms_key_id                      = each.value.kms_key_id
  efs_throughput_mode             = lookup(each.value, "efs_throughput_mode", "bursting")
  provisioned_throughput_in_mibps = lookup(each.value, "provisioned_throughput_in_mibps", 100)
  lifecycle_policy                = lookup(each.value, "lifecycle_policy", [])
  mount_target                    = each.value.mount_target
  tags                            = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "load_balancer" {
  for_each = local.config.lb

  source                                                       = "git::https://github.com/jaseel123/terraform-modules/lb.git?ref=main"
  access_logs                                                  = lookup(each.value, "access_logs", {})
  client_keep_alive                                            = lookup(each.value, "client_keep_alive", 60)
  desync_mitigation_mode                                       = lookup(each.value, "desync_mitigation_mode", "defensive")
  enable_cross_zone_load_balancing                             = lookup(each.value, "enable_cross_zone_load_balancing", true)
  enable_deletion_protection                                   = lookup(each.value, "enable_deletion_protection", true)
  enable_http2                                                 = lookup(each.value, "enable_http2", true)
  enable_tls_version_and_cipher_suite_headers                  = lookup(each.value, "enable_tls_version_and_cipher_suite_headers", null)
  idle_timeout                                                 = lookup(each.value, "idle_timeout", null)
  internal                                                     = lookup(each.value, "internal", true)
  ip_address_type                                              = lookup(each.value, "ip_address_type", "ipv4")
  load_balancer_type                                           = lookup(each.value, "load_balancer_type", "application")
  enforce_security_group_inbound_rules_on_private_link_traffic = lookup(each.value, "enforce_security_group_inbound_rules_on_private_link_traffic", "off")
  name                                                         = "${terraform.workspace}-${each.key}"
  security_groups                                              = lookup(each.value, "security_groups", [])
  subnets                                                      = lookup(each.value, "subnets", null)
  default_port                                                 = lookup(each.value, "default_port", 80)
  default_protocol                                             = lookup(each.value, "default_protocol", "HTTP")
  listeners                                                    = lookup(each.value, "listeners", {})
  target_groups                                                = lookup(each.value, "target_groups", {})
  vpc_id                                                       = lookup(each.value, "vpc_id", null)
  tags                                                         = merge(local.config.tags, lookup(each.value, "tags", {}))
}

module "iam" {
  for_each = local.config.iam

  source                                                       = "git::https://github.com/jaseel123/terraform-modules/iam.git?ref=main"
  create_role                                                  = lookup(each.value, "create_role", false)
  create_custom_policy                                         = lookup(each.value, "create_custom_policy", false)
  role_name                                                    = lookup(each.value, "role_name", "")
  policy_name                                                  = lookup(each.value, "policy_name", "")
  trust_policy                                                 = lookup(each.value, "trust_policy", {})
  attach_managed_policy                                        = lookup(each.value, "attach_managed_policy", false)
  managed_policies                                             = lookup(each.value, "managed_policies", {})
  custom_policies                                              = lookup(each.value, "custom_policies", {})
  tags                                                         = merge(local.config.tags, lookup(each.value, "tags", {}))
}