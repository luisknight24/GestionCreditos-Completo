using Microsoft.AspNetCore.Mvc;

namespace GestionIntApi.DTO
{
    public class SesionDTO 
    {
        public int Id { get; set; }
        public string? NombreApellidos { get; set; }
        public string? Correo { get; set; }
        public String? RolDescripcion { get; set; }

        public string Token { get; set; }
    }
}
