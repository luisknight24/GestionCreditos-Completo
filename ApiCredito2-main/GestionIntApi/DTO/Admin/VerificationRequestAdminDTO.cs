namespace GestionIntApi.DTO.Admin
{
    public class VerificationRequestAdminDTO
    {
        public string Correo { get; set; }
        public string Codigo { get; set; }
        public UsuarioAdminDTO? usuarioAdmin { get; set; }
    }
}
