[
  {
    "name": "${container_name}",
    "image": "${image_url}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 9090
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${deploy_env_name}/${container_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "otel"
      }
    }
  }
]