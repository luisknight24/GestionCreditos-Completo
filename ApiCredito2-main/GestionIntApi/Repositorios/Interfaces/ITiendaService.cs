using GestionIntApi.DTO;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface ITiendaService
    {
        // Task<List<TiendaDTO>> GetAllTiendas();
        //Task<TiendaDTO> GetTiendaById(int id);
        // Task<List<TiendaMostrarAppDTO>> GetTiendasApp(int clienteId);

        //        Task<TiendaDTO> CreateTienda(TiendaDTO tiendaDto);
        //    Task<bool> UpdateTienda(TiendaDTO tiendaDto);
        //  Task<bool> DeleteTienda(int id);

        Task<TiendaAdminDTO> CrearTiendaAdmin(TiendaAdminDTO dto);
        Task<List<TiendaAdminDTO>> GetTiendasAdmin();
        Task<TiendaAppDTO> AsociarTiendaCliente(TiendaAppDTO dto);
        Task<List<TiendaAppDTO>> GetTiendasCliente(int clienteId);
        Task<TiendaAdminDTO> GetTiendaAdminById(int id);
        Task<bool> EliminarTienda(int id);

        Task<List<TiendaMostrarAppVentaDTO>> GetFechaVenta(int clienteId);
        Task<bool> EditarTienda(TiendaAdminDTO modelo);

    }
}
