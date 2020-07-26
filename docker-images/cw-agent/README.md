In order to get Envoy metrics and Docker logs into CloudWatch one need to run a CloudWatch Agent as a sidecar container. With Fargate ECS using [this image](https://hub.docker.com/r/amazon/cloudwatch-agent) doesn't work. Two changes are required: 


1. It has insufficient to write to a particular path. According to this GH [issue](https://github.com/aws/aws-app-mesh-roadmap/issues/122) we need to use a modified CloudWatch Agent docker image to resolve.

2. Run as a known user ID (UID 1337) so it can be set to ignore traffic. 

