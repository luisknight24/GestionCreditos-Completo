using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class ClienteIdProvider_cs : IUserIdProvider
    {
        public string GetUserId(HubConnectionContext connection)
        {
            // Busca el claim ClienteId en el token JWT
            var clienteId = connection.User?.FindFirst("ClienteId")?.Value;

            if (string.IsNullOrEmpty(clienteId))
            {
                // Opcional: fallback a NameIdentifier
                clienteId = connection.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            }

            return clienteId;
        }
    }
}
