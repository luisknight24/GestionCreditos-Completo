namespace GestionIntApi.Models
{
    public class Notificacion
    {
        public int Id { get; set; }

        // A qué cliente pertenece
        public int ClienteId { get; set; }
        public Cliente Cliente { get; set; }

        // Tipo de notificación: PagoMañana, Vencido, Moroso
        public string Tipo { get; set; }

        // Mensaje que verán en el panel
        public string Mensaje { get; set; }

        // Cuándo fue creada
        public DateTime Fecha { get; set; } = DateTime.Now;

        public bool Leida { get; set; } = false;
    }
}
