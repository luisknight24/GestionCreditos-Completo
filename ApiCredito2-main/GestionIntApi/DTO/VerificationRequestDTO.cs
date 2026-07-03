namespace GestionIntApi.DTO
{
    public class VerificationRequestDTO
    {
        public string Correo { get; set; }
        public string Codigo { get; set; }
        public UsuarioDTO? Usuario { get; set; }
    }
}
