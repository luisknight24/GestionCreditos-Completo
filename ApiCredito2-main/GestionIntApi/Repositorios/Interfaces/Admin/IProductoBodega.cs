using GestionIntApi.DTO.Admin;

namespace GestionIntApi.Repositorios.Interfaces.Admin
{
    public interface IProductoBodega
    {
        Task<List<ProductoBodegaDTO>> listaProductos();
       
        Task<ProductoBodegaDTO> crearProducto(ProductoBodegaDTO modelo);
        Task<bool> editarProducto(ProductoBodegaDTO modelo);
        Task<bool> eliminarProducto(int id);
        Task<ProductoBodegaDTO> obtenerPorIdProducto(int id);


    }
}
