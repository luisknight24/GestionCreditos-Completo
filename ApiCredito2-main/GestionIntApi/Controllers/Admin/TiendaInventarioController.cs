using GestionIntApi.DTO.Admin;
using GestionIntApi.Repositorios.Implementacion.Admin;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.Controllers.Admin
{
    [Route("api/[controller]")]
    [ApiController]
    public class TiendaInventarioController : Controller
    {
        private readonly ITiendaInventarioService _tiendaInventarioService;

        public TiendaInventarioController(ITiendaInventarioService tiendaInventarioService)
        {
            _tiendaInventarioService = tiendaInventarioService;
        }

        [HttpGet("TiendasDisponibles")]
        public async Task<IActionResult> ObtenerTiendasDisponibles()
        {
            var rsp = new Response<List<TiendaDestinoDTO>>();
            try
            {
                rsp.value = await _tiendaInventarioService.ObtenerTiendasDisponibles();
                rsp.status = true;
                rsp.msg = "Tiendas obtenidas correctamente";
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpGet("InventarioTienda/{tiendaId}")]
        public async Task<IActionResult> ObtenerInventarioTienda(int tiendaId)
        {
            var rsp = new Response<StockBodegaDTO>();
            try
            {
                rsp.value = await _tiendaInventarioService.ObtenerInventarioTienda(tiendaId);
                rsp.status = true;
                rsp.msg = "Inventario obtenido correctamente";
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }

        [HttpGet("ProductosTienda/{tiendaId}")]
        public async Task<IActionResult> ObtenerProductosTienda(int tiendaId)
        {
            var rsp = new Response<List<ProductoBodegaDTO>>();
            try
            {
                rsp.value = await _tiendaInventarioService.ObtenerProductosTienda(tiendaId);
                rsp.status = true;
                rsp.msg = "Productos de tienda obtenidos correctamente";
            }
            catch (Exception ex)
            {
                rsp.status = false;
                rsp.msg = ex.Message;
            }
            return Ok(rsp);
        }
    }
}
