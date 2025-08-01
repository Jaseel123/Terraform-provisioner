locals {
  config = merge(
    yamldecode(file("configurations/${terraform.workspace}/config.yaml")),
    yamldecode(file("configurations/${terraform.workspace}/ecr.yaml"))
  )
}