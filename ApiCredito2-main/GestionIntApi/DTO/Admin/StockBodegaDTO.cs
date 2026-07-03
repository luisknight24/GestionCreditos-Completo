namespace GestionIntApi.DTO.Admin
{
    public class StockBodegaDTO
    {
        public int TotalProductos { get; set; }
        public int ProductosDisponibles { get; set; }
        public int ProductosEnTransito { get; set; }
        public int ProductosDanados { get; set; }
        public decimal ValorTotal { get; set; }

        // Desglose por tipo (Teléfonos, TVs, etc.)
        public List<StockPorTipoDTO> DesglosePorTipo { get; set; }


    }
}
