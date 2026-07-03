using GestionIntApi.Models;

namespace GestionIntApi.Repositorios.Contrato
{
    public interface IClienteRepository
    {
        Task<Cliente> Registrar(Cliente modelo);
        Task<IEnumerable<Cliente>> ObtenerClientesCompletos();
        Task<Cliente> ObtenerClienteId(int id);
        Task<bool> Editar(Cliente modelo);
        Task<bool> Eliminar(Cliente modelo);

    }
}
