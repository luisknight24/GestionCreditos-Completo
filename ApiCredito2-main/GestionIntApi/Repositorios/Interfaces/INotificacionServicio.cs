using GestionIntApi.DTO;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface INotificacionServicio
    {
        Task GenerarNotificaciones();
        Task<List<NotificacionDTO>> GetNotificaciones();
       
        Task MarcarComoLeida(int clienteID, int notificacionId);
        Task<bool> MarcarComoLeida1(int notificacionId);
    }





}
