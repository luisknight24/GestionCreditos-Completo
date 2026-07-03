using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;


namespace GestionIntApi.Repositorios.Implementacion
{
    

    public class NotificacionService: INotificacionServicio
    {

        private readonly IGenericRepository<Credito> _CreditoRepositorio;
        private readonly INotificacionRepository _notificacionRepository;
        private readonly IMapper _mapper;
        private readonly IHubContext<AdminHub> _hubContext;
        public NotificacionService(IGenericRepository<Credito> CreditoRepositorio,
                           INotificacionRepository notificacionRepository,
                           IMapper mapper,
                           IHubContext<AdminHub> hubContext)
        {
            _CreditoRepositorio = CreditoRepositorio;
            _notificacionRepository = notificacionRepository;
            _mapper = mapper;
            _hubContext = hubContext;
        }


        public async Task GenerarNotificaciones()
        {
            var listaCreditos = await _CreditoRepositorio.Consultar();
            var creditos = listaCreditos.ToList();
            var hoy = DateTime.Now.Date;
            foreach (var credito in creditos)
            {
                var proximaCuota = credito.ProximaCuota.Date;

                // 1. PAGO MAÑANA
                if (credito.ProximaCuota.Date == DateTime.Now.AddDays(182).Date)
                {
                    if (!await ExisteNotificacionHoy(credito.Id, "PagoMañana")) {

                        await CrearNotificacion(credito.ClienteId, "PagoMañana",
                            $"El cliente debe pagar mañana: {credito.ProximaCuota:dd/MM/yyyy}");

                    }
                }

                // 2. CUOTA VENCIDA
                if (credito.ProximaCuota.Date < DateTime.Now.Date)
                {
                    if (!await ExisteNotificacionHoy(credito.Id, "Moroso")) {

                        int diasAtrazo1 = (hoy - proximaCuota).Days;
                        await CrearNotificacion(
                   credito.ClienteId,
                   "Moroso",
                   $"Tiene {diasAtrazo1} día(s) de atraso en el pago."
               );

                    }
                    
                }

                // 3. CLIENTE MOROSO (más de 5 días)
              /*  var diasAtraso = (DateTime.Now.Date - credito.ProximaCuota.Date).Days;

                if (diasAtraso >= 1)
                {
                    await CrearNotificacion(credito.ClienteId, "ClienteMoroso",
                        $"Tiene {diasAtraso} días de atraso en el pago.");
                }
            
                */
                }
        }

        public async Task CrearNotificacion(int clienteId, string tipo, string mensaje)
        {
            var notificacion = new Notificacion
            {
                ClienteId = clienteId,
                Mensaje = mensaje,
                Tipo = tipo,
                Fecha = DateTime.UtcNow
            };

            await _notificacionRepository.Crear(notificacion);

            // 2️⃣ Mapear a DTO
            var dto = _mapper.Map<NotificacionDTO>(notificacion);

            // 3️⃣ 📡 Enviar por SignalR al cliente específico
            if (_hubContext != null)
            {
                try
                {
                    Console.WriteLine($"📤 Enviando notificación por SignalR a cliente {clienteId}");
                    Console.WriteLine($"   Tipo: {tipo} | Mensaje: {mensaje}");

                    await _hubContext.Clients.User(clienteId.ToString())
     .SendAsync("NotificacionActualizado", dto);
     //.SendAsync("NotificacionActualizado", dto);

                    Console.WriteLine($"✅ Notificación enviada por SignalR exitosamente");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"⚠️ Error enviando notificación SignalR: {ex.Message}");
                    Console.WriteLine($"⚠️ Stack: {ex.StackTrace}");
                }
            }
            else
            {
                Console.WriteLine("❌ _hubContext es NULL, no se puede enviar SignalR");
            }
        }

        public async Task<List<NotificacionDTO>> GetNotificaciones()
        {
            var query = await _notificacionRepository.Consultar();
            return _mapper.Map<List<NotificacionDTO>>(query.ToList());
        }


        public async Task MarcarComoLeida(int clienteId, int notificacionId)
        {
            var notificacion = await _notificacionRepository.Obtener(n =>
                n.Id == notificacionId &&
                n.ClienteId == clienteId
            );

            if (notificacion == null)
                throw new Exception("Notificación no encontrada o no tienes permiso");

            notificacion.Leida = true;
            await _notificacionRepository.Editar(notificacion);

            var dto = _mapper.Map<NotificacionDTO>(notificacion);

            // ✅ Verificar que _hubContext no sea null
            if (_hubContext != null)
            {
                try
                {
                    await _hubContext.Clients
                        .User(clienteId.ToString())
                        .SendAsync("NotificacionActualizado", dto);
                }
                catch (Exception ex)
                {
                    // Log pero no fallar
                    Console.WriteLine($"⚠️ Error enviando notificación SignalR: {ex.Message}");
                }
            }
        }

        public async Task<bool> MarcarComoLeida1(int notificacionId)
        {
            var notificacion = await _notificacionRepository.Obtener(n => n.Id == notificacionId);
            if (notificacion == null)
                return false; // Notificación no encontrada

            notificacion.Leida = true;
            await _notificacionRepository.Editar(notificacion);

            // Enviar actualización por SignalR si _hubContext no es null
            if (_hubContext != null)
            {
                var dto = _mapper.Map<NotificacionDTO>(notificacion);
                await _hubContext.Clients.All.SendAsync("NotificacionActualizado", dto);
            }

            return true;
        }


        private async Task<bool> ExisteNotificacionHoy(
       int clienteId,
       string tipo
   )
        {
            var hoy = DateTime.UtcNow.Date;

            var query = await _notificacionRepository.Consultar();

            return await query.AnyAsync(n =>
                n.ClienteId == clienteId &&
                n.Tipo == tipo &&
                n.Fecha.Date == hoy
            );
        }

    }
}
