resource "aws_iam_policy" "this" {
  name        = var.policy_name
  description = var.policy_description
  policy      = data.aws_iam_policy_document.this.json

  tags = {
    Environment      = var.environment
    ManagedBy        = "Terraform"
    CreatedOrUpdated = timestamp()
  }
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.statements
    content {
      sid       = lookup(statement.value, "sid", null)
      actions   = statement.value.actions
      resources = statement.value.resources
      effect    = lookup(statement.value, "effect", "Allow")

      # Principals block (Used for Resource Policies/Trust Relationships)
      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      # Condition block (Now correctly structured for future use)
      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}
