[
  {
    "name": "${container_name}",
    "image": "${image_url}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "dependsOn": [
      {
        "containerName": "envoy",
        "condition": "HEALTHY"
      },
      {
        "containerName": "cloudwatch-agent",
        "condition": "START"
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "80"
      },
      {
        "name": "HEALTHCHECK",
        "value": "/healthcheck"
      },
      {
        "name": "ENABLE_LOGGING",
        "value": "true"
      },
      {
        "name": "APP_NAME",
        "value": "${container_name}"
      },
      {
        "name": "ASPNETCORE_ENVIRONMENT",  
        "value": "Production"
      },
      {
        "name": "AWS_REGION",
        "value": "${aws_region}"
      },
      {
        "name": "SERVICE_DISCOVERY_NAMESPACE",
        "value": "${service_discovery_namespace}"
      },
      {
        "name": "AWS_XRAY_TRACING_NAME",
        "value": "${container_name}"
      }

    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${deploy_env_name}/${container_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  },
  {
    "name": "envoy",
    "image": "840364872350.dkr.ecr.${aws_region}.amazonaws.com/aws-appmesh-envoy:v1.12.3.0-prod",
    "essential": true,
    "user": "1337",
    "portMappings": [
      {
        "containerPort": 9901,
        "protocol": "tcp"
      },
      {
        "containerPort": 15000,
        "protocol": "tcp"
      },
      {
        "containerPort": 15001,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "APPMESH_VIRTUAL_NODE_NAME",
        "value": "mesh/${appmesh_name}/virtualNode/node-${container_name}"
      },
      {
        "name": "ENABLE_ENVOY_XRAY_TRACING",
        "value": "1"
      },
      {
        "name": "ENABLE_ENVOY_STATS_TAGS",
        "value": "1"
      },
      {
        "name": "ENABLE_ENVOY_DOG_STATSD",
        "value": "1"
      },
      {
        "name": "ENVOY_LOG_LEVEL",
        "value": "${ENVOY_LOG_LEVEL}"
      }
    ],
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
      ],
      "startPeriod": 10,
      "interval": 5,
      "timeout": 2,
      "retries": 3
    },
    "ulimits": [
      {
        "name": "nofile",
        "hardLimit": 15000,
        "softLimit": 15000
      }
    ],
    "dependsOn": [
      {
        "containerName": "xray-daemon",
        "condition": "START"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${deploy_env_name}/${container_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "envoy"
      }
    }
  },
  {
    "name": "xray-daemon",
    "image": "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/janaka/amazon/aws-xray-daemon:latest",
    "user": "1337",
    "essential": true,
    "memoryReservation": 256,
    "portMappings": [
      {
        "containerPort": 2000,
        "protocol": "udp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${deploy_env_name}/${container_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "xray-daemon"
      }
    }
  },
  {
    "name": "cloudwatch-agent",
    "image": "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/janaka/amazon/cloudwatch-agent:latest",
    "user": "1337",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8125,
        "protocol": "udp"
      }
    ],
    "secrets": [
      {
          "name": "CW_CONFIG_CONTENT",
          "valueFrom": "ecs-cwagent"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${deploy_env_name}/${container_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "cw-agent"
      }
    }
  }
]