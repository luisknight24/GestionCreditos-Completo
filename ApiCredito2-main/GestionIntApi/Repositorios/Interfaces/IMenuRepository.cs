
using GestionIntApi.DTO;
namespace GestionIntApi.Repositorios.Interfaces
{
    public interface IMenuRepository
    {

        Task<List<MenuDTO>> listaMenus(int usuarioId);




    }
}
