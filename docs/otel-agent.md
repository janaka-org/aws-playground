## OTel Collector
Setting up OTel Collector/Export as an Agent. Agent mode, side car, is the recommended deployment.

https://github.com/open-telemetry/opentelemetry-collector/releases

docker pull otel/opentelemetry-collector-contrib:0.3.0

OTel Collector architecture and pipeline config docs https://github.com/open-telemetry/opentelemetry-collector/blob/master/docs/design.md

Looks like one can override specific config values with env var. https://github.com/open-telemetry/opentelemetry-collector/issues/557 https://blog.gopheracademy.com/advent-2014/configuration-with-fangs/

enable otel reveiver with default config [ref](https://github.com/open-telemetry/opentelemetry-collector/blob/master/receiver/README.md#opentelemetry-receiver)

otlp reveiver config options and defaults https://github.com/open-telemetry/opentelemetry-collector/blob/master/receiver/otlpreceiver/testdata/config.yaml

otlp exporter config options https://github.com/open-telemetry/opentelemetry-collector/blob/master/exporter/otlpexporter/testdata/config.yaml

Examples [here](../docker/otel-collector) and [here](../docker/envoy-sandbox)


```yaml
receivers:
  otlp:
    endpoint: 0.0.0.0:55680 # default is localhost:55680 https://github.com/open-telemetry/opentelemetry-collector/blob/665d64efef4637b8216108ed07d8b93a443833dd/receiver/otlpreceiver/factory.go#L50
```

```yaml
exporters:
  otlp:
```



## [OTel .NET client example](https://github.com/open-telemetry/opentelemetry-dotnet/tree/master/samples/Exporters/Web) 

Honeycomb .NET Core OTel exporter example https://github.com/martinjt/Honeycomb.OpenTelemetry
Could be useful while figuring out the proper setup

Add packages
Check for latest release versions here https://www.nuget.org/packages?q=opentelemetry
```sh
dotnet add package OpenTelemetry --version 0.2.0-alpha.275
dotnet add package OpenTelemetry.Adapter.AspNetCore --version 0.2.0-alpha.275
dotnet add package OpenTelemetry.Adapter.Dependencies --version 0.2.0-alpha.275
dotnet add package OpenTelemetry.Hosting --version 0.2.0-alpha.275
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol --version 0.2.0-alpha.275 
```


startup.cs
```cs

using System;
using System.IO;
using System.Reflection;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using OpenTelemetry.Trace.Configuration;

public void ConfigureServices(IServiceCollection services)
{
    services.AddControllers();

    services.AddOpenTelemetry((sp, builder) =>
    {
        builder
            //.SetSampler(Samplers.AlwaysSample)
            .UseZipkin(options =>
            {
                options.ServiceName = "test-zipkin";
                options.Endpoint = new Uri(this.Configuration.GetValue<string>("Zipkin:Endpoint"));
            })
            .AddRequestInstrumentation()
            .AddDependencyInstrumentation();
    });
}
```

appsettings.json
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "AllowedHosts": "*",
  "Zipkin": {
    "Endpoint": "http://localhost:9411/api/v2/spans"
  }
}
```



## OTel Collector cli args



```sh
		"--config=testdata/otelcol-config.yaml",
```

Code ref for metrics args https://github.com/open-telemetry/opentelemetry-collector/blob/366363c800430f57f59510fcd15d9cd2f083d823/internal/collector/telemetry/telemetry.go#L54
```sh
		"--metrics-addr=localhost:<port>",
		"--metrics-prefix=",
    "--metrics-level="
		"--add-instance-id=true",
```