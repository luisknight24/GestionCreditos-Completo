namespace GestionIntApi.Models
{
    public class RegistrarPago
    {
        public int Id { get; set; }
        public int CreditoId { get; set; }
        public Credito Credito { get; set; }
        public decimal MontoPagado { get; set; }
        public string MetodoPago { get; set; } // "Efectivo" o "Transferencia"
        public DateTime FechaPago { get; set; }
    }
}
