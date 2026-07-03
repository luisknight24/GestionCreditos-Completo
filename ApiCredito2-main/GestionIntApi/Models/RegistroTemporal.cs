using GestionIntApi.DTO;

namespace GestionIntApi.Models
{
    public class RegistroTemporal
    {
        public UsuarioDTO Usuario { get; set; }
        public string Codigo { get; set; }
        public DateTime Expira { get; set; } = DateTime.Now.AddMinutes(10);
    }
}
