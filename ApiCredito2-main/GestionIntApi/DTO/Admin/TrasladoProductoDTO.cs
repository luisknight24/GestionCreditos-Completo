namespace GestionIntApi.DTO.Admin
{
    public class TrasladoProductoDTO
    {
        public int ProductoId { get; set; }
        public int TiendaOrigenId { get; set; }
        public int TiendaDestinoId { get; set; }
        public string? Observacion { get; set; }
        public string UsuarioRegistro { get; set; }
    }
}
