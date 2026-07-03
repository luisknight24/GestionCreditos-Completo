using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.Controllers.Admin
{
    public class EmailValidationController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
