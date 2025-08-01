locals {
  config_file             = "configurations/${terraform.workspace}/config.yaml"
  rds_config_file         = "configurations/${terraform.workspace}/rds.yaml"
  neptune_config_file     = "configurations/${terraform.workspace}/neptune.yaml"
  msk_config_file         = "configurations/${terraform.workspace}/msk.yaml"
  elasticache_config_file = "configurations/${terraform.workspace}/elasticache.yaml"
  opensearch_config_file  = "configurations/${terraform.workspace}/opensearch.yaml"
  amazonmq_config_file    = "configurations/${terraform.workspace}/amazonmq.yaml"

  rds_exists         = fileexists(local.rds_config_file)
  neptune_exists     = fileexists(local.neptune_config_file)
  msk_exists         = fileexists(local.msk_config_file)
  elasticache_exists = fileexists(local.elasticache_config_file)
  opensearch_exists  = fileexists(local.opensearch_config_file)
  amazonmq_exists    = fileexists(local.amazonmq_config_file)

  config = merge(
    yamldecode(file(local.config_file)),
    local.rds_exists ? yamldecode(file(local.rds_config_file)) : null,
    local.neptune_exists ? yamldecode(file(local.neptune_config_file)) : { neptune : {} },
    local.msk_exists ? yamldecode(file(local.msk_config_file)) : { msk : {} },
    local.elasticache_exists ? yamldecode(file(local.elasticache_config_file)) : { elasticache : {} },
    local.opensearch_exists ? yamldecode(file(local.opensearch_config_file)) : { opensearch : {} },
    local.amazonmq_exists ? yamldecode(file(local.amazonmq_config_file)) : { amazonmq : {} }
  )
}
