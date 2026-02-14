variable "policy_name" {
  type = string
}

variable "policy_description" {
  type    = string
  default = "Managed by Terraform"
}

variable "environment" {
  type = string
}

variable "statements" {
  description = "List of policy statements"
  type = list(object({
    sid       = optional(string)
    actions   = list(string)
    resources = list(string)
    effect    = optional(string, "Allow")
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [])
    # Re-added conditions as an optional list of objects
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
}
