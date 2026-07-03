using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class ReporteDTO
    {
        // ===== CLIENTE =====
        public int ClienteId { get; set; }
        public string CodigoUnico { get; set; }
        public string NombreCliente { get; set; }
        public string Cedula { get; set; }
        public string TelefonoCliente { get; set; }
        public string DireccionCliente { get; set; }
        public string FotoClienteUrl { get; set; }

        // ===== TIENDA =====
        public int? TiendaId { get; set; }
        public string NombreTienda { get; set; }
        public string EncargadoTienda { get; set; }
        public string TelefonoTienda { get; set; }

        public string? Comentario { get; set; }

        public decimal ValorComision { get; set; }
        public string Direccion { get; set; }
        // ===== CRÉDITO =====
        public int CreditoId { get; set; }
        public string NombrePropietario { get; set; }
        public string Imai { get; set; }
        public string Marca { get; set; }
        public string Modelo { get; set; }
        public string FotoContrato { get; set; }

        public string FotoCelularEntregadoUrl { get; set; }

        public decimal Capacidad { get; set; }

        public decimal Entrada { get; set; }
        public decimal MontoTotal { get; set; }
        public decimal MontoPendiente { get; set; }
        public int PlazoCuotas { get; set; }
        public string FrecuenciaPago { get; set; }
        public decimal ValorPorCuota { get; set; }
        public DateTime ProximaCuota { get; set; }
        public string EstadoCredito { get; set; }

        public string EstadoCuota { get; set; }
        public decimal AbonadoTotal { get; set; }

        public decimal AbonadoCuota { get; set; }
        public string EstadoDeComision { get; set; }


        // ===== FECHAS =====
        public string FechaCreditoStr { get; set; }



    }
}
