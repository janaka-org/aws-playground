using System;
using Amazon.XRay.Recorder.Handlers.System.Net;
using Amazon.XRay.Recorder.Core;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

using OpenTelemetry.Trace.Configuration; 
// using OpenTelemetry.Resources;
// using OpenTelemetry.Exporter.OpenTelemetryProtocol;
// using Grpc.Core;

namespace hello_world_api
{
    public class Startup
    {
        private readonly ILogger<Startup> _logger;
        public Startup(ILogger<Startup> logger, IConfiguration configuration)
        {
            _logger = logger;
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            string ServiceDiscoveryNamespace, AspnetcoreEnvironment, AwsRegion;
            ServiceDiscoveryNamespace = Environment.GetEnvironmentVariable("SERVICE_DISCOVERY_NAMESPACE");
            AspnetcoreEnvironment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
            AwsRegion = Environment.GetEnvironmentVariable("AWS_REGION");
            _logger.LogDebug($"Env vars: SERVICE_DISCOVERY_NAMESPACE={ServiceDiscoveryNamespace}, ASPNETCORE_ENVIRONMENT={AspnetcoreEnvironment}, AWS_REGION={AwsRegion}");

            if (ServiceDiscoveryNamespace == null) {
                throw new ArgumentNullException("SERVICE_DISCOVERY_NAMESPACE", "This environment variable is `null`. Check spelling of the env var being set. Make sure a valid value is being set.");
            }

            services.AddControllers();

            var zipkinEndpoint = "http://localhost:9411/api/v2/spans";
            //var zipkinEndpoint = this.Configuration.GetValue<string>("Zipkin:Endpoint");
            _logger.LogDebug($"Zipkin:Endpoint={zipkinEndpoint}");
            if (zipkinEndpoint == null) {
                throw new ArgumentNullException("zipkinEndpoint", "endpoint address cannot be empty. Use localhost:9411 to send to the local OTel agent");
            }

            // var otlpEndpoint = this.Configuration.GetValue<string>("otlp:Endpoint");
            // if (otlpEndpoint == null) {
            //     throw new ArgumentNullException("otlpEndpoint", "endpoint address cannot be empty");
            // }

            // ref https://github.com/open-telemetry/opentelemetry-dotnet/blob/master/src/OpenTelemetry.Exporter.OpenTelemetryProtocol/TracerBuilderExtensions.cs
            // services.AddOpenTelemetry((sp, builder) =>
            // {
            //     builder
            //         .SetResource(Resources.CreateServiceResource("hello-world-api"))
            //         .UseOpenTelemetryProtocolExporter (options =>
            //         {
            //             options.Credentials = ChannelCredentials.Insecure;
            //             options.Endpoint = otlpEndpoint;
            //         })
            //         .AddRequestAdapter()
            //         .AddDependencyAdapter(); 
            // });

            services.AddOpenTelemetry((sp, builder) =>
            {
                builder
                    //.SetSampler(Samplers.AlwaysSample)
                    
                    .UseZipkin(options =>
                    {
                        options.ServiceName = "hello-world-api";
                        options.Endpoint = new Uri(zipkinEndpoint);
                    })
                    .AddRequestAdapter()
                    .AddDependencyAdapter(); 
            });

            //AWSXRayRecorder.InitializeInstance(configuration: Configuration);
            //services.AddTransient<HttpClientXRayTracingHandler>();
            services.AddHttpClient("timenowapi", c =>
            {  
                c.BaseAddress = new Uri($"http://time-now-api.{ServiceDiscoveryNamespace}/"); // for AWS CloudMap / App Mesh experiment
                //c.BaseAddress = new Uri("http://localhost:5000/"); 
                c.DefaultRequestHeaders.Add("User-Agent", "HttpClientFactory-HelloWorld");
            });
            
            //.AddHttpMessageHandler<HttpClientXRayTracingHandler>();

            services.AddLogging(logging => 
            { 
                logging.AddAWSProvider(Configuration.GetAWSLoggingConfigSection()); 
                logging.SetMinimumLevel(LogLevel.Debug); 
            });

            
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            app.UseExceptionHandler("/error");
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            //app.UseXRay("hello-world-api");
            app.UseRouting();
            app.UseAuthorization();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
            //app.UseHttpsRedirection();
            
        }
    }
}
