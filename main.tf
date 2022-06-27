##############################################################################
# Bucket List to Map
##############################################################################

module "bucket_map" {
  source         = "./list_to_map"
  list           = var.cos_buckets
  key_name_field = "shortname"
}

##############################################################################

##############################################################################
# COS Map
##############################################################################

module "cos_map" {
  source         = "./list_to_map"
  list           = var.cos_instances
  key_name_field = "shortname"
}

##############################################################################

##############################################################################
# VPC List to Map
##############################################################################

module "vpc_map" {
  source         = "./list_to_map"
  list           = var.vpc_flow_logs_data
  key_name_field = "vpc_prefix"
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  ##############################################################################
  # local.flow_logs_vpc_to_cos_instance_map
  # > Map of VPCs and COS buckets used to create flow logs collectors
  ##############################################################################
  flow_logs_vpc_to_cos_instance_map = {
    for network in var.vpc_flow_logs_data :
    (network.vpc_prefix) => module.bucket_map.value[network.flow_logs_bucket_name] if network.flow_logs_bucket_name != null
  }
}

##############################################################################

##############################################################################
# Flow Logs Service Authorizations
##############################################################################

resource "ibm_iam_authorization_policy" "flow_logs_policy" {
  for_each                    = module.cos_map.value
  source_service_name         = "is"
  source_resource_type        = "flow-log-collector"
  description                 = "Allow flow logs write access cloud object storage instance"
  roles                       = ["Writer"]
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = split(":", each.value.id)[7]
}

##############################################################################

##############################################################################
# Flow Logs
##############################################################################

resource "ibm_is_flow_log" "flow_logs" {
  for_each       = local.flow_logs_vpc_to_cos_instance_map
  name           = "${var.prefix}-${each.key}-flow-logs"
  target         = module.vpc_map.value[each.key].vpc_id
  active         = true
  storage_bucket = each.value.name
  resource_group = lookup(module.vpc_map.value[each.key], "resource_group_id", null)
  depends_on     = [ibm_iam_authorization_policy.flow_logs_policy]
}

##############################################################################