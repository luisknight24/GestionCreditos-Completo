namespace GestionIntApi.Models
{
    public class RegistroRequest
    {
        public string NombreApellidos { get; set; }
        public string Correo { get; set; }
        public string Clave { get; set; }
        public int RolId { get; set; }
        public string Codigo { get; set; }
    }
}
