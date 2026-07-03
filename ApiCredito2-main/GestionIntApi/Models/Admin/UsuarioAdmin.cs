namespace GestionIntApi.Models.Admin
{
    public class UsuarioAdmin
    {

        public int Id { get; set; }
        public string? NombreApellidos { get; set; }
        public string? Correo { get; set; }
        public int? RolAdminId { get; set; }
        public string? Clave { get; set; }
        public bool? EsActivo { get; set; }
        public DateTime? FechaRegistro { get; set; }
        public RolAdmin RolAdmin { get; set; }

        public string? PasswordResetToken { get; set; }
        public DateTime? ResetTokenExpires { get; set; }



    }
}
