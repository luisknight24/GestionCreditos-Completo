using GestionIntApi.Models;
using GestionIntApi.Repositorios.Interfaces;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class RegistroTemporalService : IRegistroTemporalService
    {
        private readonly Dictionary<string, RegistroTemporal> _registros
            = new Dictionary<string, RegistroTemporal>(StringComparer.OrdinalIgnoreCase);

        public void GuardarRegistro(string correo, RegistroTemporal data)
        {
            if (string.IsNullOrWhiteSpace(correo)) return;
            _registros[correo.Trim().ToLower()] = data;
        }

        public RegistroTemporal ObtenerRegistro(string correo)
        {
            if (string.IsNullOrWhiteSpace(correo)) return null;
            var key = correo.Trim().ToLower();

            if (_registros.TryGetValue(key, out var registro))
            {
                // Ver si expiró usando DateTime.UtcNow
                if (registro.Expira < DateTime.UtcNow)
                {
                    _registros.Remove(key);
                    return null;
                }
                return registro;
            }
            return null;
        }

        public void EliminarRegistro(string correo)
        {
            if (string.IsNullOrWhiteSpace(correo)) return;
            var key = correo.Trim().ToLower();
            if (_registros.ContainsKey(key))
            {
                _registros.Remove(key);
            }
        }
    }
}
