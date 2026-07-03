using GestionIntApi.DTO;
using GestionIntApi.Repositorios.Implementacion;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TiendaController : Controller
    {


        private readonly ITiendaService _TiendaServicios;
        private readonly ILogger<TiendaController> _logger;

        public TiendaController(ITiendaService TiendaServicios, ILogger<TiendaController> logger)
        {
            _TiendaServicios = TiendaServicios;
            _logger = logger;
        }



        [HttpGet]
        [Route("Lista")]
        public async Task<IActionResult> Lista()
        {
            var rsp = new Response<List<TiendaAdminDTO>>();
            try
            {
                rsp.status = true;
                rsp.value = await _TiendaServicios.GetTiendasAdmin();
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpGet]
        [Route("Lista/{Id}")]
        public async Task<IActionResult> TiendaPorID(int Id)
        {
            var rsp = new Response<TiendaAdminDTO>();
            try
            {
                rsp.status = true;
                rsp.value = await _TiendaServicios.GetTiendaAdminById(Id);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        /*  [HttpGet("{id}")]
          public async Task<ActionResult<TiendaDTO>> GetById(int id)
          {
              try
              {
                  var odontologo = await _TiendaServicios.GetTiendaById(id);
                  if (odontologo == null)
                      return NotFound();
                  return Ok(odontologo);
              }
              catch
              {
                  return StatusCode(500, "Error al obtener la tienda por ID");
              }
          }
        */


        [HttpPost]
        public async Task<IActionResult> CrearTienda([FromBody] TiendaAdminDTO dto)
        {
            var rsp = new Response<TiendaAdminDTO>();

            try
            {
                rsp.status = true;
                rsp.value = await _TiendaServicios.CrearTiendaAdmin(dto);
                rsp.msg = "Tienda creada correctamente";
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }

            return Ok(rsp);
        }




        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Eliminar(int id)
        {
            var rsp = new Response<bool>();

            try
            {
                rsp.status = true;
                rsp.value = await _TiendaServicios.EliminarTienda(id);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }

            return Ok(rsp);
        }

        [HttpPut]
        [Route("Editar")]
        public async Task<IActionResult> Editar([FromBody] TiendaAdminDTO tienda)
        {
            var rsp = new Response<bool>();
            try
            {
                rsp.status = true;
                rsp.value = await _TiendaServicios.EditarTienda(tienda);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }


        /*

        [HttpGet("tiendaApp/{clienteId}")]
        public async Task<ActionResult<List<TiendaMostrarAppDTO>>> GetByIdApp(int clienteId)
        {
            try
            {
                var tiendas = await _TiendaServicios.GetTiendasApp(clienteId);
                if (tiendas == null || !tiendas.Any())
                    return NotFound();

                return Ok(tiendas);
            }
            catch (Exception ex)
            {
                // Log detallado del error
                _logger.LogError(ex, "Error al obtener las tiendas del clienteId {ClienteId}", clienteId);

                // También se puede devolver el mensaje en desarrollo
                return StatusCode(500, $"Error al obtener las tiendas del clienteId {clienteId}: {ex.Message}");
            }
        }


        [HttpGet("tiendasApp")]

        [Authorize] // 🔒 Protegido con JWT
        public async Task<ActionResult<List<TiendaMostrarAppDTO>>> GetCreditosPendientesApp()
        {
            try
            {

                var clienteIdClaim = User.FindFirst("ClienteId")?.Value;
                if (string.IsNullOrEmpty(clienteIdClaim))
                    return Unauthorized("Token inválido o ClienteId no encontrado");

                int clienteId = int.Parse(clienteIdClaim);



                var tienda = await _TiendaServicios.GetTiendasCliente(clienteId);
                if (tienda == null)
                    return NotFound();
                return Ok(tienda);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex); // o usar ILogger
                return StatusCode(500, $"Error al obtener los créditos: {ex.Message}");

            }
        }


        [HttpPost]
        [Route("Guardar")]
        public async Task<IActionResult> Guardar([FromBody] TiendaDTO tienda)
        {
            var rsp = new Response<TiendaDTO>();

            try
            {
                // 1. Validar correo

                // 2. Registrar usuario directamente
                var nuevoCredito = await _TiendaServicios.GetTiendasCliente(tienda);

                rsp.status = true;
                rsp.msg = "Tienda registrada correctamente.";
                rsp.value = nuevoCredito;
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }

            return Ok(rsp);
        }

        [HttpPut]
        [Route("Editar")]
        public async Task<IActionResult> Editar([FromBody] TiendaDTO Detalle)
        {
            var rsp = new Response<bool>();
            try
            {
                rsp.status = true;
                rsp.value = await _TiendaServicios.UpdateTienda(Detalle);
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
                rsp.value = await _TiendaServicios.DeleteTienda(id);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }


        [HttpPut]
        [Route("ActualizarTiendaJWT")]
        [Authorize] // Requiere JWT válido
        public async Task<IActionResult> GuardarTinedaConJWT([FromBody] TiendaDTO tienda)
        {
            var rsp = new Response<TiendaDTO>();

            try
            {
                // 1️⃣ Obtener ClienteId desde el JWT
                var clienteIdClaim = User.Claims.FirstOrDefault(c => c.Type == "ClienteId");
                if (clienteIdClaim == null)
                {
                    rsp.status = false;
                    rsp.msg = "Cliente no identificado en el token.";
                    return Unauthorized(rsp);
                }

                tienda.ClienteId = int.Parse(clienteIdClaim.Value);

                // 2️⃣ Crear el crédito usando el servicio
                bool actualizado = await _TiendaServicios.UpdateTienda(tienda);
                if (actualizado) {
                    rsp.status = true;
                    rsp.msg = "Crédito actulizada correctamente.";
                    rsp.value = tienda;

                }
                else
                {
                    rsp.status = false;
                    rsp.msg = "No se pudo actualizar la tienda.";
                }

            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }

            return Ok(rsp);
        }


        [HttpPost]
        [Route("GuardarTiendaJWT")]
        [Authorize] // Requiere JWT válido
        public async Task<IActionResult> GuardarTinedaConJWT1([FromBody] TiendaDTO tienda)
        {
            var rsp = new Response<TiendaDTO>();

            try
            {
                // 1️⃣ Obtener ClienteId desde el JWT
                var clienteIdClaim = User.Claims.FirstOrDefault(c => c.Type == "ClienteId");
                if (clienteIdClaim == null)
                {
                    rsp.status = false;
                    rsp.msg = "Cliente no identificado en el token.";
                    return Unauthorized(rsp);
                }

                tienda.ClienteId = int.Parse(clienteIdClaim.Value);

                // 2️⃣ Crear el crédito usando el servicio
                var tiendaNueva = await _TiendaServicios.CreateTienda(tienda);
               
                    rsp.status = true;
                    rsp.msg = "Crédito actulizada correctamente.";
                    rsp.value = tiendaNueva;

                
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }

            return Ok(rsp);
        }

        */
    }


}
