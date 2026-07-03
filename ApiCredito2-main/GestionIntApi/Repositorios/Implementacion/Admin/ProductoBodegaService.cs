using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Models.Admin;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces.Admin;
using Microsoft.EntityFrameworkCore;

namespace GestionIntApi.Repositorios.Implementacion.Admin
{
    public class ProductoBodegaService: IProductoBodega
    {
        private readonly IGenericRepository<Producto> _productoRepository;
        private readonly IMapper _mapper;

        private readonly IMovimientoInventarioService _movimientoRepository;

        public ProductoBodegaService(
            IGenericRepository<Producto> productoRepository,
            IMovimientoInventarioService movimientoRepository,
        IMapper mapper)
        {
            _productoRepository = productoRepository;
            _mapper = mapper;
            _movimientoRepository = movimientoRepository;
        }

        // 1. LISTAR PRODUCTOS
        public async Task<List<ProductoBodegaDTO>> listaProductos()
        {
            try
            {
                var query = await _productoRepository.Consultar();
                var lista = query.ToList();
                return _mapper.Map<List<ProductoBodegaDTO>>(lista);
            }
            catch
            {
                throw;
            }
        }

        public async Task<ProductoBodegaDTO> crearProducto(ProductoBodegaDTO modelo)
        {
            try
            {
                // 1. Mapeamos el DTO al Modelo
                var producto = _mapper.Map<Producto>(modelo);

                // 2. Generamos el Código Automático
                var consulta = await _productoRepository.Consultar();
                int ultimoId = consulta.Any() ? await consulta.MaxAsync(p => p.Id) : 0;

                string prefijo = producto.TipoProducto.Length >= 3
                    ? producto.TipoProducto.Substring(0, 3).ToUpper()
                    : "GEN";

                producto.Codigo = $"{prefijo}-{DateTime.Now.Year}-{(ultimoId + 1).ToString("D4")}";

                // 3. IMPORTANTE: Si TiendaActualId viene en 0 desde el DTO, lo ponemos en null
                // para que no intente buscar una tienda con Id 0 que no existe.
                if (producto.TiendaId == 0) producto.TiendaId = null;

                // 4. Forzamos la fecha de registro
                producto.FechaRegistro = DateTime.UtcNow;

                // 5. Intentamos guardar
                var creado = await _productoRepository.Crear(producto);

                if (creado.Id == 0)
                    throw new Exception("No se pudo insertar el registro.");

                if (creado.TiendaId.HasValue)
                {
                    await _movimientoRepository.RegistrarEntrada(
                        creado.Id,
                        creado.TiendaId.Value,
                        "Ingreso automático por registro de producto nuevo",
                        "Sistema"
                    );
                }

                return _mapper.Map<ProductoBodegaDTO>(creado);
            }
            catch (Exception ex)
            {
                // Esto captura el error real de la base de datos (Postgres/SQL Server)
                var innerError = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
                throw new Exception($"Error DB: {innerError}");
            }
        }

        // 3. EDITAR PRODUCTO
        public async Task<bool> editarProducto(ProductoBodegaDTO modelo)
        {
            try
            {
                var consulta = await _productoRepository.Consultar(p => p.Id == modelo.Id);
                var productoParaEditar = consulta.FirstOrDefault();

                if (productoParaEditar == null)
                    throw new Exception("El producto no existe en bodega");

                // Mapeo manual o automático de DTO a Entidad
                productoParaEditar.TipoProducto = modelo.TipoProducto;
              //  productoParaEditar.Codigo = modelo.Codigo;
                productoParaEditar.Marca = modelo.Marca;
                productoParaEditar.Modelo = modelo.Modelo;
                productoParaEditar.PropietarioDelProducto=modelo.PropietarioDelProducto;
                productoParaEditar.IMEI = modelo.IMEI;
                productoParaEditar.IMEI2 = modelo.IMEI2;
                productoParaEditar.Serie = modelo.Serie;
                productoParaEditar.Color = modelo.Color;
                productoParaEditar.Tamano = modelo.Tamano;
                productoParaEditar.Estado = modelo.Estado;
                productoParaEditar.PrecioCompra = modelo.PrecioCompra;
                productoParaEditar.Observaciones = modelo.Observaciones;    
                productoParaEditar.PrecioVentaContado = modelo.PrecioVentaContado;
                productoParaEditar.PrecioVentaCredito = modelo.PrecioVentaCredito;

                return await _productoRepository.Editar(productoParaEditar);
            }
            catch
            {
                throw;
            }
        }

        // 4. ELIMINAR PRODUCTO
        public async Task<bool> eliminarProducto(int id)
        {
            try
            {
                var producto = await _productoRepository.Obtener(p => p.Id == id);

                if (producto == null)
                    throw new Exception("Producto no encontrado");

                return await _productoRepository.Eliminar(producto);
            }
            catch
            {
                throw;
            }
        }

        // 5. OBTENER POR ID
        public async Task<ProductoBodegaDTO> obtenerPorIdProducto(int id)
        {
            try
            {
                var producto = await _productoRepository.Obtener(p => p.Id == id);

                if (producto == null)
                    throw new Exception("El producto no existe");

                return _mapper.Map<ProductoBodegaDTO>(producto);
            }
            catch
            {
                throw;
            }
        }
    }
}
