using GestionIntApi.Models;
using GestionIntApi.Models.Admin;

namespace GestionIntApi.DTO.Admin
{
    public class UsuarioAdminDTO
    {
        public int Id { get; set; }
        public string? NombreApellidos { get; set; }
        public string? Correo { get; set; }
        public int? RolAdminId { get; set; }
        public string? Clave { get; set; }
        public String? RolDescripcion { get; set; }
        public int? EsActivo { get; set; }


    }
}
