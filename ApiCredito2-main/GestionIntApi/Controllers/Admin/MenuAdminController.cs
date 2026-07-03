using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Repositorios.Interfaces.Admin;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.Controllers.Admin
{
    [Route("api/[controller]")]
    [ApiController]
    public class MenuAdminController : Controller
    {
        private readonly IMenuAdminRepository _menuServicio;
        public MenuAdminController(IMenuAdminRepository menuServicio)
        {
            _menuServicio = menuServicio;
        }

        [HttpGet]
        [Route("Lista")]
        public async Task<IActionResult> Lista(int idUsuario)
        {
            var rsp = new Response<List<MenuAdminDto>>();
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
