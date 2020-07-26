{
    "executionRoleArn": "${execution_role_arn}",
    "family": "${family}",
    "networkMode": "awsvpc",
    "volumes": [],
    "placementConstraints": [],  
    "cpu": "256",
    "memory": "1024",
    "requiresCompatibilities": [
      "FARGATE"
    ],
    "containerDefinitions": ${container_defs}
  }