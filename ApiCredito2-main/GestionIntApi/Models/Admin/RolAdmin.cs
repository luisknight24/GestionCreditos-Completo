namespace GestionIntApi.Models.Admin
{
    public class RolAdmin
    {
        public int Id { get; set; }
        public string? Descripcion { get; set; }
        public DateTime? FechaRegistro { get; set; }
        public ICollection<UsuarioAdmin> UsuarioAdmins { get; set; } = new List<UsuarioAdmin>();
        public ICollection<MenuRolAdmin> MenuRolAdmins { get; set; } = new List<MenuRolAdmin>();
    }
}
