
# data "aws_iam_group" "service_accounts_group" {
#   group_name = "ServiceAccounts"
# }

# resource "aws_iam_user" "service_account_user" {
#   name = "sa-aws_app_mesh_example"
#   path = "/"
# }

# resource "aws_iam_user_group_membership" "add_to_service_accounts" {
#   user = aws_iam_user.service_account_user.name

#   groups = [
#     data.aws_iam_group.service_accounts_group.name,
#   ]
# }

# resource "aws_iam_user_policy" "service_account_user_policy" {
#   name = "PolicyForGithubActionsAWSAppMeshExample"
#   user = aws_iam_user.service_account_user.name

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "GetAuthorizationToken",
#             "Effect": "Allow",
#             "Action": [
#                 "ecr:GetAuthorizationToken"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "AllowPush",
#             "Effect": "Allow",
#             "Action": [
#                 "ecr:GetDownloadUrlForLayer",
#                 "ecr:BatchGetImage",
#                 "ecr:BatchCheckLayerAvailability",
#                 "ecr:PutImage",
#                 "ecr:InitiateLayerUpload",
#                 "ecr:UploadLayerPart",
#                 "ecr:CompleteLayerUpload"
#             ],
#             "Resource": [
#                 "arn:aws:ecr:*:<aws_account_id_here>:repository/janaka/aws-app-mesh-example/hello-world-api",
#                 "arn:aws:ecr:*:<aws_account_id_here>:repository/janaka/aws-app-mesh-example/time-now-api"
#             ]
#         },
#         {
#             "Sid": "RegisterTaskDefinition",
#             "Effect": "Allow",
#             "Action": [
#                 "ecs:RegisterTaskDefinition"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "PassRolesInTaskDefinition",
#             "Effect": "Allow",
#             "Action": [
#                 "iam:PassRole"
#             ],
#             "Resource": [
#                 "arn:aws:iam::<aws_account_id_here>:role/AWSServiceRoleForECS",
#                 "arn:aws:iam::<aws_account_id_here>:role/ecsTaskExecutionRole_hello-world-api"
#                 "arn:aws:iam::<aws_account_id_here>:role/ecsTaskExecutionRole_time-now-api"
#             ]
#         },
#         {
#             "Sid": "DeployService",
#             "Effect": "Allow",
#             "Action": [
#                 "ecs:UpdateService",
#                 "ecs:DescribeServices",
#                 "codedeploy:GetDeploymentGroup"
#             ],
#             "Resource": [
#                 "arn:aws:ecs:*:<aws_account_id_here>:service/janaka-experiments/service-hello-world-api",
#                 "arn:aws:ecs:*:<aws_account_id_here>:service/janaka-experiments/service-time-now-api"
#             ]
#         }
#     ]
# }
# EOF
# }

# resource "aws_iam_access_key" "service_account_keys" {
#   user = aws_iam_user.service_account_user.name
# }



# data "github_actions_public_key" "example_public_key" {
#   repository = "aws-app-mesh-example"
# }

# resource "github_actions_secret" "AWS_ACCESS_KEY_ID" {
#   repository       = "aws-app-mesh-example"
#   secret_name      = " AWS_ACCESS_KEY_ID"
#   plaintext_value  = service_account_keys.id
# }

# resource "github_actions_secret" "AWS_SECRET_ACCESS_KEY" {
#   repository       = "aws-app-mesh-example"
#   secret_name      = " AWS_SECRET_ACCESS_KEY"
#   plaintext_value  = service_account_keys.secret
# }

