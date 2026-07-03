using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
namespace GestionIntApi.Repositorios.Interfaces
{
    public interface  IUsuarioRepository
    {

        Task<List<UsuarioDTO>> listaUsuarios();
        Task<SesionDTO> ValidarCredenciales(string correo, string clave);
        Task<UsuarioDTO> crearUsuario(UsuarioDTO modelo);
        Task<bool> editarUsuario(UsuarioDTO modelo);
        Task<bool> eliminarUsuario(int id);
        Task<UsuarioDTO> obtenerPorIdUsuario(int id);
        Task<UsuarioCompletoDto> ObtenerRegistroIntegralPorId(int idUsuario);
        Task<bool> EditarRegistroIntegral(UsuarioCompletoDto modelo);
        Task<bool> ExisteCorreo(string correo);
        Task<List<UsuarioCompletoDto>> ObtenerTodosIntegral();
    }
}
