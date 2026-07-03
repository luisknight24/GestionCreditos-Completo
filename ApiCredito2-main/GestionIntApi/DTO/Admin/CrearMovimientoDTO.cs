namespace GestionIntApi.DTO.Admin
{
    public class CrearMovimientoDTO
    {


        public string TipoMovimiento { get; set; } // ENTRADA, SALIDA, TRASLADO, VENTA
        public int ProductoId { get; set; }
        public int? TiendaOrigenId { get; set; }
        public int? TiendaDestinoId { get; set; }
        public decimal? MontoVenta { get; set; }
        public string? Observacion { get; set; }




    }
}
