namespace GestionIntApi.Models
{
    public class Credito
    {

        public int Id { get; set; }


        public bool? EsVentaContado { get; set; }

    

        // Valor total del celular
        public decimal MontoTotal { get; set; }
        public string? NombrePropietario { get; set; }
        public decimal MontoPendiente { get; set; }
        public decimal Entrada { get; set; }
        public int PlazoCuotas { get; set; }
        public string FrecuenciaPago { get; set; } // semanal, quincenal, mensual
        public DateTime DiaPago { get; set; }

        public decimal ValorPorCuota { get; set; }
        public decimal TotalPagar { get; set; }
        public DateTime ProximaCuota { get; set; }

        public string Estado { get; set; }
     //   public string FotoCelularEntregadoUrl { get; set; }
      //  public string FotoContrato { get; set; }
        public string Marca { get; set; }
        public string Modelo { get; set; }
        public string TipoProducto { get; set; }
        public decimal Capacidad { get; set; }
        public string? IMEI { get; set; }
        public decimal AbonadoTotal  { get; set; }

        public decimal AbonadoCuota { get; set; }
        public string EstadoCuota { get; set; }

        public string? MetodoPago { get; set; }

        public DateTime FechaCreacion { get; set; }

        // FK a Cliente
        public int ClienteId { get; set; }
        public Cliente Cliente { get; set; }

        public int? TiendaAppId { get; set; }
        public TiendaApp TiendaApp { get; set; }
        // public ICollection<Cliente> Clientes { get; set; }

        public ICollection<RegistrarPago> RegistrosPagos { get; set; }
    }
}
