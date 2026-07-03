namespace GestionIntApi.Models
{
    public class TiendaApp
    {

        public int Id { get; set; }

        // Relación REAL
        public int TiendaId { get; set; }
        public Tienda Tienda { get; set; }

        // Se usa para buscar / trazabilidad
        public string CedulaEncargado { get; set; }

        public string EstadoDeComision { get; set; }

        public DateTime FechaRegistro { get; set; } = DateTime.Now;

        public int ClienteId { get; set; }
        public Cliente Cliente { get; set; }
    }
}
