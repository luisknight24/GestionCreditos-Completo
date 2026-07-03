using GestionIntApi.DTO;
using GestionIntApi.Models;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface IClienteService
    {

        Task<List<ClienteDTO>> GetClientes();
        Task<ClienteDTO> GetClienteById(int id);
        Task<ClienteDTO> CreateCliente(ClienteDTO clienteDto);
      
        Task<bool> UpdateCliente( ClienteDTO clienteDto);
        Task<bool> DeleteCliente(int id);
        Task<ClienteDTO> CrearClienteDesdeAdmin(ClienteDTO modelo);
        // Métodos adicionales opcionales
        Task<ClienteMostrarAppDTO> GetClienteParaApp(int UsuarioId);
        Task<List<ReporteDTO>> Reporte(string fechaInicio, string fechaFin);
        Task<IEnumerable<ClienteDTO>> GetClientesPorTienda(int tiendaId);
        Task<IEnumerable<ClienteDTO>> GetClientesPorUsuario(int usuarioId);

       

    }
}
