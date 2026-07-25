using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Models.Admin;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces.Admin;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class UsuarioAdminService:IUsuarioAdminRepository
    {

        private readonly IGenericRepository<UsuarioAdmin> _UsuarioRepositorio;
        private readonly IMapper _mapper;
        private readonly SistemaGestionDBcontext _context;
        private readonly IConfiguration _configuration;

        public UsuarioAdminService(SistemaGestionDBcontext context, IGenericRepository<UsuarioAdmin> usuarioRepositorio, IMapper mapper, IConfiguration configuration)
        {
            _UsuarioRepositorio = usuarioRepositorio;
            _mapper = mapper;
            _context = context;
            _configuration = configuration;
        }

        private string GenerarTokenAdmin(UsuarioAdmin usuario)
        {
            var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY");
            if (string.IsNullOrWhiteSpace(secretKey))
            {
                secretKey = _configuration.GetSection("JwtSettings")["SecretKey"];
            }

            var key = Encoding.ASCII.GetBytes(secretKey!);
            var expiryStr = _configuration.GetSection("JwtSettings")["ExpiryHours"];
            int expiryHours = int.TryParse(expiryStr, out var h) ? h : 1;

            var tokenHandler = new JwtSecurityTokenHandler();
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
                    new Claim(ClaimTypes.Name, usuario.NombreApellidos ?? ""),
                    new Claim(ClaimTypes.Role, usuario.RolAdmin?.Descripcion ?? "Admin")
                }),
                Expires = DateTime.UtcNow.AddHours(expiryHours),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        public async Task<List<UsuarioAdminDTO>> listaUsuarios()
        {
            try
            {
                var queryUsuario = await _UsuarioRepositorio.Consultar();
                var listaUsuario = queryUsuario.Include(rol => rol.RolAdmin).ToList();
                return _mapper.Map<List<UsuarioAdminDTO>>(listaUsuario);
            }
            catch
            {
                throw;
            }
        }

        public async Task<UsuarioAdminDTO> obtenerPorIdUsuario(int id)
        {
            try
            {
                var odontologoEncontrado = await _UsuarioRepositorio
                    .Obtenerid(u => u.Id == id);
                var listaUsuario = odontologoEncontrado.Include(rol => rol.RolAdmin).ToList();
                var odontologo = listaUsuario.FirstOrDefault();
                if (odontologo == null)
                    throw new TaskCanceledException("Usuario no encontrado");
                return _mapper.Map<UsuarioAdminDTO>(odontologo);
            }
            catch
            {
                throw;
            }
        }

        public async Task<SesionDTOAdmin> ValidarCredenciales(string correo, string clave)
        {
            try
            {
                var queryUsuario = await _UsuarioRepositorio.Consultar(
                u => u.Correo == correo
               );
                if (queryUsuario.FirstOrDefault() == null)
                    throw new TaskCanceledException("El usuario no existe");
                UsuarioAdmin devolverUsuario = queryUsuario.Include(rol => rol.RolAdmin).First();
                if (devolverUsuario.EsActivo == false)
                    throw new TaskCanceledException("El usuario está inactivo");
                if (!BCrypt.Net.BCrypt.Verify(clave, devolverUsuario.Clave))
                    throw new TaskCanceledException("La contraseña es incorrecta");
                
                var sesionDto = _mapper.Map<SesionDTOAdmin>(devolverUsuario);
                sesionDto.Token = GenerarTokenAdmin(devolverUsuario);
                return sesionDto;
            }
            catch
            {
                throw;
            }
        }

        public async Task<UsuarioAdminDTO> crearUsuario(UsuarioAdminDTO modelo)
        {
            try
            {
                // Encripta la contraseña del modelo
                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(modelo.Clave);
                // Actualiza la propiedad 'Clave' del modelo con la contraseña encriptada
                modelo.Clave = hashedPassword;

                var UsuarioCreado = await _UsuarioRepositorio.Crear(_mapper.Map<UsuarioAdmin>(modelo));

                if (UsuarioCreado.Id == 0)
                    throw new TaskCanceledException("No se pudo Crear");
                var query = await _UsuarioRepositorio.Consultar(u => u.Id == UsuarioCreado.Id);
                UsuarioCreado = query.Include(rol => rol.RolAdmin).First();
                return _mapper.Map<UsuarioAdminDTO>(UsuarioCreado);
            }
            catch
            {
                throw;
            }
        }

        public async Task<bool> editarUsuario(UsuarioAdminDTO modelo)
        {
            try
            {
                // Encripta la contraseña del modelo
                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(modelo.Clave);
                // Actualiza la propiedad 'Clave' del modelo con la contraseña encriptada
                modelo.Clave = hashedPassword;

                var UsuarioModelo = _mapper.Map<UsuarioAdmin>(modelo);

                var UsuarioEncontrado = await _UsuarioRepositorio.Obtener(u => u.Id == UsuarioModelo.Id);
                if (UsuarioEncontrado == null)
                    throw new TaskCanceledException("El usuario no existe");
                UsuarioEncontrado.NombreApellidos = UsuarioModelo.NombreApellidos;
                UsuarioEncontrado.Correo = UsuarioModelo.Correo;
                UsuarioEncontrado.RolAdminId = UsuarioModelo.RolAdminId;
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

        public async Task<bool> eliminarUsuario(int id)
        {
            try
            {
                var UsuarioEncontrado = await _UsuarioRepositorio.Obtener(u => u.Id == id);
                if (UsuarioEncontrado == null)
                    throw new TaskCanceledException("Usuario no existe");
                bool respuesta = await _UsuarioRepositorio.Eliminar(UsuarioEncontrado);
                return respuesta;
            }
            catch
            {
                throw;
            }
        }


        public async Task<bool> ExisteCorreoAdmin(string correo)
        {
            return await _context.UsuariosAdmin
                                 .AnyAsync(u => u.Correo.ToLower() == correo.ToLower());
        }
    }
}
