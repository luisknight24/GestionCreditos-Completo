namespace GestionIntApi.DTO
{
    public class CreditoMostrarDTO
    {
        public int Id { get; set; }
        public decimal MontoTotal { get; set; }// Id del crédito        
        public decimal MontoPendiente { get; set; }
        public string FechaCreditoStr { get; set; }
        public decimal Entrada { get; set; }
        public string ProximaCuotaStr { get; set; }
        public int PlazoCuotas { get; set; }
        public decimal ValorPorCuota { get; set; }
        public string Estado { get; set; }

        public string Marca { get; set; }
        public string Modelo { get; set; }
        public decimal AbonadoTotal { get; set; }

        public decimal AbonadoCuota { get; set; }
        public string EstadoCuota { get; set; }
        public int ClienteId { get; set; }
        public int? TiendaAppId { get; set; }// Opcional según necesidad
    }

}
