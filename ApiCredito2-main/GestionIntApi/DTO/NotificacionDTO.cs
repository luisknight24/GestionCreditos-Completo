namespace GestionIntApi.DTO
{
    public class NotificacionDTO
    {
        public int Id { get; set; }
        public int ClienteId { get; set; }
        public string Tipo { get; set; }
        public string Mensaje { get; set; }
        public DateTime Fecha { get; set; }
        public bool Leida { get; set; } = false;
    }
}
