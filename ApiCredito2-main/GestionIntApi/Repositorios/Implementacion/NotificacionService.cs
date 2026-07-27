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
            var creditos = listaCreditos.Where(c => c.MontoPendiente > 0 && c.Estado != "Pagado").ToList();
            var hoy = DateTime.Now.Date;

            foreach (var credito in creditos)
            {
                var proximaCuota = credito.ProximaCuota.Date;
                int diasDiferencia = (proximaCuota - hoy).Days;

                if (diasDiferencia == 5)
                {
                    if (!await ExisteNotificacionHoy(credito.ClienteId, "Recordatorio5Dias"))
                    {
                        await CrearNotificacion(
                            credito.ClienteId,
                            "Recordatorio5Dias",
                            $"Recordatorio: Faltan 5 días para la fecha de pago de tu cuota de ${credito.ValorPorCuota:F2} ({credito.ProximaCuota:dd/MM/yyyy})."
                        );
                    }
                }
                else if (diasDiferencia == 3)
                {
                    if (!await ExisteNotificacionHoy(credito.ClienteId, "Recordatorio3Dias"))
                    {
                        await CrearNotificacion(
                            credito.ClienteId,
                            "Recordatorio3Dias",
                            $"Recordatorio: Faltan 3 días para el vencimiento de tu cuota de ${credito.ValorPorCuota:F2}."
                        );
                    }
                }
                else if (diasDiferencia == 2)
                {
                    if (!await ExisteNotificacionHoy(credito.ClienteId, "Recordatorio2Dias"))
                    {
                        await CrearNotificacion(
                            credito.ClienteId,
                            "Recordatorio2Dias",
                            $"Recordatorio: Faltan 2 días para el vencimiento de tu cuota de ${credito.ValorPorCuota:F2}."
                        );
                    }
                }
                else if (diasDiferencia == 0)
                {
                    if (!await ExisteNotificacionHoy(credito.ClienteId, "PagoHoy"))
                    {
                        await CrearNotificacion(
                            credito.ClienteId,
                            "PagoHoy",
                            $"¡Hoy es tu día de pago! Recuérdalo para mantener tu crédito al día (${credito.ValorPorCuota:F2})."
                        );
                    }
                }
                else if (diasDiferencia < 0)
                {
                    int diasAtraso = Math.Abs(diasDiferencia);
                    if (!await ExisteNotificacionHoy(credito.ClienteId, "Moroso"))
                    {
                        await CrearNotificacion(
                            credito.ClienteId,
                            "Moroso",
                            $"Atención: Tu cuota tiene {diasAtraso} día(s) de atraso. Regulariza tu saldo de ${credito.ValorPorCuota:F2} para evitar recargos."
                        );
                    }
                }
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

            var dto = _mapper.Map<NotificacionDTO>(notificacion);

            if (_hubContext != null)
            {
                try
                {
                    Console.WriteLine($"Enviando notificación por SignalR a cliente {clienteId}");
                    Console.WriteLine($"Tipo: {tipo} | Mensaje: {mensaje}");

                    await _hubContext.Clients.User(clienteId.ToString())
     .SendAsync("NotificacionActualizado", dto);

                    Console.WriteLine($"Notificación enviada por SignalR exitosamente");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error enviando notificación SignalR: {ex.Message}");
                    Console.WriteLine($"Stack: {ex.StackTrace}");
                }
            }
            else
            {
                Console.WriteLine("_hubContext es NULL, no se puede enviar SignalR");
            }
        }

        public async Task<List<NotificacionDTO>> GetNotificaciones()
        {
            var query = await _notificacionRepository.Consultar();
            var ordenadas = query.OrderByDescending(n => n.Fecha).ToList();
            return _mapper.Map<List<NotificacionDTO>>(ordenadas);
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
                    Console.WriteLine($"Error enviando notificación SignalR: {ex.Message}");
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
