# Local .env
if [ -f .env ]; then
    # Load Environment Variables
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
    echo $AWS_REGION
fi

# auth to the AWS source ECR repo
# See README.md for details on the managed policy needed
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin 840364872350.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy
docker build -t janaka/aws-appmesh-envoy:v1.12.3.0-prod .

#auth to our destination ECR repo
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/janaka/aws-appmesh-envoy
docker tag janaka/aws-appmesh-envoy:v1.12.3.0-prod $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/janaka/aws-appmesh-envoy:v1.12.3.0-prod
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/janaka/aws-appmesh-envoy:v1.12.3.0-prod

