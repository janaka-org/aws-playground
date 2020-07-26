# Time Now API

This service is part of the microservice demo system. It can be used to experiment with various new technologies. The [Hello World API](https://github.com/janaka/aws-app-mesh-example/tree/master/time-now-api) depends on this service

## Build and Publish the app

### CI/CD

Bump the version number in the repo `version` file triggers the app to be built and published as Docker image in ECR (AWS account `Janaka Personal`).

TODO `<make this also deploy>` update instructions here.

### Manual

Build the image
`$ docker build -t time-now-api .`

ECR auth - generate docker login command
`$ aws ecr get-login --region eu-west-1 --profile janakapersonal --no-include-email`

Run the docker login command that is output from previous step

Tag the image locally
`$ docker tag time-now-api <your_aws_account_id>.dkr.ecr.eu-west-1.amazonaws.com/janaka/aws-app-mesh-example/time-now-api:1.0`

Push the image to ECR
`$ docker push <your_aws_account_id>.dkr.ecr.eu-west-1.amazonaws.com/janaka/aws-app-mesh-example/time-now-api`

## Running the container locally

`$ docker run -d -p 8080:80 --name time-now-api time-now-api`

Browse <http://localhost:8080/api/timenow>

## Dev and debug locally

TODO `<add instrcution>`

* Run the `time-now-api`
* Run this service

## Testing 

* browse to `http://localhost:5000/api/timenow`
* `<current date and time>` should be displayed
* each time you refresh the time should update.

## AWS Infrastructure setup

Ditched CDK. Migrating to Terraform

~Use CDK and `FargateSerciceStack` in the `janakacdk` projects to setup the infrastructure.~

