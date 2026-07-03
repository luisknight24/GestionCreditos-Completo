using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Models.Admin;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces.Admin;
using Microsoft.EntityFrameworkCore;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class UsuarioAdminService:IUsuarioAdminRepository
    {

        private readonly IGenericRepository<UsuarioAdmin> _UsuarioRepositorio;
        private readonly IMapper _mapper;
        private readonly SistemaGestionDBcontext _context;

        public UsuarioAdminService(SistemaGestionDBcontext context,IGenericRepository<UsuarioAdmin> usuarioRepositorio, IMapper mapper)
        {
            _UsuarioRepositorio = usuarioRepositorio;
            _mapper = mapper;
            _context = context;
        }

        public async Task<List<UsuarioAdminDTO>> listaUsuarios()
        {
            try
            {
                var queryUsuario = await _UsuarioRepositorio.Consultar();
                var listaUsuario = queryUsuario.Include(rol => rol.RolAdmin).ToList();
                // Recorremos la lista de usuarios y reemplazamos el hash de la contraseña por el texto plano
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
                if (devolverUsuario.EsActivo == false) // Verificar el estado del usuario
                    throw new TaskCanceledException("El usuario está inactivo");
                if (!BCrypt.Net.BCrypt.Verify(clave, devolverUsuario.Clave))
                    throw new TaskCanceledException("La contraseña es incorrecta");
                return _mapper.Map<SesionDTOAdmin>(devolverUsuario);
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
