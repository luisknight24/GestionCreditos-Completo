using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class LoginDTO
    {

        [Required(ErrorMessage = "El correo es obligatorio")]
        [EmailAddress(ErrorMessage = "El formato del correo no es válido")]
        public string? Correo { get; set; }


        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener al menos 8 caracteres")]
        public string? Clave { get; set; }

    }
}
