using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class TiendaAdminDTO
    {
        public int Id { get; set; }

        [Required]
        public string NombreTienda { get; set; }

        [Required]
        public string NombreEncargado { get; set; }

        [Required]
        public string CedulaEncargado { get; set; }


        public string? Comentario { get; set; }

        public decimal ValorComision { get; set; }

        public string Telefono { get; set; }
        public string Direccion { get; set; }

        public DateTime FechaRegistro { get; set; }
    }
}
