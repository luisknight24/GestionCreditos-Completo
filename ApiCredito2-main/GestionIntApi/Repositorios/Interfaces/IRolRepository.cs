using GestionIntApi.DTO;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface IRolRepository
    {
        Task<List<RolDTO>> listaRoles();



    }
}
