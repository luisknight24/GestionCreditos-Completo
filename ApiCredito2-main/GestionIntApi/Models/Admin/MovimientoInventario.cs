using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.Models.Admin
{
    public class MovimientoInventario
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(20)]
        public string TipoMovimiento { get; set; }
        // VALORES: ENTRADA | SALIDA | TRASLADO | VENTA | DEVOLUCION | AJUSTE

        public DateTime FechaMovimiento { get; set; } = DateTime.Now;

        // 🔥 Producto involucrado
        public int ProductoId { get; set; }
        public Producto Producto { get; set; }

        // 🔥 Tienda de ORIGEN (nullable para entradas)
        public int? TiendaOrigenId { get; set; }
        public Tienda? TiendaOrigen { get; set; }

        // 🔥 Tienda de DESTINO (nullable para salidas/ventas)
        public int? TiendaDestinoId { get; set; }
        public Tienda? TiendaDestino { get; set; }

        [MaxLength(500)]
        public string? Observacion { get; set; }

        [MaxLength(100)]
        public string? UsuarioRegistro { get; set; } // Quién hizo el movimiento

        public decimal? MontoVenta { get; set; } // Solo si es VENTA
    }
}
