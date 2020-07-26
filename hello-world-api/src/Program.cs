
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;

namespace hello_world_api
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateWebHostBuilder(args).Build().Run();
        }
        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                // .ConfigureLogging(logging =>
                // {
                //     logging.AddAWSProvider(); // AWS CloudWatch provider

                //     // When you need logging below set the minimum level. Otherwise the logging framework will default to Informational for external providers.
                //     logging.SetMinimumLevel(LogLevel.Debug);
                // })
                .UseStartup<Startup>();
    }
}
