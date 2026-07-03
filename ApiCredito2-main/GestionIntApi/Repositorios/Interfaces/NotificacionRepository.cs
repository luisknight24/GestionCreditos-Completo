using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;

namespace GestionIntApi.Repositorios.Interfaces
{
    public class NotificacionRepository : GenericRepository<Notificacion>, INotificacionRepository
    {
        public NotificacionRepository(SistemaGestionDBcontext context) : base(context)
        {
        }
    }
}
