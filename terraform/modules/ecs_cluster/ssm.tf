# config for cloudwatch agent
# shared by all instances
# TODO Nothing secret here so should move to S3 and pass in as an env var

resource "aws_ssm_parameter" "ecs-cwagent" {
  name  = "ecs-cwagent"
  type  = "String"
  value = <<EOF
{ "logs": 
  { 
    "metrics_collected": 
    {
      "emf": {} 
    }
  }, 
  "metrics": 
  { 
    "metrics_collected": 
    { 
      "statsd": {}
    }
  }
}
EOF
}