namespace GestionIntApi.DTO
{
    public class HistoriaAppDTO
    {
        public int Id { get; set; }// Id del crédito        

        public string ProximaCuotaStr { get; set; }
        public decimal MontoPendiente { get; set; }
        public decimal AbonadoCuota { get; set; }
     
        public string EstadoCuota { get; set; }
        public int ClienteId { get; set; }
        public int? TiendaId { get; set; }
        public int CreditoId { get; set; }// Opcional según necesidad

    }
}
