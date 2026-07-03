using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class ClienteMostrarAppDTO
    {
        public int Id { get; set; }

       
        public string NombreApellidos { get; set; }
        public string? Correo { get; set; }

        public int UsuarioId { get; set; }
    }
}
