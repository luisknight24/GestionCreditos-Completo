namespace GestionIntApi.Models.Admin
{
    public class MenuRolAdmin
    {
        public int Id { get; set; }
        public int? MenuAdminId { get; set; }
        public int? RolAdminId { get; set; }
        public MenuAdmin? MenuAdmin { get; set; }
        public RolAdmin? RolAdmin { get; set; }
    }
}
