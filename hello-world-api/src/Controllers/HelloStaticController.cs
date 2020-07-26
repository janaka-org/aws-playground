using Microsoft.AspNetCore.Mvc;

namespace hello_world_api.Controllers
{
    [Route("[controller]")]
    [Controller]
    public class HelloStaticController : ControllerBase
    {
        // GET healthcheck
        [HttpGet]
        public ActionResult<string> Get()
        {
            return "Hello world static!";
        }
    }
}
