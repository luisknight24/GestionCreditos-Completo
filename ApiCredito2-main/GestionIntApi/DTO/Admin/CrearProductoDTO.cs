namespace GestionIntApi.DTO.Admin
{
    public class CrearProductoDTO
    {
        public string TipoProducto { get; set; } // "Telefono", "TV", "Tablet"
        public string? IMEI { get; set; }
        public string? Serie { get; set; }
        public string Marca { get; set; }
        public string Modelo { get; set; }
        public string? Color { get; set; }
        public decimal PrecioCompra { get; set; }
        public decimal? PrecioVenta { get; set; }
    }
}
