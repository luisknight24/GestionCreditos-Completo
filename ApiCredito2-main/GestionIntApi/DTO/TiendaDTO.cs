using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class TiendaDTO
    {


        public int Id { get; set; }


        [Required(ErrorMessage = "El nombre de la tienda es obligatorio")]
        public string NombreTienda { get; set; }


        [Required(ErrorMessage = "El nombre de la tienda es obligatorio")]
        public string NombreEncargado { get; set; }


        [Required(ErrorMessage = "El nombre de la tienda es obligatorio")]
        public string Telefono { get; set; }


        [Required(ErrorMessage = "El nombre de la tienda es obligatorio")]
        public string Direccion { get; set; }


        public string? Comentario { get; set; }

        public decimal ValorComision { get; set; }



        [Required(ErrorMessage = "El nombre de la tienda es obligatorio")]
        public DateTime FechaRegistro { get; set; }

        public int ClienteId { get; set; }
    }
}
