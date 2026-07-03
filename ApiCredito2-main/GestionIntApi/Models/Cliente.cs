namespace GestionIntApi.Models
{
    public class Cliente
    {
        public int Id { get; set; }
        // FK -> Usuario
        public int? UsuarioId { get; set; }
        public Usuario? Usuario { get; set; }
        // Relación con DetallCliente
        public int DetalleClienteID { get; set; }
        public DetalleCliente DetalleCliente { get; set; }

        public ICollection<TiendaApp> TiendaApps { get; set; }

        public ICollection<Credito> Creditos { get; set; }
        ICollection<Notificacion> Notificaciones { get; set; }
    }
}
