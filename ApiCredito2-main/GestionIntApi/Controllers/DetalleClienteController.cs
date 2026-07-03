using GestionIntApi.DTO;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DetalleClienteController : Controller
    {
        private readonly IDetalleClienteService _detalleClienteServicios;
        private readonly ICodigoVerificacionService _codigoService;
        private readonly IEmailService _emailService;
        private readonly IRegistroTemporalService _registroTemporal;


        public DetalleClienteController(IDetalleClienteService DetalleClienteServicios)
        {
            _detalleClienteServicios = DetalleClienteServicios;

        }



        [HttpGet]
        [Route("Lista")]
        public async Task<IActionResult> Lista()
        {
            var rsp = new Response<List<DetalleClienteDTO>>();
            try
            {
                rsp.status = true;
                rsp.value = await _detalleClienteServicios.GetAllDetalles();
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<DetalleClienteDTO>> GetById(int id)
        {
            try
            {
                var odontologo = await _detalleClienteServicios.GetDetalleById(id);
                if (odontologo == null)
                    return NotFound();
                return Ok(odontologo);
            }
            catch
            {
                return StatusCode(500, "Error al obtener el Odontólogo por ID");
            }
        }

        [HttpPost]
        [Route("Guardar")]
        public async Task<IActionResult> Guardar([FromBody] DetalleClienteDTO credito)
        {
            var rsp = new Response<DetalleClienteDTO>();

            try
            {
                // 1. Validar correo

                // 2. Registrar usuario directamente
                var nuevoCredito = await _detalleClienteServicios.CreateDetalle(credito);

                rsp.status = true;
                rsp.msg = "Usuario registrado correctamente.";
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
        public async Task<IActionResult> Editar([FromBody] DetalleClienteDTO Detalle)
        {
            var rsp = new Response<bool>();
            try
            {
                rsp.status = true;
                rsp.value = await _detalleClienteServicios.UpdateDetalle(Detalle);
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
                rsp.value = await _detalleClienteServicios.DeleteDetalle(id);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpPut]
        [Route("EditarFotosJWT")]
        [Authorize]
        public async Task<IActionResult> EditarFJWT([FromBody] DetalleClienteDTO detalle)
        {
            var rsp = new Response<bool>();
            try
            {
                // Obtener ClienteId desde JWT
                var clienteIdClaim = User.Claims.FirstOrDefault(c => c.Type == "ClienteId");
                if (clienteIdClaim == null)
                {
                    rsp.status = false;
                    rsp.msg = "Cliente no identificado en el token.";
                    return Unauthorized(rsp);
                }

                int clienteId = int.Parse(clienteIdClaim.Value);

                // Traer el detalle actual asociado al cliente
                var detalleExistente = await _detalleClienteServicios.GetDetalleByClienteId(clienteId);
                if (detalleExistente == null)
                {
                    rsp.status = false;
                    rsp.msg = "Detalle del cliente no encontrado.";
                    return NotFound(rsp);
                }

                // Asignar el Id correcto al DTO para el Update
                detalle.Id = detalleExistente.Id;

                rsp.status = true;
                rsp.value = await _detalleClienteServicios.UpdateDetalle(detalle);
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
