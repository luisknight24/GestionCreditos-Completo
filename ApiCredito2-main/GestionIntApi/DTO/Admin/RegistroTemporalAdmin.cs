namespace GestionIntApi.DTO.Admin
{
    public class RegistroTemporalAdmin
    {
        public UsuarioAdminDTO UsuarioAdmin { get; set; }
        public string Codigo { get; set; }
        public DateTime Expira { get; set; } = DateTime.Now.AddMinutes(10);
    }
}
