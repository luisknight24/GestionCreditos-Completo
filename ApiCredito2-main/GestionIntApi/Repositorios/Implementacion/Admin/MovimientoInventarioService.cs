using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Models.Admin;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces.Admin;
using Microsoft.EntityFrameworkCore;

namespace GestionIntApi.Repositorios.Implementacion.Admin
{
    public class MovimientoInventarioService : IMovimientoInventarioService
    {
        private readonly IGenericRepository<MovimientoInventario> _movimientoRepository;
        private readonly IGenericRepository<Producto> _productoRepository;

        public MovimientoInventarioService(
            IGenericRepository<MovimientoInventario> movimientoRepository,
            IGenericRepository<Producto> productoRepository)
        {
            _movimientoRepository = movimientoRepository;
            _productoRepository = productoRepository;
        }

        public async Task<MovimientoInventario> RegistrarEntrada(int productoId, int tiendaDestinoId, string observacion, string usuario)
        {
            var producto = await _productoRepository.Obtener(p => p.Id == productoId);
            if (producto == null)
                throw new Exception("Producto no encontrado");

            var movimiento = new MovimientoInventario
            {
                TipoMovimiento = "ENTRADA",
                ProductoId = productoId,
                TiendaDestinoId = tiendaDestinoId,
                Observacion = observacion,
                UsuarioRegistro = usuario,
                FechaMovimiento = DateTime.UtcNow
            };

            // Actualizar ubicación del producto
            producto.TiendaId = tiendaDestinoId;
            producto.Estado = "Disponible";
            await _productoRepository.Editar(producto);

            return await _movimientoRepository.Crear(movimiento);
        }

        public async Task<MovimientoInventario> RegistrarSalida(int productoId, int tiendaOrigenId, string observacion, string usuario)
        {
            var producto = await _productoRepository.Obtener(p => p.Id == productoId);
            if (producto == null)
                throw new Exception("Producto no encontrado");

            if (producto.TiendaId != tiendaOrigenId)
                throw new Exception("El producto no está en la tienda especificada");

            var movimiento = new MovimientoInventario
            {
                TipoMovimiento = "SALIDA",
                ProductoId = productoId,
                TiendaOrigenId = tiendaOrigenId,
                Observacion = observacion,
                UsuarioRegistro = usuario,
                FechaMovimiento = DateTime.UtcNow
            };

            // Actualizar ubicación del producto (null = sin ubicación)
            producto.TiendaId = null;
            producto.Estado = "En Tránsito";
            await _productoRepository.Editar(producto);

            return await _movimientoRepository.Crear(movimiento);
        }

        public async Task<MovimientoInventario> RegistrarTraslado(int productoId, int tiendaOrigenId, int tiendaDestinoId, string observacion, string usuario)
        {
            var producto = await _productoRepository.Obtener(p => p.Id == productoId);
            if (producto == null)
                throw new Exception("Producto no encontrado");

            if (producto.TiendaId != tiendaOrigenId)
                throw new Exception("El producto no está en la tienda de origen especificada");

            if (tiendaOrigenId == tiendaDestinoId)
                throw new Exception("La tienda de origen y destino no pueden ser la misma");

            var movimiento = new MovimientoInventario
            {
                TipoMovimiento = "TRASLADO",
                ProductoId = productoId,
                TiendaOrigenId = tiendaOrigenId,
                TiendaDestinoId = tiendaDestinoId,
                Observacion = observacion,
                UsuarioRegistro = usuario,
                FechaMovimiento = DateTime.UtcNow
            };

            // 🔥 ACTUALIZAR UBICACIÓN DEL PRODUCTO (lo más importante)
            producto.TiendaId = tiendaDestinoId;
            await _productoRepository.Editar(producto);

            return await _movimientoRepository.Crear(movimiento);
        }

        public async Task<MovimientoInventario> RegistrarVenta(int productoId, int tiendaOrigenId, decimal montoVenta, string observacion, string usuario)
        {
            var producto = await _productoRepository.Obtener(p => p.Id == productoId);
            if (producto == null)
                throw new Exception("Producto no encontrado");

            if (producto.TiendaId != tiendaOrigenId)
                throw new Exception("El producto no está en la tienda especificada");

            var movimiento = new MovimientoInventario
            {
                TipoMovimiento = "VENTA",
                ProductoId = productoId,
                TiendaOrigenId = tiendaOrigenId,
                MontoVenta = montoVenta,
                Observacion = observacion,
                UsuarioRegistro = usuario,
                FechaMovimiento = DateTime.UtcNow
            };

            // Actualizar estado del producto
            producto.Estado = "Vendido";
            producto.TiendaId = null;
            await _productoRepository.Editar(producto);

            return await _movimientoRepository.Crear(movimiento);
        }

        public async Task<MovimientoInventario> RegistrarDevolucion(int productoId, int tiendaDestinoId, string observacion, string usuario)
        {
            var producto = await _productoRepository.Obtener(p => p.Id == productoId);
            if (producto == null)
                throw new Exception("Producto no encontrado");

            var movimiento = new MovimientoInventario
            {
                TipoMovimiento = "DEVOLUCION",
                ProductoId = productoId,
                TiendaDestinoId = tiendaDestinoId,
                Observacion = observacion,
                UsuarioRegistro = usuario,
                FechaMovimiento = DateTime.UtcNow
            };

            // Actualizar estado del producto
            producto.Estado = "Disponible";
            producto.TiendaId = tiendaDestinoId;
            await _productoRepository.Editar(producto);

            return await _movimientoRepository.Crear(movimiento);
        }

        public async Task<MovimientoInventario> RegistrarAjuste(int productoId, int? tiendaId, string observacion, string usuario)
        {
            var producto = await _productoRepository.Obtener(p => p.Id == productoId);
            if (producto == null)
                throw new Exception("Producto no encontrado");

            var movimiento = new MovimientoInventario
            {
                TipoMovimiento = "AJUSTE",
                ProductoId = productoId,
                TiendaDestinoId = tiendaId,
                Observacion = observacion,
                UsuarioRegistro = usuario,
                FechaMovimiento = DateTime.UtcNow
            };

            return await _movimientoRepository.Crear(movimiento);
        }

        public async Task<List<MovimientoInventario>> TrasladarMultiplesProductos(List<int> productosIds, int tiendaOrigenId, int tiendaDestinoId, string observacion, string usuario)
        {
            var movimientos = new List<MovimientoInventario>();

            foreach (var productoId in productosIds)
            {
                var movimiento = await RegistrarTraslado(productoId, tiendaOrigenId, tiendaDestinoId, observacion, usuario);
                movimientos.Add(movimiento);
            }

            return movimientos;
        }

        public async Task<List<MovimientoHistorialDTO>> ObtenerHistorial(int? productoId = null, int? tiendaId = null, DateTime? fechaInicio = null, DateTime? fechaFin = null, string tipoMovimiento = null)
        {
            var query = await _movimientoRepository.Consultar();
            var movimientos = await query
                .Include(m => m.Producto)
                .Include(m => m.TiendaOrigen)
                .Include(m => m.TiendaDestino)
                .ToListAsync();

            // Filtros
            if (productoId.HasValue)
                movimientos = movimientos.Where(m => m.ProductoId == productoId.Value).ToList();

            if (tiendaId.HasValue)
                movimientos = movimientos.Where(m => m.TiendaOrigenId == tiendaId.Value || m.TiendaDestinoId == tiendaId.Value).ToList();

            if (fechaInicio.HasValue)
                movimientos = movimientos.Where(m => m.FechaMovimiento >= fechaInicio.Value).ToList();

            if (fechaFin.HasValue)
                movimientos = movimientos.Where(m => m.FechaMovimiento <= fechaFin.Value).ToList();

            if (!string.IsNullOrEmpty(tipoMovimiento))
                movimientos = movimientos.Where(m => m.TipoMovimiento == tipoMovimiento).ToList();

            return movimientos.Select(m => new MovimientoHistorialDTO
            {
                Id = m.Id,
                TipoMovimiento = m.TipoMovimiento,
                FechaMovimiento = m.FechaMovimiento,
                ProductoId = m.ProductoId,
                Codigo = m.Producto?.Codigo,
                TipoProducto = m.Producto?.TipoProducto,
                Marca = m.Producto?.Marca,
                Modelo = m.Producto?.Modelo,
                IMEI = m.Producto?.IMEI,
                Serie = m.Producto?.Serie,
                TiendaOrigenId = m.TiendaOrigenId,
                TiendaOrigen = m.TiendaOrigen?.NombreTienda,
                TiendaDestinoId = m.TiendaDestinoId,
                TiendaDestino = m.TiendaDestino?.NombreTienda,
                MontoVenta = m.MontoVenta,
                Observacion = m.Observacion,
                UsuarioRegistro = m.UsuarioRegistro
            }).OrderByDescending(m => m.FechaMovimiento).ToList();
        }

        public async Task<List<MovimientoHistorialDTO>> ObtenerHistorialProducto(int productoId)
        {
            return await ObtenerHistorial(productoId: productoId);
        }

        public async Task<List<MovimientoHistorialDTO>> ObtenerHistorialPorIMEI(string imei)
        {
            // Primero buscar el producto por IMEI
            var producto = await _productoRepository.Obtener(p => p.IMEI == imei);

            if (producto == null)
                throw new Exception($"No se encontró ningún producto con el IMEI: {imei}");

            return await ObtenerHistorial(productoId: producto.Id);
        }

        public async Task<List<MovimientoHistorialDTO>> ObtenerHistorialPorSerie(string serie)
        {
            // Primero buscar el producto por Serie
            var producto = await _productoRepository.Obtener(p => p.Serie == serie);

            if (producto == null)
                throw new Exception($"No se encontró ningún producto con la Serie: {serie}");

            return await ObtenerHistorial(productoId: producto.Id);
        }

        public async Task<List<MovimientoHistorialDTO>> ObtenerHistorialPorCodigo(string codigo)
        {
            // Primero buscar el producto por Código
            var producto = await _productoRepository.Obtener(p => p.Codigo == codigo);

            if (producto == null)
                throw new Exception($"No se encontró ningún producto con el Código: {codigo}");

            return await ObtenerHistorial(productoId: producto.Id);
        }

        public async Task<List<MovimientoHistorialDTO>> ObtenerHistorialTienda(int tiendaId)
        {
            return await ObtenerHistorial(tiendaId: tiendaId);
        }
    }

 

}
