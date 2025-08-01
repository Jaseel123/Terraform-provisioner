# Resource Provisioner

Used to provision below reources
- KMS
- [S3](#s3)
- DynamoDB
- IRSA(IAM role for service account)
- vault configs
- Cloudfront
- LB
- lambda
- Security groups
- SNS
- SQS
- Media convert
- EventBridge
- Step Functions

## S3 <a id="s3"></a>

```yaml
s3:
  example-bucket:
    bucket_prefix: (Optional) - To give a prefix to the bucket name
    versioning_enabled: (Optional) - Enable bucket versioning, defaults to false
    encryption_mode: (Optional) - Enable encryption for the bucket, defaults to AES256. valid values are AES256 and aws:kms
    kms_key_arn: (Optional) - required in encruption mode is set to aws:kms
    force_destroy: (Optional) - force destroy the bucket, default false
    lifecycle_policy: (Optional) -lifecycle policies for the bucket
      enabled: true
      rules:
      - id: rule id
        enabled: true
        abort_incomplete_multipart_upload_days: 7
    website_configuration:
      enabled: false
      index_document: index.html
      error_document: error.html
      routing_rules: []
    public_access:
      block_public_acls: true
      block_public_policy: true
      ignore_public_acls: true
      restrict_public_buckets: true
    create_bucket_notification: true
    lambda_notification:
      lambda_function:
        id:
        function_arn:
        events:
        filter_prefix:
        filter_suffix:
    sqs_notification: {}
    sns_notification: {}
    create_sns_policy: false
    create_sqa_policy: false
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.37.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 3.25.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/alb.git | initial-ver |
| <a name="module_apigateway"></a> [apigateway](#module\_apigateway) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/api-gateway.git | main |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/cloudfront.git | initial-version |
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/dynamodb.git | v1.0.1 |
| <a name="module_eventbridge"></a> [eventbridge](#module\_eventbridge) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/eventbridge.git | initial-version |
| <a name="module_irsa"></a> [irsa](#module\_irsa) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/irsa.git | main |
| <a name="module_kms"></a> [kms](#module\_kms) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/kms.git | v1.0.0 |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/lambda.git | initial-version |
| <a name="module_mediaconvert"></a> [mediaconvert](#module\_mediaconvert) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/media-convert.git | initial-version |
| <a name="module_s3"></a> [s3](#module\_s3) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/s3.git | main |
| <a name="module_sg"></a> [sg](#module\_sg) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/sg.git | initial-version |
| <a name="module_sns"></a> [sns](#module\_sns) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/sns.git | initial-version |
| <a name="module_sqs"></a> [sqs](#module\_sqs) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/sqs.git | initial-version |
| <a name="module_stepfunctions"></a> [stepfunctions](#module\_stepfunctions) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/step-functions.git | main |
| <a name="module_vault-auth-config"></a> [vault-auth-config](#module\_vault-auth-config) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/vault.git//kubernetes-auth-backend | v1.1.0 |
| <a name="module_vault-oidc"></a> [vault-oidc](#module\_vault-oidc) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/vault.git//oidc | v1.1.0 |
| <a name="module_vault-rsa"></a> [vault-rsa](#module\_vault-rsa) | git::https://gitlab.avrioc.io/devops/platform-automations/terraform-modules/vault.git//VRSA | v1.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vault_role_id"></a> [vault\_role\_id](#input\_vault\_role\_id) | Role id to authenticate with vault | `string` | n/a | yes |
| <a name="input_vault_secret_id"></a> [vault\_secret\_id](#input\_vault\_secret\_id) | Secret id to authenticate with vault | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->