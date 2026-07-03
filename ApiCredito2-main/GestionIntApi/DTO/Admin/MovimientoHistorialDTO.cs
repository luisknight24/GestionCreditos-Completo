namespace GestionIntApi.DTO.Admin
{
    public class MovimientoHistorialDTO
    {
        public int Id { get; set; }
        public string TipoMovimiento { get; set; } // ENTRADA, SALIDA, TRASLADO, VENTA
        public DateTime FechaMovimiento { get; set; }

        // Producto
        public int ProductoId { get; set; }
        public string Codigo { get; set; } // 🔥 NUEVO
        public string TipoProducto { get; set; } // "Telefono", "TV"
        public string Marca { get; set; }
        public string Modelo { get; set; }
        public string? IMEI { get; set; }
        public string? Serie { get; set; }

        // Origen/Destino
        public int? TiendaOrigenId { get; set; }      // 🔥 NUEVO
        public string? TiendaOrigen { get; set; }
        public int? TiendaDestinoId { get; set; }     // 🔥 NUEVO
        public string? TiendaDestino { get; set; }

        // Venta
        public decimal? MontoVenta { get; set; }
        public string? Observacion { get; set; }
        public string? UsuarioRegistro { get; set; }
    }
}