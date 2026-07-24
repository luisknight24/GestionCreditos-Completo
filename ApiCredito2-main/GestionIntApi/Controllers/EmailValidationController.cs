using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Models.Admin;
using GestionIntApi.Repositorios.Implementacion;
using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Repositorios.Interfaces.Admin;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Win32;
using System.IO;
using System.Net.Sockets;
using System.Security.Cryptography;
using System.Threading.Tasks;

namespace GestionIntApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EmailValidationController : ControllerBase
    {
        private readonly SistemaGestionDBcontext _context;
        private readonly IEmailService _emailService;
        private readonly ICodigoVerificacionService _codigoService;
        private readonly IUsuarioRepository _UsuarioServicios;
        private readonly IUsuarioAdminRepository _UsuarioServiciosAdmin;
        private readonly IRegistroTemporalService _registroTemporal;
        private readonly IRegistroTemporalAdminService _registroTemporalAdmin;
        public EmailValidationController(IUsuarioAdminRepository UsuarioServiciosAdmin,IRegistroTemporalAdminService registroTemporalAdmin,SistemaGestionDBcontext context, IEmailService emailService, ICodigoVerificacionService codigoService, IUsuarioRepository usuarioServicios, IRegistroTemporalService iRegistroTemporalService)
        { 
            _context = context;
            _emailService = emailService;
            _codigoService = codigoService;
            _UsuarioServicios = usuarioServicios;
            _registroTemporal = iRegistroTemporalService;
            _registroTemporalAdmin = registroTemporalAdmin;
            _UsuarioServiciosAdmin = UsuarioServiciosAdmin;
        }

        [HttpPost("EnviarCodigo")]
        public async Task<IActionResult> EnviarCodigo([FromBody] string correo)
        {
            var codigo = new Random().Next(100000, 999999).ToString();

            _codigoService.GuardarCodigo(correo, codigo);
          

            await _emailService.SendEmailAsync(
                correo,
                "Código de verificación",
                $"<h3>Tu código es: <b>{codigo}</b></h3>"
            );

            return Ok(new { status = true, msg = "Código enviado" });
        }

        [HttpPost("EnviarCodigo1")]
        public async Task<IActionResult> EnviarCodigo([FromBody] UsuarioDTO usuario)
        {

            // --- LOGS ---
            Console.WriteLine("===== USUARIO RECIBIDO =====");
            Console.WriteLine($"Nombre: {usuario.NombreApellidos}");
            Console.WriteLine($"Correo: {usuario.Correo}");
            if (usuario.Cliente != null)
            {
                Console.WriteLine("Cliente existe");
                if (usuario.Cliente.Creditos != null)
                {
                    foreach (var c in usuario.Cliente.Creditos)
                    {
                        Console.WriteLine("----- Credito -----");
                        Console.WriteLine($"MontoTotal: {c.MontoTotal}");
                       // Console.WriteLine($"FotoContrato: {c.FotoContrato}");
                        //Console.WriteLine($"FotoCelularEntregadoUrl: {c.FotoCelularEntregadoUrl}");
                    }
                }
                else
                {
                    Console.WriteLine("No hay créditos");
                }
            }
            else
            {
                Console.WriteLine("Cliente es null");
            }

            var correo = usuario.Correo;

            var codigo = new Random().Next(100000, 999999).ToString();

            // Guardar solo el código si quieres
            _codigoService.GuardarCodigo(correo, codigo);

            // Guardar TODO en registro temporal
            _registroTemporal.GuardarRegistro(correo, new RegistroTemporal
            {
                Usuario = usuario,
                Codigo = codigo,
                Expira = DateTime.UtcNow.AddMinutes(5)
            });

            // Enviar correo en segundo plano para responder de inmediato en <300ms
            _ = Task.Run(async () =>
            {
                try
                {
                    await _emailService.SendEmailAsync(
                        correo,
                        "Código de verificación",
                        $"<h3>Tu código es: <b>{codigo}</b></h3>"
                    );
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"❌ Error enviando correo en background: {ex.Message}");
                }
            });

            return Ok(new { status = true, msg = "Código enviado" });
        }


      
        [HttpPost("EnviarCodigoBD")]
        public async Task<IActionResult> EnviarCodigo2([FromBody] UsuarioDTO usuario)
        {
            // 0️⃣ Validaciones básicas
            if (usuario == null)
                return BadRequest(new { status = false, msg = "Usuario nulo" });

            if (string.IsNullOrWhiteSpace(usuario.Correo))
                return BadRequest(new { status = false, msg = "Correo no proporcionado" });

            Console.WriteLine("===== USUARIO RECIBIDO =====");
            Console.WriteLine($"Nombre: {usuario.NombreApellidos}");
            Console.WriteLine($"Correo: {usuario.Correo}");

            if (usuario.Cliente?.Creditos != null)
            {
                foreach (var c in usuario.Cliente.Creditos)
                {
                    Console.WriteLine("----- Credito -----");
                    Console.WriteLine($"MontoTotal: {c.MontoTotal}");
                //    Console.WriteLine($"FotoContrato: {c.FotoContrato}");
                 //   Console.WriteLine($"FotoCelularEntregadoUrl: {c.FotoCelularEntregadoUrl}");
                }
            }

            var correo = usuario.Correo.Trim().ToLower();

            // 1️⃣ Verificar código activo en BD
            var codigoActivo = await _context.CodigosVerificacion
                .FirstOrDefaultAsync(c => c.Correo == correo && c.Expira > DateTime.UtcNow);

            if (codigoActivo != null)
            {
                return Ok(new { status = true, msg = "Código ya enviado, revisa tu correo" });
            }

            // 2️⃣ Crear código
            var codigo = new Random().Next(100000, 999999).ToString();

            var nuevoCodigo = new VerificationCode
            {
                Correo = correo,
                Codigo = codigo,
                Expira = DateTime.UtcNow.AddMinutes(5),
            };

            _context.CodigosVerificacion.Add(nuevoCodigo);
            await _context.SaveChangesAsync();

            // 3️⃣ Enviar correo en BACKGROUND
            _ = Task.Run(async () =>
            {
                try
                {
                    await _emailService.SendEmailAsync(
                        correo,
                        "Código de verificación",
                        $"<h3>Tu código es: <b>{codigo}</b></h3>"
                    );
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"❌ Error enviando correo: {ex.Message}");
                }
            });

            // 4️⃣ Responder INMEDIATO
            return Ok(new { status = true, msg = "Código enviado" });
        }



        /*  [HttpPost("ValidarCodigo")]
          public async Task<IActionResult> ValidarCodigo([FromBody] VerificationCode req)
          {
              var valido = _codigoService.ValidarCodigo(req.Correo, req.Codigo);

              if (!valido)
                  return BadRequest(new { status = false, msg = "Código incorrecto o expirado" });

              return Ok(new { status = true, msg = "Correo verificado correctamente" });



              // Guardar usuario en la base de datos
              var nuevoUsuario = await _UsuarioServicios.crearUsuario(req.Usuario);

              // Eliminar registro temporal
              _registroTemporal.EliminarRegistro(req.Correo);

              rsp.status = true;
              rsp.value = nuevoUsuario;
              rsp.msg = "Usuario registrado correctamente.";

              return Ok(rsp);
          }
        */
        [HttpPost("ValidarCodigoantesdevT")]
        public async Task<IActionResult> ValidarCodigoAntesdeVerificaciondeTiempo([FromBody] VerificationCode req)
        {

            Console.WriteLine("=== 📥 PETICIÓN ValidarCodigo ===");
            Console.WriteLine($"Correo recibido: {req.Correo}");
            Console.WriteLine($"Código recibido: {req.Codigo}");

            var rsp = new Response<UsuarioDTO>();

            var registro = _registroTemporal.ObtenerRegistro(req.Correo);

            if (registro == null)
            {
                Console.WriteLine("❌ No existe registro temporal para este correo.");
                rsp.status = false;
                rsp.msg = "Código incorrecto o expirado.";
                return BadRequest(rsp);
            }

         //   Console.WriteLine("Registro encontrado en memoria:");
          //  Console.WriteLine($"Código guardado: {registro.Codigo}");

            if (registro.Codigo != req.Codigo)
            {
            //    Console.WriteLine("❌ El código NO coincide con el guardado.");
                rsp.status = false;
                rsp.msg = "Código incorrecto o expirado.";
                return BadRequest(rsp);
            }

            //Console.WriteLine("✅ Código correcto, procediendo a crear usuario...");

            // Guardar usuario en la base de datos
            var nuevoUsuario = await _UsuarioServicios.crearUsuario(registro.Usuario);

            // Eliminar registro temporal
            _registroTemporal.EliminarRegistro(req.Correo);
           // Console.WriteLine("🗑 Registro temporal eliminado.");

            rsp.status = true;
            rsp.value = nuevoUsuario;
            rsp.msg = "Usuario registrado correctamente.";

            Console.WriteLine("=== ✔ RESPUESTA Correcta ===");

            return Ok(rsp);
        }


        [HttpPost("ValidarCodigo")]
        public async Task<IActionResult> ValidarCodigo1([FromBody] VerificationCode req)
        {
            Console.WriteLine("=== 📥 PETICIÓN ValidarCodigo ===");
            Console.WriteLine($"Correo recibido: {req.Correo}");
            Console.WriteLine($"Código recibido: {req.Codigo}");

            var rsp = new Response<UsuarioDTO>();

            try
            {
                var registro = _registroTemporal.ObtenerRegistro(req.Correo);

                if (registro == null)
                {
                    Console.WriteLine("❌ No existe registro temporal para este correo.");
                    rsp.status = false;
                    rsp.msg = "Código incorrecto o expirado.";
                    return BadRequest(rsp);
                }

                // ✅ Verificar expiración por tiempo
                var tiempoTranscurrido = DateTime.UtcNow - registro.Expira;
                if (tiempoTranscurrido.TotalMinutes > 5) // Expira en 5 minutos
                {
                    Console.WriteLine("❌ El código ha expirado por tiempo.");
                    _registroTemporal.EliminarRegistro(req.Correo);
                    rsp.status = false;
                    rsp.msg = "El código ha expirado. Solicite uno nuevo.";
                    return BadRequest(rsp);
                }

                // Validar código
                if (registro.Codigo != req.Codigo)
                {
                    Console.WriteLine("❌ El código NO coincide con el guardado.");
                    rsp.status = false;
                    rsp.msg = "Código incorrecto.";
                    return BadRequest(rsp);
                }

                Console.WriteLine("✅ Código correcto, procediendo a crear usuario...");

                // ✅ SOLO AQUÍ SE GUARDA EN LA BASE DE DATOS
                var nuevoUsuario = await _UsuarioServicios.crearUsuario(registro.Usuario);

                // Eliminar registro temporal SOLO si se guardó exitosamente
                _registroTemporal.EliminarRegistro(req.Correo);
                Console.WriteLine("🗑 Registro temporal eliminado.");

                rsp.status = true;
                rsp.value = nuevoUsuario;
                rsp.msg = "Usuario registrado correctamente.";
                Console.WriteLine("=== ✔ RESPUESTA Correcta ===");

                return Ok(rsp);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ ERROR GENERAL: {ex.Message}");
                if (ex.InnerException != null)
                {
                    Console.WriteLine($"🔍 INNER EXCEPTION: {ex.InnerException.Message}");
                }
                Console.WriteLine($"StackTrace: {ex.StackTrace}");

                // Si falla al guardar en BD, NO se elimina el registro temporal
                // para que el usuario pueda reintentar
                rsp.status = false;
                rsp.msg = "Error al procesar la solicitud. Intente nuevamente.";
                return StatusCode(500, rsp);
            }
        }


        [HttpPost("ValidarCodigoconBD")]
        public async Task<IActionResult> ValidarCodigo([FromBody] VerificationRequestDTO req)
        {
            if (req == null || string.IsNullOrWhiteSpace(req.Correo) || string.IsNullOrWhiteSpace(req.Codigo))
                return BadRequest(new { status = false, msg = "Correo o código no proporcionado" });

            Console.WriteLine("=== 📥 PETICIÓN ValidarCodigo ===");
            Console.WriteLine($"Correo recibido: {req.Correo}");
            Console.WriteLine($"Código recibido: {req.Codigo}");

            var correo = req.Correo.Trim().ToLower();

            // 1️⃣ Buscar código activo en DB
            var codigoActivo = await _context.CodigosVerificacion
                .FirstOrDefaultAsync(c => c.Correo == correo && c.Codigo == req.Codigo && c.Expira > DateTime.UtcNow);

            if (codigoActivo == null)
                return BadRequest(new { status = false, msg = "Código incorrecto o expirado." });

            try
            {
                // 2️⃣ Crear usuario usando tu servicio existente
                var nuevoUsuario = await _UsuarioServicios.crearUsuario(req.Usuario);

                // 3️⃣ Opcional: eliminar código usado
                _context.CodigosVerificacion.Remove(codigoActivo);
                await _context.SaveChangesAsync();

                return Ok(new { status = true, msg = "Usuario registrado correctamente", value = nuevoUsuario });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error creando usuario: {ex.Message}");
                return StatusCode(500, new { status = false, msg = "Error creando usuario" });
            }
        }

        [HttpPost("EnviarCodigoAdmin")]
        public async Task<IActionResult> EnviarCodigoAdmin([FromBody] UsuarioAdminDTO usuario)
        {

            // --- LOGS ---
            Console.WriteLine("===== USUARIO RECIBIDO =====");
            Console.WriteLine($"Nombre: {usuario.NombreApellidos}");
            Console.WriteLine($"Correo: {usuario.Correo}");
           

            var correo = usuario.Correo;

            var codigo = new Random().Next(100000, 999999).ToString();

            // Guardar solo el código si quieres
            _codigoService.GuardarCodigo(correo, codigo);

            // Guardar TODO en registro temporal
            _registroTemporalAdmin.GuardarRegistro(correo, new RegistroTemporalAdmin
            {
                UsuarioAdmin = usuario,
                Codigo = codigo,
                Expira = DateTime.Now.AddMinutes(5)
            });

            // Enviar correo en segundo plano para responder de inmediato
            _ = Task.Run(async () =>
            {
                try
                {
                    await _emailService.SendEmailAsync(
                        correo,
                        "Código de verificación",
                        $"<h3>Tu código es: <b>{codigo}</b></h3>"
                    );
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"❌ Error enviando correo en background admin: {ex.Message}");
                }
            });

            return Ok(new { status = true, msg = "Código enviado" });
        }


        [HttpPost("ValidarCodigoAdmin")]
        public async Task<IActionResult> ValidarCodigoAdmin([FromBody] VerificationCode req)
        {

            Console.WriteLine("=== 📥 PETICIÓN ValidarCodigo ===");
            Console.WriteLine($"Correo recibido: {req.Correo}");
            Console.WriteLine($"Código recibido: {req.Codigo}");

            var rsp = new Response<UsuarioAdminDTO>();

            var registro = _registroTemporalAdmin.ObtenerRegistro(req.Correo);

            if (registro == null)
            {
                Console.WriteLine("❌ No existe registro temporal para este correo.");
                rsp.status = false;
                rsp.msg = "Código incorrecto o expirado.";
                return BadRequest(rsp);
            }

            //   Console.WriteLine("Registro encontrado en memoria:");
            //  Console.WriteLine($"Código guardado: {registro.Codigo}");

            if (registro.Codigo != req.Codigo)
            {
                //    Console.WriteLine("❌ El código NO coincide con el guardado.");
                rsp.status = false;
                rsp.msg = "Código incorrecto o expirado.";
                return BadRequest(rsp);
            }

            //Console.WriteLine("✅ Código correcto, procediendo a crear usuario...");

            // Guardar usuario en la base de datos
            var nuevoUsuario = await _UsuarioServiciosAdmin.crearUsuario(registro.UsuarioAdmin);

            // Eliminar registro temporal
            _registroTemporal.EliminarRegistro(req.Correo);
            // Console.WriteLine("🗑 Registro temporal eliminado.");

            rsp.status = true;
            rsp.value = nuevoUsuario;
            rsp.msg = "Usuario registrado correctamente.";

            Console.WriteLine("=== ✔ RESPUESTA Correcta ===");

            return Ok(rsp);
        }


    }

}
