##############################################################################
# Fail State Locals
##############################################################################

locals {
  all_bucket_names = [
    for bucket in var.cos_buckets :
    bucket.shortname
  ]
  flow_logs_bucket_names = [
    for network in var.vpc_flow_logs_data :
    network.flow_logs_bucket_name if network.flow_logs_bucket_name != null
  ]
}

##############################################################################

##############################################################################
# Fail if COS bucket for Flow Logs instance is not found
##############################################################################

locals {
  flow_logs_cos_bucket_not_found = length([
    for name in local.flow_logs_bucket_names :
    true if !contains(local.all_bucket_names, name)
  ]) != 0
  CONFIGURATION_FAILURE_flow_logs_cos_bucket_not_found = regex("false", local.flow_logs_cos_bucket_not_found)
}

##############################################################################