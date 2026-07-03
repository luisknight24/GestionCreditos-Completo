using GestionIntApi.Models;
using System.Text.Json.Serialization;

namespace GestionIntApi.DTO
{
    public class ClienteDTO
    {
        public int Id { get; set; }

        public int? UsuarioId { get; set; }
// public UsuarioDTO Usuario { get; set; }

        public int DetalleClienteID { get; set; }
        public DetalleClienteDTO DetalleCliente { get; set; }

        public List<TiendaAppDTO> TiendaApps { get; set; }
        


        public List<CreditoDTO> Creditos { get; set; }
    }
}
