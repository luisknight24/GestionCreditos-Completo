using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Models.Admin;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Repositorios.Interfaces.Admin;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Mvc;
using SendGrid;

namespace GestionIntApi.Controllers.Admin
{

    [Route("api/[controller]")]
    [ApiController]
    public class UsuarioAdminController : Controller
    {
        private readonly IUsuarioAdminRepository _UsuarioAdminServicios;
        private readonly ICodigoVerificacionService _codigoService;
        private readonly IEmailService _emailService;
        private readonly IUsuarioRepository _UsuarioServicios;
        private readonly IRegistroTemporalAdminService _registroTemporal;
        public UsuarioAdminController(IRegistroTemporalAdminService registroTemporal, IUsuarioRepository UsuarioServicios,IUsuarioAdminRepository usuarioServicios, ICodigoVerificacionService codigoService, IEmailService emailService)
        {
            _UsuarioAdminServicios = usuarioServicios;
            _codigoService = codigoService;
            _emailService = emailService;

            _UsuarioServicios = UsuarioServicios;


            _registroTemporal = registroTemporal;

        }

        [HttpPost]
        [Route("IniciarSesion")]
        public async Task<IActionResult> IniciarSesion([FromBody] LoginAdminDto login)
        {
            var rsp = new Response<SesionDTOAdmin>();
            try
            {
                rsp.status = true;
                rsp.value = await _UsuarioAdminServicios.ValidarCredenciales(login.Correo, login.Clave);

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
        public async Task<IActionResult> GuardarAdmin([FromBody] UsuarioAdminDTO usuarioAdmin)
        {
            var rsp = new Response<UsuarioAdminDTO>();
            try
            {
                var existe = await _UsuarioAdminServicios.ExisteCorreoAdmin(usuarioAdmin.Correo);
                if (existe)
                {
                    rsp.status = false;
                    rsp.msg = "El correo ya está registrado.";
                    return BadRequest(rsp);
                }

                //  var newUser = await _UsuarioServicios.crearUsuario(usuario);

                // 2. Generar Código
                var codigo = new Random().Next(100000, 999999).ToString();

                var datos = new RegistroTemporalAdmin
                {
                    UsuarioAdmin = usuarioAdmin,
                    Codigo = codigo
                };

                // 3. Guardar el código temporal asociado al correo del usuario
                //  _codigoService.GuardarCodigo(usuario.Correo, codigo);
                _registroTemporal.GuardarRegistro(usuarioAdmin.Correo, datos);
                // 4. Enviar correo
                await _emailService.SendEmailAsync(
                    usuarioAdmin.Correo,
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
        [Route("GuardarASinVer")]
        public async Task<IActionResult> GuardarAdminSinVerif([FromBody] UsuarioAdminDTO usuarioAdmin)
        {
            var rsp = new Response<UsuarioAdminDTO>();
            try
            {
                // 1. Verificar si el correo ya existe
                var existe = await _UsuarioAdminServicios.ExisteCorreoAdmin(usuarioAdmin.Correo);
                if (existe)
                {
                    rsp.status = false;
                    rsp.msg = "El correo ya está registrado.";
                    return BadRequest(rsp);
                }

                // 2. Registrar directamente en la base de datos
                // Usamos el servicio de creación de usuario directamente
                var usuarioCreado = await _UsuarioAdminServicios.crearUsuario(usuarioAdmin);

                if (usuarioCreado != null)
                {
                    rsp.status = true;
                    rsp.msg = "Usuario registrado exitosamente.";
                    rsp.value = usuarioCreado;
                }
                else
                {
                    rsp.status = false;
                    rsp.msg = "No se pudo crear el usuario.";
                    return BadRequest(rsp);
                }
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
                return StatusCode(500, rsp);
            }
            return Ok(rsp);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UsuarioAdminDTO>> GetById(int id)
        {
            try
            {
                var odontologo = await _UsuarioAdminServicios.obtenerPorIdUsuario(id);
                if (odontologo == null)
                    return NotFound();
                return Ok(odontologo);
            }
            catch
            {
                return StatusCode(500, "Error al obtener el Odontólogo por ID");
            }
        }

        [HttpGet]
        [Route("Lista")]
        public async Task<IActionResult> Lista()
        {
            var rsp = new Response<List<UsuarioAdminDTO>>();
            try
            {
                rsp.status = true;
                rsp.value = await _UsuarioAdminServicios.listaUsuarios();
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
                rsp.value = await _UsuarioAdminServicios.eliminarUsuario(id);
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
        public async Task<IActionResult> Editar(UsuarioAdminDTO usuarioAdmin)
        {
            var rsp = new Response<bool>();
            try
            {
                rsp.status = true;
                rsp.value = await _UsuarioAdminServicios.editarUsuario(usuarioAdmin);
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
