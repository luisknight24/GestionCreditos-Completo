using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class PagoCreditoDTO
    {
        public int CreditoId { get; set; }

        [Required(ErrorMessage = "El monto pagado es obligatorio")]
        [Range(0.01, double.MaxValue, ErrorMessage = "El monto pagado debe ser mayor a 0")]
        public decimal MontoPagado { get; set; }

        public string? MetodoPago { get; set; }
    }
}
