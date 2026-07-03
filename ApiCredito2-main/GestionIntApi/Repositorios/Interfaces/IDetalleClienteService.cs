using GestionIntApi.DTO;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface IDetalleClienteService
    {

        Task<List<DetalleClienteDTO>> GetAllDetalles();
        Task<DetalleClienteDTO> GetDetalleById(int id);
        Task<DetalleClienteDTO> CreateDetalle(DetalleClienteDTO detalleDto);
        Task<bool> UpdateDetalle( DetalleClienteDTO detalleDto);
        Task<bool> DeleteDetalle(int id);

        Task<DetalleClienteDTO> GetDetalleByClienteId(int clienteId);


    }
}
