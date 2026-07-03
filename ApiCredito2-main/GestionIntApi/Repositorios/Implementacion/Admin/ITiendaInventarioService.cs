using GestionIntApi.DTO.Admin;

namespace GestionIntApi.Repositorios.Implementacion.Admin
{
    public interface ITiendaInventarioService
    {
        Task<List<TiendaDestinoDTO>> ObtenerTiendasDisponibles();
        Task<StockBodegaDTO> ObtenerInventarioTienda(int tiendaId);
        Task<List<ProductoBodegaDTO>> ObtenerProductosTienda(int tiendaId);
    }
}
