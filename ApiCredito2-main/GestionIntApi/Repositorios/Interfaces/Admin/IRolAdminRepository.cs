using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;

namespace GestionIntApi.Repositorios.Interfaces.Admin
{
    public interface IRolAdminRepository
    {
        Task<List<RolAdminDto>> listaRoles();
    }
}
