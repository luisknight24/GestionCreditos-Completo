using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.Models
{
    public class Ubicacion
    {
       
        public int Id { get; set; }

        [Required]
        public int UsuarioId { get; set; } // viene del JWT

        [Required]
        public double Latitud { get; set; }

        [Required]
        public double Longitud { get; set; }

        public DateTime Fecha { get; set; } = DateTime.UtcNow;
    }
}
