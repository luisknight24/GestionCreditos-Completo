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
    public class RolAdminController : Controller
    {
        private readonly IRolAdminRepository _rolServicios;
        public RolAdminController(IRolAdminRepository rolServicios)
        {
            _rolServicios = rolServicios;
        }

        [HttpGet]
        [Route("Lista")]
        public async Task<IActionResult> Lista()
        {
            var rsp = new Response<List<RolAdminDto>>();
            try
            {
                rsp.status = true;
                rsp.value = await _rolServicios.listaRoles();
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
