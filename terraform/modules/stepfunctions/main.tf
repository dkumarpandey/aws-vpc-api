resource "aws_iam_role" "stepfunctions_role" {

  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "states.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "stepfunctions_policy" {

  name = "${var.state_machine_name}-policy"

  role = aws_iam_role.stepfunctions_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "lambda:InvokeFunction"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "this" {

  name = var.state_machine_name

  role_arn = aws_iam_role.stepfunctions_role.arn

  definition = templatefile(
    "${path.module}/state-machine-definition.json",
    {
      create_vpc_lambda_arn       = var.create_vpc_lambda_arn
      create_subnets_lambda_arn   = var.create_subnets_lambda_arn
      persist_metadata_lambda_arn = var.persist_metadata_lambda_arn
      rollback_lambda_arn         = var.rollback_lambda_arn
    }
  )

  tags = var.tags
}