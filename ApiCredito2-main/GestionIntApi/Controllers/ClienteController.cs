using GestionIntApi.DTO;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Implementacion;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GestionIntApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ClienteController : Controller
    {

        private readonly IClienteService _ClienteServicios;
        private readonly IReporteService _ReporteServicios;
        private readonly ICodigoVerificacionService _codigoService;
        private readonly IEmailService _emailService;
        private readonly IRegistroTemporalService _registroTemporal;


        public ClienteController(IClienteService ClienteServicios, IReporteService reporteService)
        {
            _ClienteServicios = ClienteServicios;
            _ReporteServicios = reporteService;

        }

        [HttpPost("CrearDesdeAdmin")]
        public async Task<IActionResult> CrearDesdeAdmin([FromBody] ClienteDTO modelo)
        {
            var respuesta = await _ClienteServicios.CrearClienteDesdeAdmin(modelo);
            return Ok(respuesta);
        }

        [HttpGet]
        [Route("Lista")]
        public async Task<IActionResult> Lista()
        {
            var rsp = new Response<List<ClienteDTO>>();
            try
            {
                rsp.status = true;
                rsp.value = await _ClienteServicios.GetClientes();
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpGet]
        [Route("Reporte")]
        public async Task<IActionResult> Reporte(string? fechaInicio, string? fechaFin)
        {
            var rsp = new Response<List<ReporteDTO>>();
            try
            {
                rsp.status = true;
                rsp.value = await _ClienteServicios.Reporte(fechaInicio, fechaFin);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }


        [HttpDelete]
        [Route("Eliminar/{id:int}")]
        public async Task<IActionResult> Eliminar(int id)
        {
            var rsp = new Response<bool>();
            try
            {
                rsp.status = true;
                rsp.value = await _ClienteServicios.DeleteCliente(id);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }





        [HttpGet("clienteApp/{usuarioId}")]
        public async Task<ActionResult<ClienteMostrarAppDTO>> GetByIdCreditoActivoApp1(int usuarioId)
        {
            try
            {




                var credito = await _ClienteServicios.GetClienteParaApp(usuarioId);
                if (credito == null)
                    return NotFound();
                return Ok(credito);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex); // o usar ILogger
                return StatusCode(500, $"Error al obtener el cliente: {ex.Message}");

            }
        }





        [HttpGet("ClienteApp")]

        [Authorize] // 🔒 Protegido con JWT
        public async Task<ActionResult<ClienteMostrarAppDTO>> GetByIdCreditoActivoApp()
        {
            try
            {
                var usuarioIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(usuarioIdClaim))
                    return Unauthorized("Token inválido o usuarioId no encontrado");

                int usuarioId = int.Parse(usuarioIdClaim);

                var cliente = await _ClienteServicios.GetClienteParaApp(usuarioId);

                if (cliente == null)
                    return NotFound();

                return Ok(cliente);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error al obtener el cliente: {ex.Message}");
            }
        }


        [HttpGet("reporte-excel")]
        public async Task<IActionResult> ExportarExcel(
    string? fechaInicio,
    string? fechaFin
)
        {
            var archivo = await _ReporteServicios
                .ExportarReporteExcel(fechaInicio, fechaFin);

            return File(
                archivo,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                "reporte_creditos.xlsx"
            );
        }




    }
}
