using AutoMapper;
using DocumentFormat.OpenXml.Drawing;
using DocumentFormat.OpenXml.Spreadsheet;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class CreditoService: ICreditoService
    {


        private readonly IGenericRepository<Credito> _creditoRepository;

        private readonly IMapper _mapper;
        private readonly SistemaGestionDBcontext _context;
        private readonly IHubContext<AdminHub> _hubContext;
     

        public CreditoService(IHubContext<AdminHub> hubContext, IGenericRepository<Credito> creditoRepository, IMapper mapper, SistemaGestionDBcontext context)
        {

            _creditoRepository = creditoRepository;
            _mapper = mapper;
            _context = context;
            _hubContext = hubContext;

        }



        public async Task<List<CreditoDTO>> GetAllTiendas()
        {
            try
            {
                var queryCredito = await _creditoRepository.Consultar();

                var CreditoCliente = queryCredito.ToList();
                // Recorremos la lista de usuarios y reemplazamos el hash de la contraseña por el texto plano
                return _mapper.Map<List<CreditoDTO>>(CreditoCliente);
            }
            catch
            {

                throw;
            }



        }
        public async Task<CreditoDTO> GetTiendaById(int id)
        {
            try
            {
                var creditoEncontrado = await _creditoRepository.Obtener(u => u.Id == id);


                if (creditoEncontrado == null)
                    throw new TaskCanceledException("Credito de cliente no encontrado");
                return _mapper.Map<CreditoDTO>(creditoEncontrado);
            }
            catch
            {
                throw;
            }
        }

        /* int totalCuotas = modelo.FrecuenciaPago.ToLower() switch
 {
     "semanal" => modelo.PlazoCuotas * 4,
     "quincenal" => modelo.PlazoCuotas * 2,
     "mensual" => modelo.PlazoCuotas,
     _ => throw new Exception("Frecuencia de pago inválida")
 };*/



        public async Task<CreditoDTO> CreateCredito(CreditoDTO modelo)
        {
            try
            {

                // =============================
                // 1. VALIDAR SI CLIENTE TIENE CRÉDITO ACTIVO
                // =============================

                var creditoActual = await _creditoRepository.Obtener(
                    c => c.ClienteId == modelo.ClienteId && c.MontoPendiente > 0
                );

                //   if (creditoActual != null)
                // {
                //   throw new Exception("El cliente aún tiene un crédito activo pendiente. Debe saldarlo antes de crear uno nuevo.");
                // }

                // ==========================================
                // 🔥 NUEVA LÓGICA: PAGO AL CONTADO
                // ==========================================
                bool esAlContado = modelo.MetodoPago?.ToLower() == "al contado";

                if (esAlContado)
                {
                    modelo.Entrada = modelo.MontoTotal; // La entrada es el 100%
                    modelo.PlazoCuotas = 1;             // Se registra como 1 sola cuota
                    modelo.FrecuenciaPago = "Unico";
                }


                // Validaciones básicas
                if (modelo.MontoTotal <= 0)
                    throw new ArgumentException("El monto total debe ser mayor a cero.");

                if (modelo.Entrada < 0)
                    throw new ArgumentException("La entrada no puede ser negativa.");

                if (modelo.Entrada > modelo.MontoTotal)
                    throw new ArgumentException("La entrada no puede ser mayor al monto total del celular.");

                if (modelo.PlazoCuotas <= 0)
                    throw new ArgumentException("El plazo de cuotas debe ser mayor a cero.");

                // Cálculo del TotalPagar (sin intereses)
                // modelo.MontoPendiente = modelo.MontoTotal-modelo.Entrada;
                // 3️⃣ Monto pendiente real
                modelo.MontoPendiente = Math.Round(
                    modelo.MontoTotal - modelo.Entrada, 2
                );




                // 3. Si es al contado, forzamos valores de crédito finalizado
                if (esAlContado || modelo.MontoPendiente <= 0)
                {
                    modelo.MontoPendiente = 0;
                    modelo.ValorPorCuota = 0;
                    modelo.AbonadoTotal = modelo.MontoTotal;
                    modelo.AbonadoCuota = 0;
                    modelo.Estado = "Pagado";
                    modelo.EstadoCuota = "Pagada";
                    modelo.ProximaCuota = DateTime.UtcNow; // Fecha de hoy como cierre
                }
                else
                {


                    int totalCuotas = modelo.PlazoCuotas;

                    // =============================
                    // 5. VALOR POR CUOTA REAL
                    // =============================

                    // 4️⃣ Valor por cuota BASE (NO PROBLEMA)
                    decimal valorBase = Math.Floor(
                        (modelo.MontoPendiente / totalCuotas) * 100
                    ) / 100;

                    //modelo.ValorPorCuota = valorBase;
                    //modelo.ValorPorCuota = valorBase > 0 ? valorBase : modelo.MontoPendiente;
                    modelo.ValorPorCuota = Math.Round(
                      modelo.MontoPendiente / totalCuotas, 2
                   );
                    // Cálculo de ValorPorCuota
                    //  modelo.ValorPorCuota = modelo.MontoPendiente / modelo.PlazoCuotas;


                    // 🔥 NUEVO: Guardar día original para pagos mensuales
                    int diaOriginal = modelo.DiaPago.Day;
                    // Cálculo de PróximaCuota según frecuencia
                    /*   modelo.ProximaCuota = modelo.FrecuenciaPago.ToLower() switch
                      {
                         "semanal" => modelo.DiaPago.AddDays(7),
                          "quincenal" => modelo.DiaPago.AddDays(15),
                          "mensual" => modelo.DiaPago.AddMonths(1),
                          _ => modelo.DiaPago






                } */
                    ;

                    // 🔥 ACTUALIZADO: Cálculo de PróximaCuota según frecuencia
                    switch (modelo.FrecuenciaPago.ToLower())
                    {
                        case "semanal":
                            modelo.ProximaCuota = modelo.DiaPago.AddDays(7);
                            break;
                        case "quincenal":
                            modelo.ProximaCuota = modelo.DiaPago.AddDays(15);
                            break;
                        case "mensual":
                            // 🔥 NUEVO: Manejo correcto de fechas mensuales
                            var nuevaFecha = modelo.DiaPago.AddMonths(1);
                            int ultimoDia = DateTime.DaysInMonth(nuevaFecha.Year, nuevaFecha.Month);
                            int diaFinal = Math.Min(diaOriginal, ultimoDia);
                            modelo.ProximaCuota = new DateTime(
                                nuevaFecha.Year,
                                nuevaFecha.Month,
                                diaFinal,
                                modelo.DiaPago.Hour,
                                modelo.DiaPago.Minute,
                                modelo.DiaPago.Second,
                                DateTimeKind.Utc
                            );
                            break;
                        default:
                            modelo.ProximaCuota = modelo.DiaPago;
                            break;
                    }





                    // =============================
                    // 6. Inicializar propiedades de pagos
                    // =============================
                    // =============================

                    modelo.AbonadoCuota = 0;        // cuota actual
                    modelo.AbonadoTotal = modelo.Entrada;   // total del crédito
                    modelo.EstadoCuota = "Pendiente";
                    // =============================
                    // 5. Actualizar estado
                    // =============================
                    modelo.Estado = modelo.MontoPendiente <= 0 ? "Pagado" : "Pendiente";

                }
                var UsuarioCreado = await _creditoRepository.Crear(_mapper.Map<Credito>(modelo));



                // 🔥 OPCIONAL: Registrar el pago inicial en tu tabla de historial de pagos
                if (modelo.Entrada > 0)
                {
                    var registroPago = new RegistrarPago
                    {
                        CreditoId = UsuarioCreado.Id,
                        MontoPagado = modelo.Entrada,
                        MetodoPago = modelo.MetodoPago ?? "Efectivo",
                        FechaPago = DateTime.UtcNow
                    };
                    _context.RegistrosPagos.Add(registroPago);
                    await _context.SaveChangesAsync();
                }





                if (UsuarioCreado.Id == 0)
                    throw new TaskCanceledException("No se pudo crear la tienda");

                return _mapper.Map<CreditoDTO>(UsuarioCreado);
            }
            catch
            {
                throw;
            }
        }

        public async Task<bool> UpdateCredito(CreditoDTO modelo)
        {
            try
            {


                var TiendaModelo = _mapper.Map<CreditoDTO>(modelo);

                var TiendaEncontrado = await _creditoRepository.Obtener(u => u.Id == TiendaModelo.Id);
                if (TiendaEncontrado == null)
                    throw new TaskCanceledException("El credito no existe");

                // Recalcular saldo pendiente y valor por cuota
                TiendaEncontrado.MontoPendiente = modelo.MontoTotal - modelo.Entrada;
                TiendaEncontrado.ValorPorCuota = TiendaEncontrado.MontoPendiente / modelo.PlazoCuotas;

                modelo.ProximaCuota = modelo.FrecuenciaPago.ToLower() switch
                {
                    "semanal" => modelo.DiaPago.AddDays(7),
                    "quincenal" => modelo.DiaPago.AddDays(15),
                    "mensual" => modelo.DiaPago.AddMonths(1),
                    _ => modelo.DiaPago
                };

                // Actualizar los campos editables
                TiendaEncontrado.MontoTotal = modelo.MontoTotal;
                TiendaEncontrado.Entrada = modelo.Entrada;
                TiendaEncontrado.PlazoCuotas = modelo.PlazoCuotas;
                TiendaEncontrado.FrecuenciaPago = modelo.FrecuenciaPago;
                TiendaEncontrado.DiaPago = modelo.DiaPago;
               // TiendaEncontrado.FotoCelularEntregadoUrl = modelo.FotoCelularEntregadoUrl;
                //TiendaEncontrado.FotoContrato = modelo.FotoContrato;
                // detalleClienteEncontrado.FotoContrato = DetlleModelo.FotoContrato;


                // 🔥 Recalcular correctamente
                TiendaEncontrado.MontoPendiente = TiendaEncontrado.MontoTotal - TiendaEncontrado.Entrada;

                TiendaEncontrado.ValorPorCuota = TiendaEncontrado.PlazoCuotas > 0
                    ? TiendaEncontrado.MontoPendiente / TiendaEncontrado.PlazoCuotas
                    : 0;

                TiendaEncontrado.ProximaCuota = modelo.FrecuenciaPago.ToLower() switch
                {
                    "semanal" => TiendaEncontrado.DiaPago.AddDays(7),
                    "quincenal" => TiendaEncontrado.DiaPago.AddDays(15),
                    "mensual" => TiendaEncontrado.DiaPago.AddMonths(1),
                    _ => TiendaEncontrado.DiaPago
                };

                bool respuesta = await _creditoRepository.Editar(TiendaEncontrado);
                return respuesta;
            }
            catch
            {
                throw;
            }
        }

        public async Task<List<HistoriaAppDTO>> GetCalendarioPagos1(int creditoId)
        {
            var credito = await _creditoRepository.Obtener(c => c.Id == creditoId);
            if (credito == null)
                throw new Exception("Crédito no encontrado");

            Console.WriteLine($"MontoTotal: {credito.MontoTotal}");
            Console.WriteLine($"Entrada: {credito.Entrada}");
            Console.WriteLine($"MontoPendiente: {credito.MontoPendiente}");
            Console.WriteLine($"ValorPorCuota: {credito.ValorPorCuota}");
            Console.WriteLine($"PlazoCuotas: {credito.PlazoCuotas}");
            Console.WriteLine($"Cálculo: {credito.ValorPorCuota} × {credito.PlazoCuotas} = {credito.ValorPorCuota * credito.PlazoCuotas}");

            var historial = new List<HistoriaAppDTO>();

            // 1️⃣ Registrar entrada
            decimal saldoRestante = credito.MontoTotal - credito.Entrada;

            historial.Add(new HistoriaAppDTO
            {
                Id = credito.Id,
                ClienteId = credito.ClienteId,
                TiendaId = credito.TiendaAppId,
                ProximaCuotaStr = credito.FechaCreacion.ToString("yyyy-MM-dd"),
                AbonadoCuota = credito.Entrada,
                MontoPendiente = Math.Round(saldoRestante, 2),
                EstadoCuota = "Pagado"
            });

            decimal valorCuota = credito.ValorPorCuota;

            // Calcular la primera cuota desde FechaCreacion
            DateTime fecha = credito.FechaCreacion;
            fecha = credito.FrecuenciaPago.ToLower() switch
            {
                "semanal" => fecha.AddDays(7),
                "quincenal" => fecha.AddDays(15),
                "mensual" => fecha.AddMonths(1),
                _ => fecha
            };

            decimal pagoRestante = credito.AbonadoTotal - credito.Entrada;

            // 2️⃣ Generar cuotas restantes
            for (int i = 0; i < credito.PlazoCuotas; i++)
            {
                string estado;

                if (pagoRestante >= valorCuota)
                {
                    estado = "Pagado";
                    pagoRestante -= valorCuota;
                }
                else if (pagoRestante > 0)
                {
                    estado = "Pagado";
                    pagoRestante = 0;
                }
                else
                {
                    estado = "Pendiente";
                }

                bool esUltimaCuota = (i == credito.PlazoCuotas - 1);

                if (esUltimaCuota)
                {
                    // ✅ La última cuota cierra el saldo exacto
                    historial.Add(new HistoriaAppDTO
                    {
                        Id = credito.Id,
                        ClienteId = credito.ClienteId,
                        TiendaId = credito.TiendaAppId,
                        ProximaCuotaStr = fecha.ToString("yyyy-MM-dd"),
                        AbonadoCuota = Math.Round(saldoRestante, 2),
                        MontoPendiente = 0,
                        EstadoCuota = estado
                    });
                }
                else
                {
                    // ✅ Restar cuota y redondear
                    decimal nuevoSaldo = saldoRestante - valorCuota;
                    nuevoSaldo = Math.Round(nuevoSaldo, 2);

                    // ✅ Si el nuevo saldo es menor que la cuota, ajustar
                    if (nuevoSaldo < valorCuota && nuevoSaldo > 0)
                    {
                        // Penúltima cuota: ajustar para que coincida
                        decimal cuotaAjustada = saldoRestante - nuevoSaldo;

                        historial.Add(new HistoriaAppDTO
                        {
                            Id = credito.Id,
                            ClienteId = credito.ClienteId,
                            TiendaId = credito.TiendaAppId,
                            ProximaCuotaStr = fecha.ToString("yyyy-MM-dd"),
                            AbonadoCuota = Math.Round(cuotaAjustada, 2),
                            MontoPendiente = nuevoSaldo,
                            EstadoCuota = estado
                        });
                    }
                    else
                    {
                        // Cuota normal
                        historial.Add(new HistoriaAppDTO
                        {
                            Id = credito.Id,
                            ClienteId = credito.ClienteId,
                            TiendaId = credito.TiendaAppId,
                            ProximaCuotaStr = fecha.ToString("yyyy-MM-dd"),
                            AbonadoCuota = valorCuota,
                            MontoPendiente = nuevoSaldo,
                            EstadoCuota = estado
                        });
                    }

                    saldoRestante = nuevoSaldo;
                }

                fecha = credito.FrecuenciaPago.ToLower() switch
                {
                    "semanal" => fecha.AddDays(7),
                    "quincenal" => fecha.AddDays(15),
                    "mensual" => fecha.AddMonths(1),
                    _ => fecha
                };
            }

            return historial;
        }
        public async Task<bool> UpdateCreditoSoloDatos(CreditoDTO modelo)
        {
            try
            {
                var credito = await _creditoRepository.Obtener(u => u.Id == modelo.Id);
                if (credito == null)
                    throw new TaskCanceledException("El crédito no existe");

                // =============================
                // 🔒 NO TOCAR CAMPOS FINANCIEROS
                // =============================
                // NO modificar:
                // - MontoTotal
                // - Entrada
                // - MontoPendiente
                // - ValorPorCuota
                // - PlazoCuotas
                // - FrecuenciaPago
                // - DiaPago
                // - ProximaCuota
                // - AbonadoTotal
                // - AbonadoCuota

                // =============================
                // ✏️ Campos editables
                // =============================
                credito.Marca = modelo.Marca;
                credito.Modelo = modelo.Modelo;
             //   credito.FotoCelularEntregadoUrl = modelo.FotoCelularEntregadoUrl;
               // credito.FotoContrato = modelo.FotoContrato;

                // =============================
                // 🕒 Recalcular SOLO estado de cuota
                // =============================
                credito.EstadoCuota =
                    DateTime.UtcNow.Date > credito.ProximaCuota.Date
                        ? "Atrasada"
                        : "Pendiente";

                // =============================
                // 💾 Guardar
                // =============================
                bool respuesta = await _creditoRepository.Editar(credito);
                return respuesta;
            }
            catch
            {
                throw;
            }
        }









        public async Task<bool> DeleteCredito(int id)
        {
            try
            {
                var tiendaEncontrado = await _creditoRepository.Obtener(u => u.Id == id);
                if (tiendaEncontrado == null)
                    throw new TaskCanceledException("Tienda no existe");
                bool respuesta = await _creditoRepository.Eliminar(tiendaEncontrado);
                return respuesta;
            }
            catch
            {
                throw;
            }



        }
        public async Task<PagarCreditoDTO> RegistrarPagoAsync(PagoCreditoDTO pago)
        {
            // 1. Buscar el crédito por Id
            var credito = await _creditoRepository.Obtener(u => u.Id == pago.CreditoId);

            if (credito == null)
                throw new Exception("Crédito no encontrado");

            // =============================
            // 2. Normalizar fechas a UTC
            // =============================
            credito.ProximaCuota = DateTime.SpecifyKind(credito.ProximaCuota, DateTimeKind.Utc);
            credito.DiaPago = DateTime.SpecifyKind(credito.DiaPago, DateTimeKind.Utc);

            credito.FechaCreacion = DateTime.SpecifyKind(credito.FechaCreacion, DateTimeKind.Utc);


            // 🔥 NUEVO: Guardar día original para pagos mensuales
            int diaOriginal = credito.DiaPago.Day;


            // =============================
            // 3. Restar monto pagado 
            // =============================
            if (pago.MontoPagado <= 0)
                throw new Exception("El monto pagado debe ser mayor a 0");

            //  if (pago.MontoPagado > credito.MontoPendiente)
            //    throw new Exception(
            //      $"El monto pagado ({pago.MontoPagado}) no puede ser mayor al saldo pendiente ({credito.MontoPendiente})"
            // );

            // 🔑 ÚLTIMA CUOTA – ajuste automático
            if (pago.MontoPagado > credito.MontoPendiente)
            {
                pago.MontoPagado = credito.MontoPendiente;
            }


            credito.MontoPendiente -= pago.MontoPagado;
            credito.AbonadoTotal += pago.MontoPagado;
// total del crédito
            credito.AbonadoCuota += pago.MontoPagado;      // cuota actual


            // if (credito.MontoPendiente < 0)
            //   credito.MontoPendiente = 0; // evitar negativo
            decimal TOLERANCIA = 0.40m;
            if (credito.MontoPendiente > 0 && credito.MontoPendiente <= TOLERANCIA)
            {
                credito.MontoPendiente = 0;
            }
            // =============================
            // Ajustes si ya se pagó completo
            // =============================
            if (credito.MontoPendiente <= 0 && credito.MontoPendiente <= TOLERANCIA)
            {
                credito.MontoPendiente = 0;
              //  credito.ValorPorCuota = 0;
                credito.ProximaCuota = credito.DiaPago; // fecha del último pago
                credito.Estado = "Pagado";
                credito.EstadoCuota = "Pagada";
            }
            else {


                while (credito.AbonadoCuota >= credito.ValorPorCuota && credito.MontoPendiente > 0)
                {
                    //credito.EstadoCuota = "Pagada";
                    credito.AbonadoCuota -= credito.ValorPorCuota;
                    if (credito.ProximaCuota.Year < 2000)
                        credito.ProximaCuota = DateTime.UtcNow;
                    switch (credito.FrecuenciaPago.ToLower())
                    {
                        case "semanal":
                            credito.ProximaCuota = credito.ProximaCuota.AddDays(7);
                            break;
                        case "quincenal":
                            credito.ProximaCuota = credito.ProximaCuota.AddDays(15);
                            break;
                        case "mensual":


                            var nuevaFecha = credito.ProximaCuota.AddMonths(1);
                            int ultimoDia = DateTime.DaysInMonth(nuevaFecha.Year, nuevaFecha.Month);
                            int diaFinal = Math.Min(diaOriginal, ultimoDia);
                            credito.ProximaCuota = new DateTime(
                                nuevaFecha.Year,
                                nuevaFecha.Month,
                                diaFinal,
                                credito.ProximaCuota.Hour,
                                credito.ProximaCuota.Minute,
                                credito.ProximaCuota.Second,
                                DateTimeKind.Utc
                            );
                            //credito.ProximaCuota = credito.ProximaCuota.AddMonths(1);
                            break;
                    }
                    credito.ProximaCuota = DateTime.SpecifyKind(credito.ProximaCuota, DateTimeKind.Utc);
                }

            }

            // =============================
            // 5. Actualizar estado
            // =============================
            credito.Estado = credito.MontoPendiente <= 0 ? "Pagado" : "Pendiente";

            // =============================
            // 7. Estado de la cuota (SOLO Pendiente o Atrasada)
            // =============================


            if (credito.MontoPendiente <= 0) {

                credito.EstadoCuota = "Pagada";
            }
            else {

                credito.EstadoCuota =
                       DateTime.UtcNow.Date > credito.ProximaCuota.Date
                           ? "Atrasada"
                           : "Pendiente";

                // 

            }
              // =============================
            // 6. Guardar cambios en BD
            // =============================
            await _creditoRepository.Editar(credito);

            // 🔥 Cambia de RegistroPago a RegistrarPago
            var registroPago = new RegistrarPago  // ✅ Con "ar"
            {
                CreditoId = pago.CreditoId,
                MontoPagado = pago.MontoPagado,
                MetodoPago = pago.MetodoPago ?? "Efectivo",
                FechaPago = DateTime.UtcNow
            };
            _context.RegistrosPagos.Add(registroPago);
            await _context.SaveChangesAsync();
            // 🔥 FIN NUEVO


            var dto = _mapper.Map<PagarCreditoDTO>(credito);


            // 🔹 Calcular proximaCuotaStr como en GetCreditosClienteApp
            dto.ProximaCuotaStr = credito.ProximaCuota.ToString("dd/MM/yyyy");
            dto.FechaCreditoStr = credito.FechaCreacion.ToString("dd/MM/yyyy");
            if (credito.Estado == "Pagado")
            {
                dto.TiendaId = null;
                dto.NombreTienda = null;
            }


            await _hubContext.Clients.All.SendAsync("CreditoActualizado", dto);
            Console.WriteLine("✅ SignalR SendAsync ejecutado");


            try
            {
                Console.WriteLine($"🔍 Obteniendo calendario para crédito: {pago.CreditoId}");

                // 🔥 Agregamos 'credito.ClienteId' como segundo parámetro
                var calendarioActualizado = await GetCalendarioPagos(pago.CreditoId, credito.ClienteId);

                Console.WriteLine($"📅 Calendario obtenido: {calendarioActualizado.Count} registros");

                var mensaje = new
                {
                    CreditoId = pago.CreditoId,
                    Historial = calendarioActualizado
                };

                // 🛡️ SEGURIDAD: En lugar de 'All', enviamos solo al grupo del cliente
                // El nombre del grupo debe coincidir con el que definas en el Hub (ej. "Cliente_1")
                string nombreGrupo = $"Cliente_{credito.ClienteId}";
                await _hubContext.Clients.Group(nombreGrupo).SendAsync("CalendarioActualizado", mensaje);

                Console.WriteLine($"✅ SignalR CalendarioActualizado enviado al grupo {nombreGrupo}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error en CalendarioActualizado: {ex.Message}");
                Console.WriteLine($"❌ StackTrace: {ex.StackTrace}");
            }

            // =============================
            // 7. Mapear y devolver DTO
            // =============================
            return dto;
        }

     


        public async Task<List<CreditoDTO>> GetCreditosPendientesPorCliente(int clienteId)
        {
            try
            {
                // Consultamos solo los créditos del cliente
                var query = await _creditoRepository.Consultar(c => c.ClienteId == clienteId);

                // Filtramos solamente los pendientes
                var pendientes = query
                    .Where(c => c.MontoPendiente > 0)
                    .ToList();

                // Retornamos en DTO
                return _mapper.Map<List<CreditoDTO>>(pendientes);
            }
            catch
            {
                throw;
            }
        }

        public async Task<List<CreditoMostrarDTO>> GetCreditosPendientesPorCliente1(int clienteId)
        {
            try
            {
                // Consultamos solo los créditos del cliente
                var query = await _creditoRepository.Consultar(c => c.ClienteId == clienteId);

                // Filtramos solamente los pendientes
                var pendientes = query
                    .Where(c => c.MontoPendiente > 0)
                    .ToList();

                // Retornamos en DTO
                return _mapper.Map<List<CreditoMostrarDTO>>(pendientes);
            }
            catch
            {
                throw;
            }
        }
        public async Task<List<CreditoMostrarDTO>> GetCreditosClienteApp(int clienteId)
        {
            try
            {
                // Consultamos solo los créditos del cliente
                var query = await _creditoRepository.Consultar(c => c.ClienteId == clienteId);

                // Filtramos solamente los pendientes
                var pendientes = query
                    .Where(c => c.MontoPendiente > 0)
                    .ToList();

                // Retornamos en DTO
                return _mapper.Map<List<CreditoMostrarDTO>>(pendientes);
            }
            catch
            {
                throw;
            }
        }

        //public async Task<List<HistoriaAppDTO>> GetCalendarioPagos(int creditoId)

        public async Task<List<HistoriaAppDTO>> GetCalendarioPagos(int creditoId, int clienteId)
        {
            var credito = await _creditoRepository.Obtener(c => c.Id == creditoId);
            if (credito == null)
                throw new Exception("Crédito no encontrado");

            var historial = new List<HistoriaAppDTO>();
            // 🚩 IMPORTANTE: Usar la misma tolerancia que en RegistrarPago
    decimal TOLERANCIA = 0.60m;
            decimal saldoRestante = credito.MontoTotal - credito.Entrada;


            // 1️⃣ Registrar entrada
            historial.Add(new HistoriaAppDTO
            {
                Id = credito.Id,
                ClienteId = credito.ClienteId,
                TiendaId = credito.TiendaAppId,
                CreditoId = credito.Id,
                ProximaCuotaStr = credito.FechaCreacion.ToString("yyyy-MM-dd"),
                AbonadoCuota = credito.Entrada,
                MontoPendiente = Math.Round(saldoRestante, 2),
                EstadoCuota = "Pagado",
               
            });

            decimal valorCuota = credito.ValorPorCuota;
            DateTime fechaPago = credito.FechaCreacion;

            // 🔥 Guardar día original para pagos mensuales
            int diaOriginal = fechaPago.Day;

            // Calcular primera fecha de pago
            fechaPago = CalcularProximaFecha(fechaPago, credito.FrecuenciaPago, diaOriginal);

            decimal pagoRestante = credito.AbonadoTotal - credito.Entrada;

            // 2️⃣ Generar cuotas restantes
            for (int i = 0; i < credito.PlazoCuotas; i++)
            {
                // Determinar estado del pago
                string estado;
               
                if (pagoRestante >= (valorCuota - TOLERANCIA))
                {
                    estado = "Pagado";
                    pagoRestante -= valorCuota;


                    // Si la cuota está pagada, buscamos el siguiente pago en la lista de la BD
                   



                }
                else if (pagoRestante > 0)
                {
                    estado = "Pagado";
                    pagoRestante = 0;
                }
                else
                {
                    estado = "Pendiente";
                }

                bool esUltimaCuota = (i == credito.PlazoCuotas - 1);

                if (esUltimaCuota)
                {
                    // ✅ La última cuota cierra el saldo exacto
                    historial.Add(new HistoriaAppDTO
                    {
                        Id = credito.Id,
                        ClienteId = credito.ClienteId,
                        TiendaId = credito.TiendaAppId,
                        CreditoId= credito.Id,
                        ProximaCuotaStr = fechaPago.ToString("yyyy-MM-dd"),
                        AbonadoCuota = Math.Round(saldoRestante, 2),
                        MontoPendiente = 0,
                        EstadoCuota = estado
                    });
                }
                else
                {
                    // Cuota normal
                    decimal nuevoSaldo = Math.Round(saldoRestante - valorCuota, 2);

                    // Aplicar tolerancia al saldo visual
                    if (nuevoSaldo > 0 && nuevoSaldo <= TOLERANCIA) nuevoSaldo = 0;

                    historial.Add(new HistoriaAppDTO
                    {
                        Id = credito.Id,
                        ClienteId = credito.ClienteId,
                        TiendaId = credito.TiendaAppId,
                        CreditoId = credito.Id,
                        ProximaCuotaStr = fechaPago.ToString("yyyy-MM-dd"),
                        AbonadoCuota = valorCuota,
                        MontoPendiente = nuevoSaldo,
                        EstadoCuota = estado
                    });

                    saldoRestante = nuevoSaldo;
                }

                // Calcular siguiente fecha de pago
                fechaPago = CalcularProximaFecha(fechaPago, credito.FrecuenciaPago, diaOriginal);
            }

            return historial;
        }




        public async Task ActualizarEstadosCuotasAsync()
        {
            var creditosPendientes = await _creditoRepository.Consultar(
                c => c.Estado != "Pagado" && c.MontoPendiente > 0
            );

            var listaCreditosPendientes = creditosPendientes.ToList();

            foreach (var credito in listaCreditosPendientes)
            {
                credito.ProximaCuota = DateTime.SpecifyKind(credito.ProximaCuota, DateTimeKind.Utc);

                if (DateTime.UtcNow.Date > credito.ProximaCuota.Date)
                {
                    credito.EstadoCuota = "Atrasada";
                }
                else if (credito.MontoPendiente > 0)
                {
                    credito.EstadoCuota = "Pendiente";
                }

                await _creditoRepository.Editar(credito);
            }
        }


        public async Task<List<PagoRealizadoDTO>> ListarPagosPorCredito(int creditoId)
        {
            var pagos = await _context.RegistrosPagos
                .Include(p => p.Credito)
                    .ThenInclude(c => c.Cliente)
                        .ThenInclude(d => d.DetalleCliente) // <--- FALTA ESTA LÍNEA
                .Where(p => p.CreditoId == creditoId)
                .OrderByDescending(p => p.FechaPago)
                .ToListAsync();

            return pagos.Select(p => new PagoRealizadoDTO
            {
                Id = p.Id,
                CreditoId = p.CreditoId,
                MontoPagado = p.MontoPagado,
                MetodoPago = p.MetodoPago ?? "Efectivo",
                FechaPago = p.FechaPago,
                FechaPagoStr = p.FechaPago.ToString("dd/MM/yyyy HH:mm"),
                // Protege toda la cadena con el operador "?"
                NombreCliente = p.Credito?.Cliente?.DetalleCliente?.NombreApellidos ?? "N/A"
            }).ToList();
        }
        // 🔥 MÉTODO AUXILIAR (agrega este método en tu clase)
        private DateTime CalcularProximaFecha(DateTime fechaActual, string frecuencia, int diaOriginal)
        {
            switch (frecuencia.ToLower())
            {
                case "semanal":
                    return fechaActual.AddDays(7);

                case "quincenal":
                    return fechaActual.AddDays(15);

                case "mensual":
                    // Agregar un mes
                    var nuevaFecha = fechaActual.AddMonths(1);

                    // Obtener el último día del mes
                    int ultimoDiaDelMes = DateTime.DaysInMonth(nuevaFecha.Year, nuevaFecha.Month);

                    // Usar el día original, pero si no existe, usar el último día disponible
                    int diaFinal = Math.Min(diaOriginal, ultimoDiaDelMes);

                    // Crear la nueva fecha manteniendo hora/minuto/segundo
                    return new DateTime(
                        nuevaFecha.Year,
                        nuevaFecha.Month,
                        diaFinal,
                        fechaActual.Hour,
                        fechaActual.Minute,
                        fechaActual.Second,
                        DateTimeKind.Utc
                    );

                default:
                    return fechaActual;
            }
        }



    }



}

