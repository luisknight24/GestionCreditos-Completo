using AutoMapper;
using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Implementacion;
using GestionIntApi.Repositorios.Implementacion;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Utilidades;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;



namespace GestionIntApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsuarioController : ControllerBase
    {
        private readonly IUsuarioRepository _UsuarioServicios;
        private readonly ICodigoVerificacionService _codigoService;
        private readonly IEmailService _emailService;
        private readonly IRegistroTemporalService _registroTemporal;

        public UsuarioController(IUsuarioRepository usuarioServicios, ICodigoVerificacionService codigoService, IEmailService emailService, IRegistroTemporalService registroTemporal)
        {
            _UsuarioServicios = usuarioServicios;
            _codigoService = codigoService;
            _emailService = emailService;
            _registroTemporal = registroTemporal;
        }

        [HttpPost]
        [Route("IniciarSesion")]
        public async Task<IActionResult> IniciarSesion([FromBody] LoginDTO login)
        {
            var rsp = new Response<SesionDTO>();
            try
            {
                rsp.status = true;
                rsp.value = await _UsuarioServicios.ValidarCredenciales(login.Correo, login.Clave);

            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpGet]
        [Route("Lista")]
        public async Task<IActionResult> Lista()
        {
            var rsp = new Response<List<UsuarioDTO>>();
            try
            {
                rsp.status = true;
                rsp.value = await _UsuarioServicios.listaUsuarios();
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UsuarioDTO>> GetById(int id)
        {
            try
            {
                var odontologo = await _UsuarioServicios.obtenerPorIdUsuario(id);
                if (odontologo == null)
                    return NotFound();
                return Ok(odontologo);
            }
            catch
            {
                return StatusCode(500, "Error al obtener el Odontólogo por ID");
            }
        }



        [HttpGet("ObtenerCompleto/{id}")]
        public async Task<ActionResult<UsuarioCompletoDto>> GetByIdCompleto(int id)
        {
            try
            {
                var odontologo = await _UsuarioServicios.ObtenerRegistroIntegralPorId(id);
                if (odontologo == null)
                    return NotFound();
                return Ok(odontologo);
            }
            catch
            {
                return StatusCode(500, "Error al obtener el Odontólogo por ID");
            }
        }


        [HttpGet("ObtenerCompletoSinId")]
        public async Task<ActionResult<UsuarioCompletoDto>> GetByIdCompletoSinId()
        {
            try
            {
                var odontologo = await _UsuarioServicios.ObtenerTodosIntegral();
                if (odontologo == null)
                    return NotFound();
                return Ok(odontologo);
            }
            catch
            {
                return StatusCode(500, "Error al obtener el registro completo");
            }
        }


        [HttpPost]
                [Route("Guardar11")]
                public async Task<IActionResult> Guardar11([FromBody] UsuarioDTO usuario)
                {
                    var rsp = new Response<UsuarioDTO>();
                    try
                    {
                        var existe = await _UsuarioServicios.ExisteCorreo(usuario.Correo);
                        if (existe)
                        {
                            rsp.status = false;
                            rsp.msg = "El correo ya está registrado.";
                            return BadRequest(rsp);
                        }

                        //  var newUser = await _UsuarioServicios.crearUsuario(usuario);

                        // 2. Generar Código
                        var codigo = new Random().Next(100000, 999999).ToString();

                        var datos = new RegistroTemporal
                        {
                            Usuario = usuario,
                            Codigo = codigo
                        };

                        // 3. Guardar el código temporal asociado al correo del usuario
                        //  _codigoService.GuardarCodigo(usuario.Correo, codigo);
                        _registroTemporal.GuardarRegistro(usuario.Correo, datos);
                        // 4. Enviar correo
                        await _emailService.SendEmailAsync(
                            usuario.Correo,
                            "Código de verificación",
                            $"<h3>Tu código es: <b>{codigo}</b></h3>"
                        );
                        rsp.status = true;
                        rsp.msg = "Código enviado. Verifique su correo.";
                       // rsp.value = await _UsuarioServicios.crearUsuario(usuario);
                    }
                    catch (Exception ex)
                    {
                        rsp.status = false;
                        rsp.msg = ex.Message;
                    }
                    return Ok(rsp);
                }


        [HttpPost]
        [Route("Guardar")]
        public async Task<IActionResult> Guardar1([FromBody] UsuarioDTO usuario)
        {
            var rsp = new Response<UsuarioDTO>();
            try
            {
                // 1. Validar si el correo ya existe en la base de datos
                var existe = await _UsuarioServicios.ExisteCorreo(usuario.Correo);
                if (existe)
                {
                    rsp.status = false;
                    rsp.msg = "El correo ya está registrado.";
                    return BadRequest(rsp);
                }

                // 2. Generar el código de verificación aleatorio
                var codigo = new Random().Next(100000, 999999).ToString();

                // 3. INTENTAR ENVIAR EL CORREO PRIMERO
                // Si el servidor de correos falla, lanzará una excepción y saltará al 'catch'
                // evitando que los datos se guarden en el registro temporal.
                await _emailService.SendEmailAsync(
                    usuario.Correo,
                    "Código de verificación",
                    $"<h3>Tu código es: <b>{codigo}</b></h3>"
                );

                // 4. GUARDAR EN REGISTRO TEMPORAL (Solo si el correo fue exitoso)
                var datos = new RegistroTemporal
                {
                    Usuario = usuario,
                    Codigo = codigo
                };

                _registroTemporal.GuardarRegistro(usuario.Correo, datos);

                // 5. Respuesta de éxito
                rsp.status = true;
                rsp.msg = "Código enviado. Verifique su correo.";
            }
            catch (Exception ex)
            {
                // Si algo falló (especialmente el correo), llegamos aquí 
                // y no se habrá guardado nada en _registroTemporal.
                rsp.status = false;
                rsp.msg = "No se pudo procesar la solicitud: " + ex.Message;
                // Opcional: Loggear el error real para soporte técnico
            }

            return Ok(rsp);
        }

        [HttpPost]
        [Route("Guardar1")]
        public async Task<IActionResult> Guardar([FromBody] UsuarioDTO usuario)
        {
            var rsp = new Response<UsuarioDTO>();
            // ============= LOG DEL CLIENTE ===================
            if (usuario.Cliente != null)
            {
                Console.WriteLine("=== CLIENTE RECIBIDO ===");
                Console.WriteLine($"ClienteId: {usuario.Cliente.Id}");
                Console.WriteLine($"DetalleClienteID: {usuario.Cliente.DetalleClienteID}");
                Console.WriteLine($"# Tiendas: {usuario.Cliente.TiendaApps?.Count}");
                Console.WriteLine($"# Creditos: {usuario.Cliente.Creditos?.Count}");
            }
            else
            {
                Console.WriteLine("=== CLIENTE ES NULL ===");
            }

            // ============= LOG DE CADA CRÉDITO ===============
            if (usuario.Cliente?.Creditos != null)
            {
                int i = 0;
                foreach (var c in usuario.Cliente.Creditos)
                {
                    Console.WriteLine($"--- CREDITO {i} ---");
                    Console.WriteLine(System.Text.Json.JsonSerializer.Serialize(c));
                    i++;
                }
            }

            try
            {
                // 1. Validar correo
                var existe = await _UsuarioServicios.ExisteCorreo(usuario.Correo);
                if (existe)
                {
                    rsp.status = false;
                    rsp.msg = "El correo ya está registrado.";
                    return BadRequest(rsp);
                }

                // 2. Registrar usuario directamente
                var nuevoUsuario = await _UsuarioServicios.crearUsuario(usuario);

                rsp.status = true;
                rsp.msg = "Usuario registrado correctamente.";
                rsp.value = nuevoUsuario;
            }
            catch (Exception ex)
            {
                Console.WriteLine("=== ERROR EN CONTROLADOR ===");
                Console.WriteLine(ex.ToString());

                rsp.status = false;
                rsp.msg = ex.Message;
            }

            return Ok(rsp);
        }

        
        [HttpPut]
        [Route("Editar")]
        public async Task<IActionResult> Editar([FromBody] UsuarioDTO Usuario)
        {
            var rsp = new Response<bool>();
            try
            {
                rsp.status = true;
                rsp.value = await _UsuarioServicios.editarUsuario(Usuario);
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }


        [HttpPut]
        [Route("EditarCompleto")]
        public async Task<IActionResult> EditarCompleto([FromBody] UsuarioCompletoDto Usuario)
        {
            var rsp = new Response<bool>();
            try
            {
                rsp.status = true;
                rsp.value = await _UsuarioServicios.EditarRegistroIntegral(Usuario);
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
                rsp.value = await _UsuarioServicios.eliminarUsuario(id);
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
