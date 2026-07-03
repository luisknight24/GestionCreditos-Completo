namespace GestionIntApi.DTO.Admin
{
    public class PagoRealizadoDTO
    {
        public int Id { get; set; } // Id del registro de pago
        public int CreditoId { get; set; }
        public decimal MontoPagado { get; set; }
        public string MetodoPago { get; set; }
        public string FechaPagoStr { get; set; } // Formateada para el front
        public DateTime FechaPago { get; set; }
        public string NombreCliente { get; set; } // Opcional, por si lo necesitas en el comprobante
    }
}
