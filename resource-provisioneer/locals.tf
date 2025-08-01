locals {
  config_file               = "configurations/${terraform.workspace}/config.yaml"
  kms_config_file           = "configurations/${terraform.workspace}/kms.yaml"
  s3_config_file            = "configurations/${terraform.workspace}/s3.yaml"
  irsa_config_file          = "configurations/${terraform.workspace}/irsa.yaml"
  dynamodb_config_file      = "configurations/${terraform.workspace}/dynamodb.yaml"
  vault_config_file         = "configurations/${terraform.workspace}/vault.yaml"
  cloudfront_config_file    = "configurations/${terraform.workspace}/cloudfront.yaml"
  alb_config_file           = "configurations/${terraform.workspace}/alb.yaml"
  lambda_config_file        = "configurations/${terraform.workspace}/lambda.yaml"
  sg_config_file            = "configurations/${terraform.workspace}/sg.yaml"
  sns_config_file           = "configurations/${terraform.workspace}/sns.yaml"
  mediaconvert_config_file  = "configurations/${terraform.workspace}/mediaconvert.yaml"
  eventbridge_config_file   = "configurations/${terraform.workspace}/eventbridge.yaml"
  sqs_config_file           = "configurations/${terraform.workspace}/sqs.yaml"
  stepfunctions_config_file = "configurations/${terraform.workspace}/stepfunctions.yaml"
  apigateway_config_file    = "configurations/${terraform.workspace}/apigateway.yaml"
  efs_config_file           = "configurations/${terraform.workspace}/efs.yaml"
  lb_config_file            = "configurations/${terraform.workspace}/lb.yaml"
  iam_config_file           = "configurations/${terraform.workspace}/iam.yaml"

  kms_exists           = fileexists(local.kms_config_file)
  s3_exists            = fileexists(local.s3_config_file)
  irsa_exists          = fileexists(local.irsa_config_file)
  dynamodb_exists      = fileexists(local.dynamodb_config_file)
  vault_exists         = fileexists(local.vault_config_file)
  cloudfront_exists    = fileexists(local.cloudfront_config_file)
  alb_exists           = fileexists(local.alb_config_file)
  lambda_exists        = fileexists(local.lambda_config_file)
  sg_exists            = fileexists(local.sg_config_file)
  sns_exists           = fileexists(local.sns_config_file)
  mediaconvert_exists  = fileexists(local.mediaconvert_config_file)
  eventbridge_exists   = fileexists(local.eventbridge_config_file)
  sqs_exists           = fileexists(local.sqs_config_file)
  stepfunctions_exists = fileexists(local.stepfunctions_config_file)
  apigateway_exists    = fileexists(local.apigateway_config_file)
  efs_exists           = fileexists(local.efs_config_file)
  lb_exists            = fileexists(local.lb_config_file)
  iam_exists           = fileexists(local.iam_config_file)

  config = merge(
    yamldecode(file(local.config_file)),
    local.kms_exists ? yamldecode(file(local.kms_config_file)) : { kms : null },
    local.s3_exists ? yamldecode(file(local.s3_config_file)) : { s3 : {} },
    local.irsa_exists ? yamldecode(file(local.irsa_config_file)) : { irsa : {} },
    local.dynamodb_exists ? yamldecode(file(local.dynamodb_config_file)) : { dynamodb : {} },
    local.vault_exists ? yamldecode(file(local.vault_config_file)) : null,
    local.cloudfront_exists ? yamldecode(file(local.cloudfront_config_file)) : { cloudfront : {} },
    local.alb_exists ? yamldecode(file(local.alb_config_file)) : { alb : {} },
    local.lambda_exists ? yamldecode(file(local.lambda_config_file)) : { lambda : null },
    local.sg_exists ? yamldecode(file(local.sg_config_file)) : { sg : null },
    local.sns_exists ? yamldecode(file(local.sns_config_file)) : { sns : {} },
    local.mediaconvert_exists ? yamldecode(file(local.mediaconvert_config_file)) : { mediaconvert : {} },
    local.eventbridge_exists ? yamldecode(file(local.eventbridge_config_file)) : { eventbridge : {} },
    local.sqs_exists ? yamldecode(file(local.sqs_config_file)) : { sqs : {} },
    local.stepfunctions_exists ? yamldecode(file(local.stepfunctions_config_file)) : { stepfunctions : {} },
    local.apigateway_exists ? yamldecode(file(local.apigateway_config_file)) : { apigateway : {} },
    local.efs_exists ? yamldecode(file(local.efs_config_file)) : { efs : {} },
    local.lb_exists ? yamldecode(file(local.lb_config_file)) : { lb : {} },
    local.iam_exists ? yamldecode(file(local.iam_config_file)) : { iam : {} }
  )
}
