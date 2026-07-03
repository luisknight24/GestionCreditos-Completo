using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class DetalleClienteDTO
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "El número de cédula es obligatorio")]
        [StringLength(10, MinimumLength = 10, ErrorMessage = "La cédula debe tener exactamente 10 dígitos")]
        public string NumeroCedula { get; set; }


        [Required(ErrorMessage = "Los nombres y apellidos son obligatorios")]
        public string NombreApellidos { get; set; }

      

        [Required(ErrorMessage = "El teléfono es obligatorio")]
        [StringLength(10, MinimumLength = 7, ErrorMessage = "El teléfono debe tener entre 7 y 10 dígitos")]
        [RegularExpression("^[0-9]+$", ErrorMessage = "El teléfono solo debe contener números")]
        public string Telefono { get; set; }


        [Required(ErrorMessage = "La dirección es obligatoria")]
        public string Direccion { get; set; }





       
    }
}
