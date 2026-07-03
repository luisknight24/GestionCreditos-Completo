using GestionIntApi.DTO.Admin;
using GestionIntApi.Repositorios.Interfaces.Admin;
using GestionIntApi.Utilidades;
using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.Controllers.Admin
{

        [Route("api/[controller]")]
        [ApiController]
        public class ProductoBodegaController : Controller
        {
            private readonly IProductoBodega _productoBodegaServicio;
            private readonly ILogger<ProductoBodegaController> _logger;

            public ProductoBodegaController(IProductoBodega productoBodegaServicio, ILogger<ProductoBodegaController> logger)
            {
                _productoBodegaServicio = productoBodegaServicio;
                _logger = logger;
            }

            [HttpGet]
            [Route("Lista")]
            public async Task<IActionResult> Lista()
            {
                var rsp = new Response<List<ProductoBodegaDTO>>();
                try
                {
                    rsp.status = true;
                    rsp.value = await _productoBodegaServicio.listaProductos();
                }
                catch (Exception ex)
                {
                    rsp.status = false;
                    rsp.msg = ex.Message;
                }
                return Ok(rsp);
            }

            [HttpGet]
            [Route("Obtener/{Id}")]
            public async Task<IActionResult> ObtenerPorID(int Id)
            {
                var rsp = new Response<ProductoBodegaDTO>();
                try
                {
                    rsp.status = true;
                    rsp.value = await _productoBodegaServicio.obtenerPorIdProducto(Id);
                }
                catch (Exception ex)
                {
                    rsp.status = false;
                    rsp.msg = ex.Message;
                }
                return Ok(rsp);
            }

            [HttpPost]
            [Route("Crear")]
            public async Task<IActionResult> Crear([FromBody] ProductoBodegaDTO dto)
            {
                var rsp = new Response<ProductoBodegaDTO>();
                try
                {
                    rsp.status = true;
                    rsp.value = await _productoBodegaServicio.crearProducto(dto);
                    rsp.msg = "Producto registrado y código generado con éxito";
                }
                catch (Exception ex)
                {
                    rsp.status = false;
                    rsp.msg = ex.Message;
                }
                return Ok(rsp);
            }

            [HttpPut]
            [Route("Editar")]
            public async Task<IActionResult> Editar([FromBody] ProductoBodegaDTO dto)
            {
                var rsp = new Response<bool>();
                try
                {
                    rsp.status = true;
                    rsp.value = await _productoBodegaServicio.editarProducto(dto);
                    rsp.msg = "Producto actualizado correctamente";
                }
                catch (Exception ex)
                {
                    rsp.status = false;
                    rsp.msg = ex.Message;
                }
                return Ok(rsp);
            }

            [HttpDelete]
            [Route("Eliminar/{id:int}")]
            public async Task<IActionResult> Eliminar(int id)
            {
                var rsp = new Response<bool>();
                try
                {
                    rsp.status = true;
                    rsp.value = await _productoBodegaServicio.eliminarProducto(id);
                    rsp.msg = "Producto eliminado de bodega";
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

