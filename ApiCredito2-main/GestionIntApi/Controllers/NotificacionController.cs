using GestionIntApi.DTO;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Implementacion;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace GestionIntApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NotificacionController : Controller
    {

        private readonly INotificacionServicio _NotificacionServicios;
        private readonly ICodigoVerificacionService _codigoService;
        private readonly IEmailService _emailService;
        private readonly IRegistroTemporalService _registroTemporal;
        public NotificacionController(INotificacionServicio NotificacionServicios)
        {
            _NotificacionServicios = NotificacionServicios;

        }

        [HttpPost("Generar")]
        public async Task<IActionResult> GenerarNotificaciones()
        {
            try
            {
                await _NotificacionServicios.GenerarNotificaciones();
                return Ok(new { mensaje = "Notificaciones generadas correctamente" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }


        // Endpoint para obtener todas las notificaciones
        [HttpGet("GetAll")]
        public async Task<ActionResult<List<NotificacionDTO>>> GetNotificaciones()
        {
            try
            {
                var notificaciones = await _NotificacionServicios.GetNotificaciones();
                return Ok(notificaciones);
            }
            catch (Exception ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        // Opcional: obtener notificaciones de un cliente específico
        [HttpGet("{id}")]
        public async Task<ActionResult<List<NotificacionDTO>>> GetNotificacionesPorCliente(int clienteId)
        {
            try
            {
                var allNotificaciones = await _NotificacionServicios.GetNotificaciones();
                var notificacionesCliente = allNotificaciones.FindAll(n => n.ClienteId == clienteId);
                return Ok(notificacionesCliente);
            }
            catch (Exception ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }



        [HttpGet("pendientesNotApp")]
        [Authorize] // 🔒 Protegido con JWT
        public async Task<ActionResult<List<NotificacionDTO>>> GetNotificacionesClienteApp()
        {
            try
            {
                // Obtener ClienteId del token
                var clienteIdClaim = User.FindFirst("ClienteId")?.Value;
                if (string.IsNullOrEmpty(clienteIdClaim))
                    return Unauthorized("Token inválido o ClienteId no encontrado");

                int clienteId = int.Parse(clienteIdClaim);

                // Obtener todas las notificaciones
                var allNotificaciones = await _NotificacionServicios.GetNotificaciones();

                // Filtrar solo las del cliente logeado
                var notificacionesCliente = allNotificaciones.FindAll(n => n.ClienteId == clienteId);

                return Ok(notificacionesCliente);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex); // o usar ILogger
                return StatusCode(500, $"Error al obtener las notificaciones: {ex.Message}");
            }
        }


        [HttpPost("marcar-leida/{id}")]
        [Authorize] // 🔒 Protegido con JWT
        public async Task<IActionResult> MarcarLeida(int id)
        {
            // Obtener ClienteId del token
            var clienteIdClaim = User.FindFirst("ClienteId")?.Value;
            if (string.IsNullOrEmpty(clienteIdClaim))
                return Unauthorized("Token inválido o ClienteId no encontrado");

            int clienteId = int.Parse(clienteIdClaim);

            await _NotificacionServicios.MarcarComoLeida(clienteId,id);
            return NoContent();
        }


        [HttpPost("marcar-leidasinJwt/{id}")]
        public async Task<IActionResult> MarcarLeida1(int id)
        {
            var result = await _NotificacionServicios.MarcarComoLeida1(id);
            if (!result)
                return NotFound(new { mensaje = "Notificación no encontrada" });

            return NoContent();
        }


    }
}
