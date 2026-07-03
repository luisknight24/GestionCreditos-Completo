using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class TiendaMostrarAppDTO
    {

        public int Id { get; set; }
        public string NombreEncargado { get; set; }
        public string Telefono { get; set; }
        public int ClienteId { get; set; }
  

    }
}
