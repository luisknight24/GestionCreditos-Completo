namespace GestionIntApi.Models
{
    public class Usuario
    {


        public int Id { get; set; }
        public string? NombreApellidos { get; set; }
        public string? Correo { get; set; }
        public int? RolId { get; set; }
        public string? Clave { get; set; }
        public bool EsActivo { get; set; } = true;
        public DateTime? FechaRegistro { get; set; }
        public Rol Rol { get; set; }

        public string? PasswordResetToken { get; set; }
        public DateTime? ResetTokenExpires { get; set; }
        public Cliente Cliente { get; set; }



    }
}
