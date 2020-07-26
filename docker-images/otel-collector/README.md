
## [OTel Collector Demo](https://github.com/open-telemetry/opentelemetry-collector/tree/master/examples/demo) 

- Applications send data directly to a Collector configured to use fewer resources, aka the agent;
- The agent then forwards the data to Collector(s) that receive data from multiple agents. Collectors on this layer typically are allowed to use more resources and queue more data;
- The Collector then sends the data to the appropriate backend, in this demo Jaeger, Zipkin, and Prometheus;

Add `.env` file with the following. Change container image to your registry location. 

```sh
OTELCOLL_CORE_IMG=<aws_acount_id>.dkr.ecr.eu-west-1.amazonaws.com/janaka/otel/opentelemetry-collector-dev:latest
OTELCOLL_CONTRIB_IMG=<aws_account_id>.dkr.ecr.eu-west-1.amazonaws.com/janaka/otel/opentelemetry-collector-contrib:latest
 
OTELCOL_ARGS=
```


To start `docker-compose up -d`

`/agent-core` and `/collector-contrib` build and push images with config which makes it easier to test with AWS Fargate.