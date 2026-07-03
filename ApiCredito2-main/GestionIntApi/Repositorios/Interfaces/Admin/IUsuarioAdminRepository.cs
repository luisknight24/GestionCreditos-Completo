using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;

namespace GestionIntApi.Repositorios.Interfaces.Admin
{
    public interface IUsuarioAdminRepository
    {

        Task<List<UsuarioAdminDTO>> listaUsuarios();
        Task<SesionDTOAdmin> ValidarCredenciales(string correo, string clave);
        Task<UsuarioAdminDTO> crearUsuario(UsuarioAdminDTO modelo);
        Task<bool> editarUsuario(UsuarioAdminDTO modelo);
        Task<bool> eliminarUsuario(int id);
        Task<bool> ExisteCorreoAdmin(string correo);
        Task<UsuarioAdminDTO> obtenerPorIdUsuario(int id);
    }
}
