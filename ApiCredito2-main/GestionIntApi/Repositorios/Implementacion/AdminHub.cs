using Microsoft.AspNetCore.SignalR;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class AdminHub : Hub

    {



        // Opcional: aquí puedes agregar métodos que el cliente pueda invocar
        // Por ejemplo, si quieres que el admin pueda enviar mensajes manualmente

        public async Task EnviarMensajeAlCliente(string clienteId, string mensaje)
        {
            await Clients.User(clienteId).SendAsync("RecibirMensaje", mensaje);
            Console.WriteLine("✅ Evento SignalR enviado correctamente");
        }

        // Puedes sobrescribir métodos de conexión si quieres controlar la conexión
        public override async Task OnConnectedAsync()
        {
            // Opcional: log de conexión
            var clienteId = Context.User?.FindFirst("ClienteId")?.Value;
            Console.WriteLine($"🔌 Cliente conectado | ConnectionId: {Context.ConnectionId}");
            Console.WriteLine($"🔑 ClienteId del token: {clienteId}");
            if (!string.IsNullOrEmpty(clienteId))
            {
                await Groups.AddToGroupAsync(
                    Context.ConnectionId,
                    $"cliente-{clienteId}"
                );
                Console.WriteLine($"👥 Agregado al grupo: cliente-{clienteId}");
            }
            else
            {

                Console.WriteLine("⚠️ ClienteId NULL → NO agregado a grupo");

            }
    
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception exception)
        {
            // Opcional: log de desconexión
            await base.OnDisconnectedAsync(exception);
        }
    }








}
