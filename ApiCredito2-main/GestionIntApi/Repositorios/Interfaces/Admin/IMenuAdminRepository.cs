using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;

namespace GestionIntApi.Repositorios.Interfaces.Admin
{
    public interface IMenuAdminRepository
    {
        Task<List<MenuAdminDto>> listaMenus(int usuarioId);
    }
}
