module "eks" {
  source = "git::https://github.com/jaseel123/terraform-modules/eks.git?ref=main"

  region                 = local.config.region
  cluster_name           = local.config.cluster.name
  enable_spot            = try(local.config.cluster.worker_nodegroup.launch_template.enable_spot, false)
  infra_nodegroup        = local.config.cluster.infra_nodegroup
  cluster_version        = local.config.cluster.version
  worker_nodegroup       = local.config.cluster.worker_nodegroup
  additional_nodegroups  = try(local.config.cluster.additional_nodegroups, {})
  master_role            = local.config.cluster.master_role
  worker_role            = local.config.cluster.worker_role
  vpc_id                 = local.config.cluster.vpc_id
  subnet_ids             = local.config.cluster.subnet_ids
  sg                     = local.config.security_group
  sg_rules               = local.config.sg_rules
  enable_efs             = try(local.config.cluster.enable_efs, false)
  lifecycle_policy       = try(local.config.cluster.efs_lifecycle_policy, {})
  addons                 = local.config.cluster.addons
  endpoint_access        = local.config.cluster.endpoint_access
  user_data_path         = local.config.cluster.userdata
  cluster_logs_retention = try(local.config.cluster.logs_retention, 3)
  tags                   = local.config.tags
}
