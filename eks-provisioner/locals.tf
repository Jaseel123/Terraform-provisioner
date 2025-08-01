locals {
  config = yamldecode(file("configurations/${terraform.workspace}/config.yaml"))
}