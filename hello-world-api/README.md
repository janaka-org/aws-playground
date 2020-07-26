# Hello World API

This service is part of the microservice demo system. It can be used to experiment with various new technologies. It depends on the [time-now-api](https://github.com/janaka/aws-app-mesh-example/tree/master/time-now-api) service.

## Build and Publish the app

### CI/CD

Bump the version number in the repo `version` file triggers a app to be built and published as Docker image in ECR (AWS account `Janaka Personal`).

TODO `<make this also deploy>` update instructions here.

### Manual

Build the image
`$ docker build -t hellow-world-api .`

ECR auth - generate docker login command
`$ aws ecr get-login --region eu-west-1 --profile janakapersonal --no-include-email`

Run the docker login command that is output from previous step

Tag the image locally
`$ docker tag hello-world-api <your_aws_account_id>.dkr.ecr.eu-west-1.amazonaws.com/janaka/aws-app-mesh-example/hello-world-api:1.0`

Push the image to ECR
`$ docker push <your_aws_account_id>.dkr.ecr.eu-west-1.amazonaws.com/janaka/aws-app-mesh-example/hello-world-api`

## Running the container locally

`$ docker run -d -p 8080:80 --name hello-world-api hello-world-api`

Browse <http://localhost:8080/api/hello>

## Dev and debug locally

TODO `<add instrcution>`

## Testing 

* Run this service
* browse to `http://localhost:5001/api/hello`
* `Hello World! <current date and time> should be displayed`
* each time you refresh the time should update.

## AWS Infrastructure setup

Use Terraform config to setup Fargate service. 

~Use CDK and `FargateSerciceStack` in the `janakacdk` projects to setup the infrastructure.~

## Managing secrets in *.tf files. 

- don't use local state files and check into repo because values will appear in the json unencrypted
- Use AWS KMS to store the keys and the KMS tf provider to pull and use as data. 
-- Create the key as `symmetric`, `encrypt and decrypt` at `SYMMETRIC_DEFAULT`. 
-- Add encrypted secret using the AWS cli. More info [here](https://www.terraform.io/docs/providers/aws/d/kms_secrets.html) and [here](https://www.terraform.io/docs/providers/aws/d/kms_secrets.html)

`aws kms encrypt --region eu-west-1 --profile <profile_name> --key-id <kms_key> --plaintext fileb://<(echo '<text to encrypt here>') --encryption-context somekey=somevalue --query CiphertextBlob --output text` 

`aws kms decrypt --region eu-west-1 --profile <profile_name> --ciphertext-blob fileb://<(echo '<encrypted payload here>' | base64 -d) --encryption-context somekey=somevalue --output text --query Plaintext | base64 -d`