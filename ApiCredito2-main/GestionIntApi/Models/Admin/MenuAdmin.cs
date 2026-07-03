namespace GestionIntApi.Models.Admin
{
    public class MenuAdmin
    {


        public int Id { get; set; }
        public string? Nombre { get; set; }
        public string? Icono { get; set; }
        public string? Url { get; set; }
        public ICollection<MenuRolAdmin> MenuRolAdmins { get; set; }
    }
}
