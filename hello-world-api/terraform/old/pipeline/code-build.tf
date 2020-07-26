resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-eu-west-1-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation",
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ecr:eu-west-1:<aws_account_id_here>:repository/janaka/aws-app-mesh-example/hello-world-api"
            ],
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "ecr:GetAuthorizationToken"
            ]
        }
    ]
}
POLICY
}

resource "aws_codebuild_project" "hello-world-api" {
  name          = "hello-world-api"
  description   = "hello-world-api part of the aws-app-mesh-example repo"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  source {      
    # type            = "CODEPIPELINE"
    type            = "NO_SOURCE"
    # location        = "https://github.com/janaka-org/aws-app-mesh-example.git"
    # git_clone_depth = 1
    buildspec       = "hello-world-api/buildspec.yaml"
    # report_build_status = true
    
    # git_submodules_config {
    #   fetch_submodules = false
    # }
  }

  artifacts {
    //type = "CODEPIPELINE"
    type = "NO_ARTIFACT"
  }

#   cache {
#     type     = "S3"
#     location = data.aws_s3_bucket.codepipeline_bucket.bucket
#   }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/docker:18.09.0-1.7.0" #"aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "eu-west-1"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "<aws_account_id_here>"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "janaka/aws-app-mesh-example/hello-world-api"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
      type  = "PLAINTEXT"
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/hello-world-api"
      #stream_name = ""
    }

    s3_logs {
      status   = "ENABLED"
      location = "${data.aws_s3_bucket.codepipeline_bucket.id}/build-log"
    }
  }



}
