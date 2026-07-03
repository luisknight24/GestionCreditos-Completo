namespace GestionIntApi.Models
{
    public class MenuRol
    {

        public int Id { get; set; }
        public int? MenuId { get; set; }
        public int? RolId { get; set; }
        public Menu? Menu { get; set; }
        public Rol? Rol { get; set; }
    }
}
