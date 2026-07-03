using GestionIntApi.DTO.Admin;
using GestionIntApi.Models.Admin;

namespace GestionIntApi.Repositorios.Interfaces.Admin
{
    public interface IMovimientoInventarioService
    {
        // Crear movimientos
        Task<MovimientoInventario> RegistrarEntrada(int productoId, int tiendaDestinoId, string observacion, string usuario);
        Task<MovimientoInventario> RegistrarSalida(int productoId, int tiendaOrigenId, string observacion, string usuario);
        Task<MovimientoInventario> RegistrarTraslado(int productoId, int tiendaOrigenId, int tiendaDestinoId, string observacion, string usuario);
        Task<MovimientoInventario> RegistrarVenta(int productoId, int tiendaOrigenId, decimal montoVenta, string observacion, string usuario);
        Task<MovimientoInventario> RegistrarDevolucion(int productoId, int tiendaDestinoId, string observacion, string usuario);
        Task<MovimientoInventario> RegistrarAjuste(int productoId, int? tiendaId, string observacion, string usuario);

        // Traslado masivo
        Task<List<MovimientoInventario>> TrasladarMultiplesProductos(List<int> productosIds, int tiendaOrigenId, int tiendaDestinoId, string observacion, string usuario);

        // Consultas
        Task<List<MovimientoHistorialDTO>> ObtenerHistorial(int? productoId = null, int? tiendaId = null, DateTime? fechaInicio = null, DateTime? fechaFin = null, string tipoMovimiento = null);
        Task<List<MovimientoHistorialDTO>> ObtenerHistorialProducto(int productoId);
        Task<List<MovimientoHistorialDTO>> ObtenerHistorialPorIMEI(string imei);
        Task<List<MovimientoHistorialDTO>> ObtenerHistorialPorSerie(string serie);
        Task<List<MovimientoHistorialDTO>> ObtenerHistorialPorCodigo(string codigo);
        Task<List<MovimientoHistorialDTO>> ObtenerHistorialTienda(int tiendaId);
    }


}
