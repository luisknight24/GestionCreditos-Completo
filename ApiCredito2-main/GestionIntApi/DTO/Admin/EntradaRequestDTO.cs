namespace GestionIntApi.DTO.Admin
{
    public class EntradaRequestDTO
    {
        public int ProductoId { get; set; }
        public int TiendaDestinoId { get; set; }
        public string? Observacion { get; set; }
    }
}
