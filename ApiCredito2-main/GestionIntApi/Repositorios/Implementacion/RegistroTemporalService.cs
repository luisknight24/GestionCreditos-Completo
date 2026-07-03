using GestionIntApi.Models;
using GestionIntApi.Repositorios.Interfaces;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class RegistroTemporalService : IRegistroTemporalService
    {
        private readonly Dictionary<string, RegistroTemporal> _registros
            = new Dictionary<string, RegistroTemporal>();

        public void GuardarRegistro(string correo, RegistroTemporal data)
        {
            _registros[correo] = data;
        }

        public RegistroTemporal ObtenerRegistro(string correo)
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
