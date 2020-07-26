using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace hello_world_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HelloController : ControllerBase
    {
        private readonly IHttpClientFactory _clientFactory;

        private readonly ILogger _logger;
        public HelloController(IHttpClientFactory clientFactory, ILogger<HelloController> logger)
        {
            _clientFactory = clientFactory;
            _logger = logger;
        }
        // GET api/hello
        [HttpGet]
        public async Task<ActionResult<string>> Get()
        {
            var request = new HttpRequestMessage(HttpMethod.Get, "api/timenow");

            var client = _clientFactory.CreateClient("timenowapi");

            var result = "<empty>";

            try {                                                                                    
                _logger.LogInformation("Call api/timenow");
                var response = await client.SendAsync(request);
                var statuscode = response.IsSuccessStatusCode;
                if (statuscode)
                {
                    result = await response.Content.ReadAsStringAsync();
                }
                else
                {
                    result = "no date returned";
                }
                _logger.LogInformation("call api/timenow successfully: {statuscode}", statuscode);
            }
            catch (Exception e) {
                _logger.LogError("Oh an error: {e}", e);
            }
            finally {
                 result = "Hello World! " + result;
            }

            return result;
        }

        // // GET api/hello/5
        // [HttpGet("{id}")]
        // public ActionResult<string> Get(int id)
        // {
        //     return "value";
        // }

        // // POST api/hello
        // [HttpPost]
        // public void Post([FromBody] string value)
        // {
        // }

        // // PUT api/hello/5
        // [HttpPut("{id}")]
        // public void Put(int id, [FromBody] string value)
        // {
        // }

        // // DELETE api/hello/5
        // [HttpDelete("{id}")]
        // public void Delete(int id)
        // {
        // }
    }
}
