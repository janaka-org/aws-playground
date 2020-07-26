Create our own App Mesh Envoy image that includes an Envoy tracing config file for OTel.

All we are doing is inheriting the AWS App Mesh Envoy image and copying in our file. 

The App Mesh Envoy image supports providing override tracing config via the env var `ENVOY_STATS_CONFIG_FILE`.

On Fargate baking an image with the config is the easiest way to get the file copied. It's not the ideal way though. 

Managed policy needed to be able to pull the sourse app mesh envoy image from the AWS App Mesh ECR repo. Add the following to your aws dev user or CI/CD aws user
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GetAuthorizationToken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Stmt1591317456000",
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:DescribeImages",
                "ecr:DescribeRepositories",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages"
            ],
            "Resource": [
                "arn:aws:ecr:*:us-west-2:840364872350:repository/aws-appmesh-envoy"
            ]
        }
    ]
}
```
