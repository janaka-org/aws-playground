# Local .env
if [ -f .env ]; then
    # Load Environment Variables
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
    echo $AWS_REGION
fi

aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/janaka/otel/opentelemetry-collector-contrib
docker build -t janaka/otel/opentelemetry-collector-contrib:latest .
docker tag janaka/otel/opentelemetry-collector-contrib:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/janaka/otel/opentelemetry-collector-contrib:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/janaka/otel/opentelemetry-collector-contrib:latest