namespace GestionIntApi.DTO.Admin
{
    public class StockPorTipoDTO
    {

        public string TipoProducto { get; set; } // "Telefono", "TV", "Tablet"
        public int Cantidad { get; set; }
        public decimal ValorTotal { get; set; }
    }
}
