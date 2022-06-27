##############################################################################
# Account Variables
##############################################################################

variable "prefix" {
  description = "The prefix that you would like to prepend to your resources"
  type        = string
}

##############################################################################


##############################################################################
# Flow Logs Variables
##############################################################################

variable "cos_instances" {
  description = "List of COS instances to create service authorizations. Data from ICSE Cloud Service Module"
  type = list(
    object({
      shortname = string # Common name for instance without prefix or suffix
      id        = string # ID of the service instance
      crn       = string # CRN of the service instance
      name      = string # Composed name of the service instance
    })
  )
}

variable "cos_buckets" {
  description = "List of buckets from ICSE Cloud Service Module"
  type = list(
    object({
      instance_shortname = string # Shortname of COS instance
      instance_id        = string # COS instance ID
      shortname          = string # bucket shortname
      id                 = string # Bucket ID
      name               = string # Bucket composed name
      crn                = string # Bucket CRN
    })
  )
}

variable "vpc_flow_logs_data" {
  description = "List of VPC data used for flow log creation"
  type = list(
    object({
      flow_logs_bucket_name = string # Short name for the bucket
      vpc_prefix            = string # Short name for the VPC
      vpc_id                = string # ID of the VPC
      resource_group_id     = string # Resource group ID where the VPC is provisioned
    })
  )
}

##############################################################################