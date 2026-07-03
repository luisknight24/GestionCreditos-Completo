using GestionIntApi.DTO;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]

    public class MenuController : Controller
    {
            private readonly IMenuRepository _menuServicio;
            public MenuController(IMenuRepository menuServicio)
            {
                _menuServicio = menuServicio;
            }

            [HttpGet]
            [Route("Lista")]
            public async Task<IActionResult> Lista(int idUsuario)
            {
                var rsp = new Response<List<MenuDTO>>();
                try
                {
                    rsp.status = true;
                    rsp.value = await _menuServicio.listaMenus(idUsuario);
                }
                catch (Exception ex)
                {
                    rsp.status = false;
                    rsp.msg = ex.Message;
                }
                return Ok(rsp);
            }
        }
}
