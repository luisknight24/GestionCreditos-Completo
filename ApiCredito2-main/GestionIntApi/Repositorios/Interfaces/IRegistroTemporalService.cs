using GestionIntApi.Models;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface IRegistroTemporalService
    {
        void GuardarRegistro(string correo, RegistroTemporal data);
        RegistroTemporal ObtenerRegistro(string correo);
        void EliminarRegistro(string correo);
    }
}
