using GestionIntApi.DTO;
using GestionIntApi.Repositorios.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GestionIntApi.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class UbicacionController : Controller
    {
        private readonly IUbicacionService _ubicacionService;



        public UbicacionController(IUbicacionService ubicacionService)
        {
            _ubicacionService = ubicacionService;
        }


        // =======================
        // ENDPOINTS PARA CLIENTES
        // =======================
        [HttpPost("Registrar")]
        [Authorize]
        public async Task<IActionResult> Registrar([FromBody] UbicacionDTO request)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(userIdClaim))
                    return Unauthorized(new { isSuccess = false, message = "Usuario no autenticado" });

                if (!int.TryParse(userIdClaim, out int usuarioId))
                    return BadRequest(new { isSuccess = false, message = "ID de usuario inválido" });

                var ubicacion = await _ubicacionService.Registrar(request.Latitud, request.Longitud, usuarioId);

                return Ok(new
                {
                    isSuccess = true,
                    message = "Ubicación registrada exitosamente",
                    data = ubicacion
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    isSuccess = false,
                    message = $"Error al registrar ubicación: {ex.Message}"
                });
            }
        }

        [HttpGet("MisUbicaciones")]
        [Authorize]
        public async Task<IActionResult> MisUbicaciones()
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(userIdClaim))
                    return Unauthorized(new { isSuccess = false, message = "Usuario no autenticado" });

                if (!int.TryParse(userIdClaim, out int usuarioId))
                    return BadRequest(new { isSuccess = false, message = "ID de usuario inválido" });

                var ubicaciones = await _ubicacionService.ObtenerPorUsuario(usuarioId);

                return Ok(new
                {
                    isSuccess = true,
                    data = ubicaciones
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    isSuccess = false,
                    message = $"Error al obtener ubicaciones: {ex.Message}"
                });
            }
        }

        [HttpGet("UltimaUbicacion")]
        [Authorize]
        public async Task<IActionResult> UltimaUbicacion()
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(userIdClaim))
                    return Unauthorized(new { isSuccess = false, message = "Usuario no autenticado" });

                if (!int.TryParse(userIdClaim, out int usuarioId))
                    return BadRequest(new { isSuccess = false, message = "ID de usuario inválido" });

                var ubicacion = await _ubicacionService.ObtenerUltima(usuarioId);

                if (ubicacion == null)
                    return NotFound(new { isSuccess = false, message = "No se encontraron ubicaciones" });

                return Ok(new
                {
                    isSuccess = true,
                    data = ubicacion
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    isSuccess = false,
                    message = $"Error al obtener última ubicación: {ex.Message}"
                });
            }
        }

        // =======================
        // ENDPOINTS PARA ADMIN
        // =======================

   

        // Obtener ubicaciones de un usuario específico (opcional)
        [HttpGet("DashboardUbicaciones/{usuarioId}")]
        public async Task<IActionResult> DashboardUbicaciones(int usuarioId)
        {
            try
            {
                var ubicaciones = await _ubicacionService.ObtenerUltima(usuarioId);
                return Ok(new { isSuccess = true, data = ubicaciones });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { isSuccess = false, message = $"Error: {ex.Message}" });
            }
        }

        [HttpGet("ListarUltimasUbicaciones")]
        public async Task<IActionResult> ListarUltimasUbicaciones()
        {
            try
            {
                var lista = await _ubicacionService.ListarUltimasUbicaciones();
                return Ok(new { isSuccess = true, data = lista });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { isSuccess = false, message = ex.Message });
            }
        }
    }
}
