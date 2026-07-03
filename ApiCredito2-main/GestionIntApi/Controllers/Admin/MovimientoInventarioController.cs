using GestionIntApi.DTO.Admin;
using GestionIntApi.Models.Admin;
using GestionIntApi.Repositorios.Interfaces.Admin;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.Controllers.Admin
{
    [Route("api/[controller]")]
    [ApiController]
    public class MovimientoInventarioController : ControllerBase
    {
        private readonly IMovimientoInventarioService _movimientoService;

        public MovimientoInventarioController(IMovimientoInventarioService movimientoService)
        {
            _movimientoService = movimientoService;
        }

        // ==================== TRASLADOS ====================

        // 1. Usamos el DTO para el traslado individual
        [HttpPost("RegistrarTraslado")]
        public async Task<IActionResult> RegistrarTraslado([FromBody] TrasladoProductoDTO request)
        {
            var rsp = new Response<MovimientoInventario>();
            try
            {
                rsp.value = await _movimientoService.RegistrarTraslado(
                    request.ProductoId,
                    request.TiendaOrigenId,
                    request.TiendaDestinoId,
                    request.Observacion ?? "",
                    "Sistema"
                );
                rsp.status = true;
                rsp.msg = "Traslado registrado exitosamente.";
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
            // 2. Creamos otro DTO similar para Múltiples o usamos una lista

        }
            // ==================== ENTRADAS ====================

            [HttpPost("RegistrarEntrada")]
            public async Task<IActionResult> RegistrarEntrada([FromBody] EntradaRequestDTO request)
            {
                var rsp = new Response<MovimientoInventario>();
                try
                {
                    // Ya no necesitas castear con (int) porque el DTO ya define el tipo
                    rsp.value = await _movimientoService.RegistrarEntrada(
                        request.ProductoId,
                        request.TiendaDestinoId,
                        request.Observacion ?? "",
                        "Sistema"
                    );
                    rsp.status = true;
                    rsp.msg = "Entrada registrada correctamente.";
                }
                catch (Exception ex)
                {
                    rsp.status = false;
                    rsp.msg = ex.Message;
                }
                return Ok(rsp);
            }

            // ==================== CONSULTAS DE HISTORIAL ====================

            [HttpGet("Historial")]
            public async Task<IActionResult> ObtenerHistorial(
            [FromQuery] int? productoId = null,
            [FromQuery] int? tiendaId = null,
            [FromQuery] DateTime? fechaInicio = null,
            [FromQuery] DateTime? fechaFin = null,
            [FromQuery] string tipoMovimiento = null)
            {
                var rsp = new Response<List<MovimientoHistorialDTO>>();
                try
                {
                    rsp.value = await _movimientoService.ObtenerHistorial(
                        productoId,
                        tiendaId,
                        fechaInicio,
                        fechaFin,
                        tipoMovimiento
                    );
                    rsp.status = true;
                    rsp.msg = "Historial obtenido.";
                }
                catch (Exception ex)
                {
                    rsp.status = false;
                    rsp.msg = ex.Message;
                }
                return Ok(rsp);
            }

            [HttpGet("HistorialPorIMEI/{imei}")]
            public async Task<IActionResult> ObtenerHistorialPorIMEI(string imei)
            {
                var rsp = new Response<List<MovimientoHistorialDTO>>();
                try
                {
                    rsp.value = await _movimientoService.ObtenerHistorialPorIMEI(imei);
                    rsp.status = true;
                    rsp.msg = "Historial por IMEI obtenido.";
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