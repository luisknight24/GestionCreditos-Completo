namespace GestionIntApi.Models
{
    public class VerificationCode
    {

        public int Id { get; set; }
        public string Correo { get; set; }
        public string Codigo { get; set; }
        public DateTime Expira { get; set; }
    }
}
