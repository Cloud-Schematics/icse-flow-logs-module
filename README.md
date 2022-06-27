# IBM Cloud Solution Engineering VPC Flow Logs

Create flow logs instances for VPC and service authorizations to allow flow log collectors to write to Cloud Object Storage.

---

## Table of Contains 

1. [Prerequisites](#prerequisites)
2. [Input Variables](#input-variables)
3. [Resources](#resources)
4. [Example Usage](#example-usage)

---

## Prerequisites

This module assumes that the following infrastructer has been created:
- VPC
- Cloud Object Storage Instances
- Object Storage Buckets

---

## Input Variables

This module expects three variables in addition to `prefix` to be passed in for the creation of Flow Logs resources.Full descriptions of input variables for this module can be found in [variables.tf](./variables.tf).

### Cloud Object Storage Variables

This module expects a list of `cos_instances` and `cos_buckets`.

These values are direct refernces to the outputs from either of the following modules:
- [ICSE Cloud Object Storage Module](https://github.com/Cloud-Schematics/cos-module)
- [ICSE Cloud Services Module](https://github.com/Cloud-Schematics/icse-cloud-services)

#### COS Instances Variable

```terraform
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
```

#### COS Buckets Variable

```terraform
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
```

### VPC Variables

This module expects a list of `vpc_flow_logs_data`. This is a direct reference to the output of the same name in the [ICSE Multiple VPC Network Module](https://github.com/Cloud-Schematics/icse-multiple-vpc-network)

#### VPC Flow Logs Data Variable

```terraform
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
```

---

## Resources

### IAM Authorization Policies

For each COS Instance passed using the `cos_instances` variable, a service authorization policy is created to allow Flow Logs Collector resources to write to buckets with that instance.

### Flow Logs Collectors

For each VPC passed with a valid value for `flow_logs_bucket_name`, a collector will be created for that VPC targetting the bucket with that name. This collector will be added to the VPC's resource group.

---

## Example Usage

```terraform
module "flow_logs" {
  source             = "github.com/Cloud-Schematics/icse-flow-logs-module"
  prefix             = var.prefix
  cos_instances      = module.services.cos_instances
  cos_buckets        = module.services.cos_buckets
  vpc_flow_logs_data = module.vpc.vpc_flow_logs_data
}
```