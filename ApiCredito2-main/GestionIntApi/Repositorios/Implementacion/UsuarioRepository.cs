using AutoMapper;
using BCrypt.Net;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Repositorios;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Microsoft.IdentityModel.Tokens;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;


namespace GestionIntApi.Repositorios.Implementacion
{
    public class UsuarioRepository : IUsuarioRepository
    {
        private readonly IGenericRepository<Usuario> _UsuarioRepositorio;
        private readonly IGenericRepository<Cliente> _ClienteRepositorio;
        private readonly IGenericRepository<DetalleCliente> _DetalleRepositorio;
        private readonly IGenericRepository<Credito> _CreditoRepositorio;
        private readonly IGenericRepository<Tienda> _TiendaRepositorio;
        private readonly IMapper _mapper;
        private readonly SistemaGestionDBcontext _context;
        private readonly ICreditoService _creditoService;

        private readonly IConfiguration _configuration;
        public UsuarioRepository(IConfiguration configuration,ICreditoService creditoService,IGenericRepository<DetalleCliente> DetalleRepositorio, IGenericRepository<Tienda> TiendaRepositorio, IGenericRepository<Credito> CreditoRepositorio, IGenericRepository<Cliente> ClienteRepositorio, IGenericRepository<Usuario> usuarioRepositorio, IMapper mapper, SistemaGestionDBcontext sistemaGestionDBcontext)
        {
            _UsuarioRepositorio = usuarioRepositorio;
            _mapper = mapper;
            _context = sistemaGestionDBcontext;
            _ClienteRepositorio = ClienteRepositorio;
            _DetalleRepositorio = DetalleRepositorio;
            _CreditoRepositorio = CreditoRepositorio;
            _TiendaRepositorio = TiendaRepositorio;
            _creditoService= creditoService;
            _configuration = configuration;

        }

        public async Task<List<UsuarioDTO>> listaUsuarios()
        {
            try
            {
                var queryUsuario = await _UsuarioRepositorio.Consultar();
                Console.WriteLine("Usuarios encontrados: " + queryUsuario.Count());
                var listaUsuario = queryUsuario.Include(rol => rol.Rol).ToList();
                // Recorremos la lista de usuarios y reemplazamos el hash de la contraseña por el texto plano
                return _mapper.Map<List<UsuarioDTO>>(listaUsuario);
            }
            catch
            {

                throw;
            }
        }

        public async Task<UsuarioDTO> obtenerPorIdUsuario(int id)
        {
            try
            {
                var odontologoEncontrado = await _UsuarioRepositorio
                    .Obtenerid(u => u.Id == id);
                var listaUsuario = odontologoEncontrado.Include(rol => rol.Rol).ToList();
                var odontologo = listaUsuario.FirstOrDefault();
                if (odontologo == null)
                    throw new TaskCanceledException("Usuario no encontrado");
                return _mapper.Map<UsuarioDTO>(odontologo);
            }
            catch
            {
                throw;
            }
        }


     


        public async Task<SesionDTO> ValidarCredenciales(string correo, string clave)
        {
            try
            {
                var queryUsuario = await _UsuarioRepositorio.Consultar(
                u => u.Correo == correo
               );

                if (queryUsuario.FirstOrDefault() == null)
                    throw new TaskCanceledException("El usuario no existe");

                Usuario devolverUsuario = queryUsuario.Include(rol => rol.Rol)
                    .Include(u => u.Cliente) 
                    .FirstOrDefault();

                if (devolverUsuario.EsActivo == false) // Verificar el estado del usuario
                    throw new TaskCanceledException("El usuario está inactivo");
                
                if (!BCrypt.Net.BCrypt.Verify(clave, devolverUsuario.Clave))
                    throw new TaskCanceledException("La contraseña es incorrecta");




                var token = GenerarToken(devolverUsuario);


                var sesionDTO = _mapper.Map<SesionDTO>(devolverUsuario);
                sesionDTO.Token = token;
                return sesionDTO;
            }
            catch
            {
                throw;
            }
        }





        public string GenerarToken1(Usuario usuario)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var key = Encoding.ASCII.GetBytes(jwtSettings["SecretKey"]);

            var tokenHandler = new JwtSecurityTokenHandler();
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
            new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
            new Claim("ClienteId", usuario.Cliente.Id.ToString()),
            new Claim(ClaimTypes.Name, usuario.NombreApellidos)
        }),
                Expires = DateTime.UtcNow.AddHours(int.Parse(jwtSettings["ExpiryHours"])),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }


        public string GenerarToken(Usuario usuario)
        {
            // Intentamos obtener la clave desde la variable de entorno
            var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY");

            if (string.IsNullOrWhiteSpace(secretKey))
            {
                // Si no está la variable, usamos la que está en appsettings.json
                var jwtSettings = _configuration.GetSection("JwtSettings");
                secretKey = jwtSettings["SecretKey"];
            }

            var key = Encoding.ASCII.GetBytes(secretKey);

            var tokenHandler = new JwtSecurityTokenHandler();
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
            new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
            new Claim("ClienteId", usuario.Cliente.Id.ToString()),
            new Claim(ClaimTypes.Name, usuario.NombreApellidos)
        }),
              //  Expires = DateTime.UtcNow.AddHours(int.Parse(jwtSettings["ExpiryHours"])),
                Expires = DateTime.UtcNow.AddHours(int.Parse(_configuration.GetSection("JwtSettings")["ExpiryHours"])),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        public async Task<UsuarioDTO> crearUsuario1(UsuarioDTO modelo)
        {
            try
            {

                // Encripta la contraseña del modelo
                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(modelo.Clave);
                // Actualiza la propiedad 'Clave' del modelo con la contraseña encriptada
                modelo.Clave = hashedPassword;

                var UsuarioCreado = await _UsuarioRepositorio.Crear(_mapper.Map<Usuario>(modelo));
                
                /////////////////////
                
                
   
                // 2. Guardar DetalleCliente
                var detalle = await _DetalleRepositorio.Crear(
                    _mapper.Map<DetalleCliente>(modelo.Cliente.DetalleCliente)
                );

                // 3. Guardar Cliente
                var cliente = new Cliente
                {
                    UsuarioId = UsuarioCreado.Id,
                    DetalleClienteID = detalle.Id
                };

                cliente = await _ClienteRepositorio.Crear(cliente);

                var tiendasCreadas = new List<TiendaApp>();

                if (modelo.Cliente.TiendaApps != null)
                {
                    foreach (var t in modelo.Cliente.TiendaApps)
                    {
                        // 🔥 CAMBIO: Ahora TiendaApp necesita TiendaId
                        // Primero debes buscar o crear la Tienda real

                        var tiendaExistente = await _context.Tiendas
                            .FirstOrDefaultAsync(x => x.CedulaEncargado == t.CedulaEncargado);

                        if (tiendaExistente == null)
                        {
                            throw new TaskCanceledException(
                                $"La tienda con cédula {t.CedulaEncargado} no existe. " +
                                "Primero debe registrarse la tienda."
                            );
                        }

                        // Crear TiendaApp (la relación intermedia)
                        var TiendaApps = new TiendaApp
                        {
                            TiendaId = tiendaExistente.Id,  // ✅ FK a Tiendas
                            ClienteId = cliente.Id,          // ✅ FK a Clientes
                            CedulaEncargado = t.CedulaEncargado,
                            EstadoDeComision = "Pendiente",  // O el valor que necesites
                            FechaRegistro = DateTime.UtcNow
                        };

                        var tiendaCreada = await _context.TiendaApps.AddAsync(TiendaApps);
                        await _context.SaveChangesAsync();

                        tiendasCreadas.Add(TiendaApps);
                    }
                }

                // 5. Guardar créditos
                foreach (var c in modelo.Cliente.Creditos)
                {
                    c.ClienteId = cliente.Id;
                    if (tiendasCreadas.Any())
                        c.TiendaAppId = tiendasCreadas.First().Id;
                    else
                        c.TiendaAppId = null;
                    await _creditoService.CreateCredito(c);
                }

                ////////

                if (UsuarioCreado.Id == 0)
                    throw new TaskCanceledException("No se pudo Crear");
                var query = await _UsuarioRepositorio.Consultar(u => u.Id == UsuarioCreado.Id);
                UsuarioCreado = query.Include(rol => rol.Rol).First();
                return _mapper.Map<UsuarioDTO>(UsuarioCreado);
            }
            catch
            {
                throw;
            }
        }
        public async Task<UsuarioDTO> crearUsuario(UsuarioDTO modelo)
        {
            try
            {
                if (modelo.RolId <= 0) modelo.RolId = 2; // Default to Cliente (RolId = 2)

                var correo = (modelo.Correo ?? "").Trim().ToLower();
                var cedula = modelo.Cliente?.DetalleCliente?.NumeroCedula;

                // 1. Verificar si el correo ya existe en BD
                var usuarioExistente = await _context.Usuarios
                    .FirstOrDefaultAsync(u => u.Correo.ToLower() == correo);

                if (usuarioExistente != null)
                {
                    throw new TaskCanceledException($"El correo '{correo}' ya se encuentra registrado y asociado a una cuenta de crédito.");
                }

                // 2. Verificar si la cédula ya existe en BD
                if (!string.IsNullOrWhiteSpace(cedula))
                {
                    var cedulaExistente = await _context.DetallesCliente
                        .FirstOrDefaultAsync(d => d.NumeroCedula == cedula);

                    if (cedulaExistente != null)
                    {
                        throw new TaskCanceledException($"La cédula '{cedula}' ya se encuentra registrada y asociada a una cuenta de crédito.");
                    }
                }

                // Asegurar objetos no nulos
                if (modelo.Cliente == null) modelo.Cliente = new ClienteDTO();
                if (modelo.Cliente.DetalleCliente == null) modelo.Cliente.DetalleCliente = new DetalleClienteDTO();
                if (modelo.Cliente.Creditos == null) modelo.Cliente.Creditos = new List<CreditoDTO>();
                if (modelo.Cliente.TiendaApps == null) modelo.Cliente.TiendaApps = new List<TiendaAppDTO>();

                // 🔥 PASO 1: VALIDAR / REGISTRAR TIENDAS DINÁMICAMENTE
                if (modelo.Cliente?.TiendaApps != null && modelo.Cliente.TiendaApps.Any())
                {
                    foreach (var t in modelo.Cliente.TiendaApps)
                    {
                        var tiendaExistente = await _context.Tiendas
                            .FirstOrDefaultAsync(x => x.CedulaEncargado == t.CedulaEncargado);

                        if (tiendaExistente == null)
                        {
                            Console.WriteLine($"⚠️ La tienda con encargado {t.CedulaEncargado} no existe. Creándola dinámicamente...");
                            tiendaExistente = new Tienda
                            {
                                NombreTienda = $"Tienda Encargado {t.CedulaEncargado}",
                                Direccion = "Dirección Registrada",
                                NombreEncargado = $"Encargado {t.CedulaEncargado}",
                                CedulaEncargado = t.CedulaEncargado,
                                Telefono = t.CedulaEncargado,
                                ValorComision = 10.00m,
                                FechaRegistro = DateTime.UtcNow
                            };
                            await _context.Tiendas.AddAsync(tiendaExistente);
                            await _context.SaveChangesAsync();
                            Console.WriteLine($"✅ Tienda con encargado {t.CedulaEncargado} creada dinámicamente.");
                        }
                    }
                }

                // ✅ PASO 2: Si pasó todas las validaciones, ahora sí guardamos

                // 1. Encripta la contraseña de forma segura si no está encriptada
                if (!string.IsNullOrWhiteSpace(modelo.Clave) && !modelo.Clave.StartsWith("$2a$") && !modelo.Clave.StartsWith("$2b$"))
                {
                    modelo.Clave = BCrypt.Net.BCrypt.HashPassword(modelo.Clave);
                }

                var UsuarioCreado = await _UsuarioRepositorio.Crear(_mapper.Map<Usuario>(modelo));

                // 2. Guardar DetalleCliente
                var detalle = await _DetalleRepositorio.Crear(
                    _mapper.Map<DetalleCliente>(modelo.Cliente.DetalleCliente)
                );

                // 3. Guardar Cliente
                var cliente = new Cliente
                {
                    UsuarioId = UsuarioCreado.Id,
                    DetalleClienteID = detalle.Id
                };
                cliente = await _ClienteRepositorio.Crear(cliente);

                // 4. Crear TiendaApps (ya validamos que todas existen)
                var tiendasCreadas = new List<TiendaApp>();
                if (modelo.Cliente.TiendaApps != null)
                {
                    foreach (var t in modelo.Cliente.TiendaApps)
                    {
                        // Ya sabemos que existe, la buscamos de nuevo
                        var tiendaExistente = await _context.Tiendas
                            .FirstOrDefaultAsync(x => x.CedulaEncargado == t.CedulaEncargado);

                        var TiendaApps = new TiendaApp
                        {
                            TiendaId = tiendaExistente.Id,
                            ClienteId = cliente.Id,
                            CedulaEncargado = t.CedulaEncargado,
                            EstadoDeComision = t.EstadoDeComision,
                            FechaRegistro = DateTime.UtcNow
                        };

                        await _context.TiendaApps.AddAsync(TiendaApps);
                        await _context.SaveChangesAsync();
                        tiendasCreadas.Add(TiendaApps);
                    }
                }

                foreach (var c in modelo.Cliente.Creditos)
                {
                    c.ClienteId = cliente.Id;
                    if (tiendasCreadas.Any())
                        c.TiendaAppId = tiendasCreadas.First().Id;
                    else
                        c.TiendaAppId = null;
                    await _creditoService.CreateCredito(c);
                }


                return _mapper.Map<UsuarioDTO>(UsuarioCreado);
            }
            catch
            {
                throw;
            }
        }

        public async Task<bool> editarUsuario(UsuarioDTO modelo)
        {
            try
            {
                // Encripta la contraseña del modelo
                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(modelo.Clave);
                // Actualiza la propiedad 'Clave' del modelo con la contraseña encriptada
                modelo.Clave = hashedPassword;

                var UsuarioModelo = _mapper.Map<Usuario>(modelo);

                var UsuarioEncontrado = await _UsuarioRepositorio.Obtener(u => u.Id == UsuarioModelo.Id);
                if (UsuarioEncontrado == null)
                    throw new TaskCanceledException("El usuario no existe");
                UsuarioEncontrado.NombreApellidos = UsuarioModelo.NombreApellidos;
                UsuarioEncontrado.Correo = UsuarioModelo.Correo;
                UsuarioEncontrado.RolId = UsuarioModelo.RolId;
                UsuarioEncontrado.Clave = UsuarioModelo.Clave;
                UsuarioEncontrado.EsActivo = UsuarioModelo.EsActivo;
                bool respuesta = await _UsuarioRepositorio.Editar(UsuarioEncontrado);
                return respuesta;
            }
            catch
            {
                throw;
            }
        }

        public async Task<List<UsuarioCompletoDto>> ObtenerTodosIntegral()
        {
            try
            {
                // 1. Consultamos TODOS los usuarios con sus relaciones
                var usuarios = await _context.Usuarios
                    .Include(u => u.Rol)
                    .Include(u => u.Cliente)
                        .ThenInclude(c => c.DetalleCliente)
                    .AsNoTracking()
                    .ToListAsync();

                var listaDto = new List<UsuarioCompletoDto>();

                foreach (var usuario in usuarios)
                {
                    var dto = _mapper.Map<UsuarioCompletoDto>(usuario);

                    // 2. Buscamos el ÚLTIMO crédito para cada usuario
                    if (usuario.Cliente != null)
                    {
                        var ultimoCredito = await _context.Creditos
                            .Include(c => c.TiendaApp)
                            .Where(c => c.ClienteId == usuario.Cliente.Id)
                            .OrderByDescending(c => c.Id)
                            .FirstOrDefaultAsync();

                        if (ultimoCredito != null)
                        {
                            var creditoDto = _mapper.Map<CreditoDTO>(ultimoCredito);
                            dto.Cliente.Creditos = new List<CreditoDTO> { creditoDto };

                            if (ultimoCredito.TiendaApp != null)
                            {
                                dto.Cliente.TiendaApps = new List<TiendaAppDTO> {
                            _mapper.Map<TiendaAppDTO>(ultimoCredito.TiendaApp)
                        };
                            }
                        }
                    }
                    listaDto.Add(dto);
                }

                return listaDto;
            }
            catch (Exception) { throw; }
        }

        public async Task<UsuarioCompletoDto> ObtenerRegistroIntegralPorId(int idUsuario)
        {
            try
            {
                // 1. Consultamos el usuario con su cliente y detalle
                var usuario = await _context.Usuarios
                    .Include(u => u.Rol)
                    .Include(u => u.Cliente)
                        .ThenInclude(c => c.DetalleCliente)
                    .AsNoTracking()
                    .FirstOrDefaultAsync(u => u.Id == idUsuario);

                if (usuario == null) throw new TaskCanceledException("Usuario no encontrado");

                var dto = _mapper.Map<UsuarioCompletoDto>(usuario);

                // 2. Buscamos el ÚLTIMO crédito manualmente con su TiendaApp
                if (usuario.Cliente != null)
                {
                    var ultimoCredito = await _context.Creditos
                        .Include(c => c.TiendaApp) // Traemos la tienda asociada al crédito
                        .Where(c => c.ClienteId == usuario.Cliente.Id)
                        .OrderByDescending(c => c.Id) // El último registrado
                        .FirstOrDefaultAsync();

                    if (ultimoCredito != null)
                    {
                        // Mapeamos el crédito y lo asignamos a la lista del DTO
                        var creditoDto = _mapper.Map<CreditoDTO>(ultimoCredito);
                        dto.Cliente.Creditos = new List<CreditoDTO> { creditoDto };

                        // Si necesitas enviar los datos de la tienda en el DTO de TiendaApps
                        if (ultimoCredito.TiendaApp != null)
                        {
                            dto.Cliente.TiendaApps = new List<TiendaAppDTO> {
                        _mapper.Map<TiendaAppDTO>(ultimoCredito.TiendaApp)
                    };
                        }
                    }
                }

                return dto;
            }
            catch (Exception) { throw; }
        }

        public async Task<bool> EditarRegistroIntegral(UsuarioCompletoDto modelo)
        {
            try
            {
                // 1. Cargamos todo el objeto con sus hijos en una sola consulta
                var usuarioDb = await _context.Usuarios
                    .Include(u => u.Cliente)
                        .ThenInclude(c => c.DetalleCliente)
                    .Include(u => u.Cliente)
                        .ThenInclude(c => c.Creditos)
                    .Include(u => u.Cliente)
                        .ThenInclude(c => c.TiendaApps)
                    .FirstOrDefaultAsync(u => u.Id == modelo.Id);

                if (usuarioDb == null) return false;

                // 2. Actualizamos el Usuario
                usuarioDb.NombreApellidos = modelo.NombreApellidos;
                usuarioDb.Correo = modelo.Correo;
               // usuarioDb.Clave = modelo.Clave;
                usuarioDb.RolId = modelo.RolId;
                usuarioDb.EsActivo = modelo.EsActivo == 1;
                // 🔥 LÓGICA DE CONTRASEÑA SEGURA
                if (!string.IsNullOrWhiteSpace(modelo.Clave))
                {
                    string nuevaClave = modelo.Clave.Trim(); // Elimina espacios accidentales

                    // Verificamos si es un hash de BCrypt válido
                    // BCrypt suele empezar con $2a$, $2b$ o $2y$
                    bool esHash = nuevaClave.StartsWith("$2a$") ||
                                  nuevaClave.StartsWith("$2b$") ||
                                  nuevaClave.StartsWith("$2y$");

                    if (!esHash)
                    {
                        // Solo encriptamos si es texto plano real
                        usuarioDb.Clave = BCrypt.Net.BCrypt.HashPassword(nuevaClave);
                    }
                    // Si es un hash, no hacemos nada (mantenemos el valor que ya tenía el usuarioDb)
                }

                // 3. Actualizamos el Detalle del Cliente
                if (usuarioDb.Cliente?.DetalleCliente != null && modelo.Cliente?.DetalleCliente != null)
                {
                    var detDb = usuarioDb.Cliente.DetalleCliente;
                    var detMod = modelo.Cliente.DetalleCliente;
                    detDb.NumeroCedula = detMod.NumeroCedula;
                    detDb.NombreApellidos = detMod.NombreApellidos;
                    detDb.Telefono = detMod.Telefono;
                    detDb.Direccion = detMod.Direccion;
                  //  detDb.NombrePropietario = detMod.NombrePropietario;
                }

                // 4. Actualizamos TiendaApp y el Crédito específico
                var creditoMod = modelo.Cliente?.Creditos?.FirstOrDefault();
                var tiendaAppMod = modelo.Cliente?.TiendaApps?.FirstOrDefault();

                if (creditoMod != null && usuarioDb.Cliente != null)
                {
                    var creditoDb = usuarioDb.Cliente.Creditos.FirstOrDefault(c => c.Id == creditoMod.Id);

                    if (creditoDb != null)
                    {
                        // Actualizar la relación intermedia TiendaApp
                        if (tiendaAppMod != null)
                        {
                            var tiendaAppDb = usuarioDb.Cliente.TiendaApps
                                .FirstOrDefault(ta => ta.Id == creditoDb.TiendaAppId);

                            if (tiendaAppDb != null)
                            {
                                tiendaAppDb.CedulaEncargado = tiendaAppMod.CedulaEncargado;
                                tiendaAppDb.EstadoDeComision = tiendaAppMod.EstadoDeComision;
                            }
                        }

                        // Actualizar los valores del Crédito
                        creditoDb.Marca = creditoMod.Marca;
                        creditoDb.Modelo = creditoMod.Modelo;
                        creditoDb.IMEI = creditoMod.IMEI;
                        creditoDb.Capacidad = creditoMod.Capacidad;
                        creditoDb.NombrePropietario = creditoMod.NombrePropietario;
                    }
                }

                // 5. Un solo SaveChangesAsync() garantiza que todo sea una sola operación en Postgres
                // Si algo falla aquí, no se guarda nada de lo anterior.
                await _context.SaveChangesAsync();

                return true;
            }
            catch (Exception ex)
            {
                // Loguea el error interno para saber qué campo falló
                throw new Exception("Error al actualizar en Postgres: " + ex.Message);
            }
        }
        public async Task<bool> eliminarUsuario(int id)
        {
            var usuario = await _context.Usuarios
        .Include(u => u.Cliente)
            .ThenInclude(c => c.DetalleCliente)
        .Include(u => u.Cliente)
            .ThenInclude(c => c.Creditos)
        .Include(u => u.Cliente)
            .ThenInclude(c => c.TiendaApps)
        .FirstOrDefaultAsync(u => u.Id == id);

            if (usuario == null)
                return false;

            _context.Usuarios.Remove(usuario);

            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> ExisteCorreo(string correo)
        {
            return await _context.Usuarios
                                 .AnyAsync(u => u.Correo.ToLower() == correo.ToLower());
        }

      
    }
}
