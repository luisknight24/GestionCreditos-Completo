using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Interfaces.Admin;

namespace GestionIntApi.Repositorios.Implementacion.Admin
{
    public class RegistroTemporalAdminService: IRegistroTemporalAdminService
    {

        private readonly Dictionary<string, RegistroTemporalAdmin> _registros
            = new Dictionary<string, RegistroTemporalAdmin>();

        public void GuardarRegistro(string correo, RegistroTemporalAdmin data)
        {
            _registros[correo] = data;
        }

        public RegistroTemporalAdmin ObtenerRegistro(string correo)
        {
            if (_registros.TryGetValue(correo, out var registro))
            {
                // Ver si expiró
                if (registro.Expira < DateTime.Now)
                {
                    _registros.Remove(correo);
                    return null;
                }
                return registro;
            }
            return null;
        }

        public void EliminarRegistro(string correo)
        {
            if (_registros.ContainsKey(correo))
            {
                _registros.Remove(correo);
            }
        }
    }
}
