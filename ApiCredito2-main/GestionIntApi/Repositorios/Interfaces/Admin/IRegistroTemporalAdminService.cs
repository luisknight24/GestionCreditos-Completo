using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;

namespace GestionIntApi.Repositorios.Interfaces.Admin
{
    public interface IRegistroTemporalAdminService
    {

        void GuardarRegistro(string correo, RegistroTemporalAdmin data);
        RegistroTemporalAdmin ObtenerRegistro(string correo);
        void EliminarRegistro(string correo);
    }
}
