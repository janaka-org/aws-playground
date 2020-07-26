data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-eu-west-1-885974474200"
  #acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "hello-world-api_codepipeline_role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
    "Effect": "Allow",
    "Principal": {
    "Service": "codepipeline.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
}
]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "codedeploy:CreateDeployment",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:GetApplicationRevision",
            "codedeploy:RegisterApplicationRevision",
            "codedeploy:GetApplication",
            "ecs:RegisterTaskDefinition",
            "ecr:*"
        ],
        "Resource": "*",
        "Effect": "Allow"
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${data.aws_s3_bucket.codepipeline_bucket.arn}",
        "${data.aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# data "aws_kms_alias" "s3kmskey" {
#   name = "arn:aws:kms:eu-west-1:<aws_account_id_here>:alias/aws/s3"
# }

resource "aws_codepipeline" "codepipeline" {
  name     = "hello-world-api_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = data.aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    # encryption_key {
    #   id   = data.aws_kms_alias.s3kmskey.arn
    #   type = "KMS"
    # }
  }

  stage {
    name = "Source"

    action {
      name             = "SourceCode"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceCodeArtifact"]

      configuration = {
        Owner  = "janaka-org"
        Repo   = "aws-app-mesh-example"
        Branch = "master"
        PollForSourceChanges = false
      }
    }

    action {
      name             = "SourceImage"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["SourceImageArtifact"]

      configuration = {
        RepositoryName   = "janaka/aws-app-mesh-example/hello-world-api"
        ImageTag = "latest"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildContainerImage"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceCodeArtifact"]
      #output_artifacts = ["DefinitionArtifact", "ImageArtifact"]
      version          = "1"

      configuration = {
        ProjectName = "hello-world-api"
      }
    }
  }
  

  stage {
    name = "Deploy"

    action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeployToECS"
        input_artifacts = ["SourceCodeArtifact", "SourceImageArtifact"]
        version         = "1"

        configuration = {
            ApplicationName                 = "hello-world-api"
            DeploymentGroupName             = "hello_world_api-deployment-group"
            TaskDefinitionTemplateArtifact  = "SourceCodeArtifact"
            TaskDefinitionTemplatePath      = "hello-world-api/taskdef.json"
            AppSpecTemplateArtifact         = "SourceCodeArtifact"
            AppSpecTemplatePath             = "hello-world-api/appspec.yaml"
            Image1ArtifactName              = "SourceImageArtifact",
            Image1ContainerName             = "IMAGE1_NAME",
        }
    }
  }
}

# setting up the webhook via TF doesn't work, at the moment, for repos in an individual account
# as opposed to a repo in a org account.
# See GH issue https://github.com/terraform-providers/terraform-provider-github/issues/45

# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
# Would probably be better to pull this from the environment
# or something like SSM Parameter Store.

# locals {
#   webhook_secret = ""
# }

data "github_repository" "repo" {
  full_name = "janaka-org/aws-app-mesh-example"
}

resource "aws_codepipeline_webhook" "hello-world-api_webhook" {
  name            = "hello-world-api-webhook-github"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.codepipeline.name

  authentication_configuration {
    secret_token = local.webhook_secret
  }

  filter {
    json_path    = "$.commits[*]"
    match_equals = "hello-world-api/(src/.*|version)"
  }
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "hello-world-api" {
  repository = data.github_repository.repo.name

  configuration {
    url          = aws_codepipeline_webhook.hello-world-api_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = local.webhook_secret
  }

  events = ["push"]
}