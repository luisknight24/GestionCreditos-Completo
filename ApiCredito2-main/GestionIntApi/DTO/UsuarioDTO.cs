using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class UsuarioDTO 
    {
        public int Id { get; set; }
        [Required(ErrorMessage = "El nombre y apellido es obligatorio")]
        [MinLength(3, ErrorMessage = "El nombre debe tener al menos 3 caracteres")]
        public string? NombreApellidos { get; set; }

        [Required(ErrorMessage = "El correo es obligatorio")]
        [EmailAddress(ErrorMessage = "El correo no es válido")]
        public string? Correo { get; set; }
        public int? RolId { get; set; }
        public String? RolDescripcion { get; set; }

        [Required(ErrorMessage = "La clave es obligatoria")]
        [MinLength(6, ErrorMessage = "La clave debe tener mínimo 6 caracteres")]
        public string? Clave { get; set; }
        public int? EsActivo { get; set; }


        public ClienteDTO Cliente { get; set; }
    }
}
