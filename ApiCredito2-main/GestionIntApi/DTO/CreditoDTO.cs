using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class CreditoDTO
    {

        public int Id { get; set; }
        public bool? EsVentaContado { get; set; }



        [Required(ErrorMessage = "La entrada es obligatoria")]
        [Range(0, double.MaxValue, ErrorMessage = "La entrada debe ser un número positivo")]
        public decimal Entrada { get; set; }

        public string? NombrePropietario { get; set; }

        [Required(ErrorMessage = "El monto total es obligatorio")]
        [Range(1, double.MaxValue, ErrorMessage = "El monto total debe ser mayor a 0")]
        public decimal MontoTotal { get; set; }
        // Saldo pendiente después de la entrada
        public decimal MontoPendiente { get; set; }

        [Required(ErrorMessage = "El plazo de cuotas es obligatorio")]
        [Range(1, 120, ErrorMessage = "El plazo de cuotas debe estar entre 1 y 120 meses")]
        public int PlazoCuotas { get; set; }
        public string FrecuenciaPago { get; set; }
        public DateTime DiaPago { get; set; }
       // public string FotoCelularEntregadoUrl { get; set; }
        //public string FotoContrato { get; set; }
        public decimal ValorPorCuota { get; set; }



        public DateTime ProximaCuota { get; set; }
        public string? ProximaCuotaStr { get; set; }
        public string? Estado { get; set; }

        public string? MetodoPago { get; set; }
        public string Marca { get; set; }
        public string Modelo { get; set; }
        public string? IMEI { get; set; }
        public string TipoProducto { get; set; }

        public decimal Capacidad { get; set; }

        public decimal AbonadoTotal { get; set; }

        public decimal AbonadoCuota { get; set; }
        public string EstadoCuota { get; set; }



        public DateTime FechaCreacion { get; set; }
        public int ClienteId { get; set; }

        public int? TiendaAppId { get; set; }
    }
}
