using GestionIntApi.DTO;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Implementacion;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;

namespace GestionIntApi.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class CreditoController : Controller
    {

        private readonly ICreditoService _CreditoServicios;
        private readonly ICodigoVerificacionService _codigoService;
        private readonly IEmailService _emailService;
        private readonly IRegistroTemporalService _registroTemporal;


        public CreditoController( ICreditoService CreditoServicios)
        {
            _CreditoServicios = CreditoServicios;

        }



        [HttpGet]
        [Route("Lista")]
        public async Task<IActionResult> Lista()
        {
            var rsp = new Response<List<CreditoDTO>>();
            try
            {
                rsp.status = true;
                rsp.value = await _CreditoServicios.GetAllTiendas();
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<CreditoDTO>> GetById(int id)
        {
            try
            {
                Console.WriteLine("🔵 Endpoint pendientesApp llamado");
                var odontologo = await _CreditoServicios.GetTiendaById(id);
                if (odontologo == null)
                    return NotFound();
                return Ok(odontologo);
            }
            catch
            {
                return StatusCode(500, "Error al obtener el Odontólogo por ID");
            }
        }


        [HttpGet("pendientes/{Id}")]
        public async Task<ActionResult<CreditoDTO>> GetByIdCreditoActivo(int id)
        {
            try
            {
                Console.WriteLine("🔵 Endpoint pendientesApp llamado");
                var credito = await _CreditoServicios.GetCreditosPendientesPorCliente(id);
                if (credito == null)
                    return NotFound();
                return Ok(credito);
            }
            catch
            {
                return StatusCode(500, "Error al obtener el credito por ID");
            }
        }
        [HttpGet("pendientes1/{clienteId}")]
        public async Task<ActionResult<CreditoDTO>> GetByIdCreditoActivo1(int clienteId)
        {
            try
            {
                Console.WriteLine("🔵 Endpoint pendientesApp llamado");
                var credito = await _CreditoServicios.GetCreditosPendientesPorCliente1(clienteId);
                if (credito == null)
                    return NotFound();
                return Ok(credito);
            }
            catch
            {
                return StatusCode(500, "Error al obtener el credito por ID");
            }
        }


        [HttpGet("pendientesAppConId")]

        public async Task<ActionResult<List<CreditoMostrarDTO>>> GetByIdCreditoActivoApp(int clienteId)
        {
            try
            {



                var credito = await _CreditoServicios.GetCreditosClienteApp(clienteId);
                if (credito == null)
                    return NotFound();
                return Ok(credito);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex); // o usar ILogger
                return StatusCode(500, $"Error al obtener los créditos: {ex.Message}");

            }
        }
        [HttpGet("pendientesApp1")]

        [Authorize] // 🔒 Protegido con JWT
        public async Task<ActionResult<List<CreditoMostrarDTO>>> GetByIdCreditoActivoApp1()
        {
            try
            {

                var clienteIdClaim = User.FindFirst("ClienteId")?.Value;
                if (string.IsNullOrEmpty(clienteIdClaim))
                    return Unauthorized("Token inválido o ClienteId no encontrado");

                int clienteId = int.Parse(clienteIdClaim);



                var credito = await _CreditoServicios.GetCreditosClienteApp(clienteId);
                if (credito == null)
                    return NotFound();
                return Ok(credito);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex); // o usar ILogger
                return StatusCode(500, $"Error al obtener los créditos: {ex.Message}");

            }
        }


        [HttpGet("pendientesApp")]
        [Authorize]
        public async Task<ActionResult<List<CreditoMostrarDTO>>> GetByIdCreditoActivoApp()
        {
            try
            {
                Console.WriteLine("🔵 Endpoint pendientesApp llamado");

                var clienteIdClaim = User.FindFirst("ClienteId")?.Value;
                Console.WriteLine($"🆔 ClienteId claim: {clienteIdClaim}");

                if (string.IsNullOrEmpty(clienteIdClaim))
                {
                    Console.WriteLine("❌ ClienteId no encontrado en el token");
                    return Unauthorized("Token inválido o ClienteId no encontrado");
                }

                int clienteId = int.Parse(clienteIdClaim);
                Console.WriteLine($"✅ ClienteId parseado: {clienteId}");

                var creditos = await _CreditoServicios.GetCreditosClienteApp(clienteId);

                if (creditos == null)
                {
                    Console.WriteLine("⚠️ No se encontraron créditos");
                    return NotFound();
                }

                Console.WriteLine($"📦 Créditos encontrados: {creditos.Count}");

                // 🔥 LOG CLAVE: ver qué se está enviando
                foreach (var c in creditos)
                {
                    Console.WriteLine("----- CRÉDITO -----");
                    Console.WriteLine($"Id: {c.Id}");
                    Console.WriteLine($"MontoTotal: {c.MontoTotal}");
                    Console.WriteLine($"TiendaId: {c.TiendaAppId}");
                    Console.WriteLine($"Estado: {c.Estado}");
                }

                return Ok(creditos);
            }
            catch (Exception ex)
            {
                Console.WriteLine("❌ ERROR en pendientesApp");
                Console.WriteLine(ex);

                return StatusCode(500, $"Error al obtener los créditos: {ex.Message}");
            }
        }



        [HttpPost]
        [Route("Guardar")]
        public async Task<IActionResult> Guardar([FromBody] CreditoDTO credito)
        {
            var rsp = new Response<CreditoDTO>();

            try
            {
                // 1. Validar correo

                // 2. Registrar usuario directamente
                var nuevoCredito = await _CreditoServicios.CreateCredito(credito);

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



        [HttpPost]
        [Route("RegistrarPago")]
        public async Task<IActionResult> GuardarPago([FromBody] PagoCreditoDTO credito)
        {
            var rsp = new Response<PagarCreditoDTO>();

            try
            {
                // 1. Validar correo

                // 2. Registrar usuario directamente
                var nuevoCredito = await _CreditoServicios.RegistrarPagoAsync(credito);

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
        public async Task<IActionResult> Editar([FromBody] CreditoDTO Credito)
        {
            var rsp = new Response<bool>();
            try
            {
                rsp.status = true;
                rsp.value = await _CreditoServicios.UpdateCredito(Credito);
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
                rsp.value = await _CreditoServicios.DeleteCredito(id);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpPost]
        [Route("GuardarJWT")]
        [Authorize] // Requiere JWT válido
        public async Task<IActionResult> GuardarConJWT([FromBody] CreditoDTO credito)
        {
            var rsp = new Response<CreditoDTO>();

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

                credito.ClienteId = int.Parse(clienteIdClaim.Value);

                // 2️⃣ Crear el crédito usando el servicio
                var nuevoCredito = await _CreditoServicios.CreateCredito(credito);

                rsp.status = true;
                rsp.msg = "Crédito registrado correctamente.";
                rsp.value = nuevoCredito;
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }

            return Ok(rsp);
        }

        [HttpGet("calendario/{creditoId}")]
        [Authorize]
        public async Task<IActionResult> GetCalendario(int creditoId)
        {
            // 1️⃣ Extraemos el ClienteId directamente del JWT (Token)
            var clienteIdClaim = User.FindFirst("ClienteId")?.Value;
            if (string.IsNullOrEmpty(clienteIdClaim))
                return Unauthorized("Token inválido o ClienteId no encontrado");

            int clienteId = int.Parse(clienteIdClaim);

            try
            {
                // 2️⃣ Llamamos al servicio con los DOS parámetros.
                // Esto busca: El crédito específico Y que pertenezca a este cliente.
                var data = await _CreditoServicios.GetCalendarioPagos(creditoId, clienteId);

                return Ok(data);
            }
            catch (Exception ex)
            {
                // Si el crédito no existe o no es de ese cliente, el servicio lanzará la excepción
                return NotFound(new { msg = ex.Message });
            }
        }

        [HttpGet("calendariosinJWT/{creditoId}")]
     
        public async Task<IActionResult> GetCalendario(int creditoId, int clienteId)
        {
            var data = await _CreditoServicios.GetCalendarioPagos(creditoId, clienteId);
            return Ok(data);
        }


        [HttpGet("historial-pagos/{creditoId}")]
        public async Task<IActionResult> GetHistorialPagos(int creditoId)
        {
            try
            {
                var historial = await _CreditoServicios.ListarPagosPorCredito(creditoId);
                return Ok(new { status = true, value = historial });
            }
            catch (Exception ex)
            {
                return BadRequest(new { status = false, msg = ex.Message });
            }
        }

    }
}
