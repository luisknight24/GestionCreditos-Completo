using GestionIntApi.Models.Admin;

namespace GestionIntApi.Models
{
    public class Tienda
    {
        public int Id { get; set; }

        public string NombreTienda { get; set; }
        public string Direccion { get; set; }

        public string NombreEncargado { get; set; }
        public string CedulaEncargado { get; set; }   // ÚNICA
        public string Telefono { get; set; }

        public string? Comentario { get; set; }

        public decimal ValorComision { get; set; }

        public DateTime FechaRegistro { get; set; } = DateTime.Now;

        // Navegación
        public ICollection<TiendaApp> TiendaApps { get; set; } = new List<TiendaApp>();
        public ICollection<Producto> ProductosActuales { get; set; } = new List<Producto>();
    }
}
