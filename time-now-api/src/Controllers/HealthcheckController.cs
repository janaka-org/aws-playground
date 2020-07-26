using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace time_now_api.Controllers
{
    [Route("[controller]")]
    [Controller]
    public class HealthcheckController : ControllerBase
    {
        // GET healthcheck
        [HttpGet]
        public ActionResult<string> Get()
        {
            return "healthy";
        }
    }
}
