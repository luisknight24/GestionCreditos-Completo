namespace GestionIntApi.DTO.Admin
{
    public class ProductoBodegaDTO
    {


        public int Id { get; set; }
        public int? TiendaId { get; set; }
        public string TipoProducto { get; set; }


        public decimal? PrecioVentaCredito { get; set; }
        public decimal? PrecioVentaContado { get; set; }
        public string? PropietarioDelProducto { get; set; }
        public string? IMEI2 { get; set; }
        public string? Observaciones { get; set; }
        public string Codigo { get; set; }
        public string Marca { get; set; }
        public string Modelo { get; set; }
        public string? IMEI { get; set; }
     
        public string? Serie { get; set; }
        public string? Color { get; set; }
        public string? Tamano { get; set; }
        public string Estado { get; set; }
        public decimal PrecioCompra { get; set; }
        public decimal? PrecioVenta { get; set; }
        public DateTime FechaIngreso { get; set; }
        public int DiasEnBodega { get; set; }


    }
}
