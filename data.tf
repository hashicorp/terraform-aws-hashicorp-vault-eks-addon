data "aws_iam_policy_document" "vault_iam_policy_document" {
  count = var.auto_unseal ? 1 : 0
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = [var.auto_unseal_kms_key_arn]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}
