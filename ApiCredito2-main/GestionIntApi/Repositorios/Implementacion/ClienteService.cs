using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Globalization;


namespace GestionIntApi.Repositorios.Implementacion
{
    public class ClienteService:IClienteService
    {
       
        private readonly IClienteRepository _clienteRepository;
        private readonly IGenericRepository<Cliente> _clienteRepository2;
        private readonly SistemaGestionDBcontext _context;
        private readonly IMapper _mapper;
        private readonly IGenericRepository<DetalleCliente> _DetalleRepositorio;
        private readonly IGenericRepository<Cliente> _DetalleApp;
        private readonly IGenericRepository<Credito> _CreditoRepositorio;

        private readonly ICreditoService _CreditoRepository;
        private readonly IGenericRepository<Tienda> _TiendaRepositorio;
        private readonly ICreditoService _CreditoServicio;
        public ClienteService(ICreditoService CreditoRepository, IGenericRepository<Cliente> DetalleApp,ICreditoService CreditoServicio,IGenericRepository<DetalleCliente> DetalleRepositorio, IGenericRepository<Tienda> TiendaRepositorio, 
            IGenericRepository<Credito> CreditoRepositorio, IClienteRepository clienteRepository,
            IGenericRepository<Cliente> clienteRepository2, SistemaGestionDBcontext context, IMapper mapper)
        {
            _context = context;
            _clienteRepository=clienteRepository;
            _mapper = mapper;
            _clienteRepository2= clienteRepository2;
            _DetalleRepositorio = DetalleRepositorio;
            _CreditoRepositorio = CreditoRepositorio;
            _TiendaRepositorio = TiendaRepositorio;
            _CreditoServicio=CreditoServicio;
            _DetalleApp = DetalleApp;
            _CreditoRepository=CreditoRepository;
        }
        public async Task<List<ClienteDTO>> GetClientes()
        {
            var lista = await _clienteRepository.ObtenerClientesCompletos();

            return _mapper.Map<List<ClienteDTO>>(lista);
        }

        public async Task<ClienteDTO> GetClienteById(int id)
        {
            var cliente = await _clienteRepository.ObtenerClienteId(id);
            if (cliente == null)
                throw new TaskCanceledException("El cliente no existe");

            return _mapper.Map<ClienteDTO>(cliente);
        }

        public async Task<ClienteDTO> CreateCliente(ClienteDTO clienteDto)
        {
            try
            {
                var clienteGenerado = await _clienteRepository.Registrar(_mapper.Map<Cliente>(clienteDto));

                if (clienteGenerado.Id == 0)
                    throw new TaskCanceledException("No se pudo crear el cliente");
                return _mapper.Map<ClienteDTO>(clienteGenerado);
            }
            catch
            {
                throw;
            }
        }

        public async Task<ClienteDTO> CrearClienteDesdeAdmin(ClienteDTO modelo)
        {
            try
            {
                // 1. Guardar DetalleCliente
                var detalle = await _DetalleRepositorio.Crear(
                    _mapper.Map<DetalleCliente>(modelo.DetalleCliente)
                );

                // 2. Guardar Cliente (sin usuario)
                var cliente = new Cliente
                {
                    UsuarioId = null,  // 🔥 NULL porque no existe usuario
                    DetalleClienteID = detalle.Id
                };

                cliente = await _clienteRepository2.Crear(cliente);

                var tiendasCreadas = new List<TiendaApp>();

                if (modelo.TiendaApps != null)
                {
                    foreach (var t in modelo.TiendaApps)
                    {
                        // 🔥 CAMBIO: Ahora TiendaApp necesita TiendaId
                        // Primero debes buscar o crear la Tienda real

                        var tiendaExistente = await _context.Tiendas
                            .FirstOrDefaultAsync(x => x.CedulaEncargado == t.CedulaEncargado);

                        if (tiendaExistente == null)
                        {
                            throw new TaskCanceledException(
                                $"La tienda con cédula {t.CedulaEncargado} no existe. " +
                                "Primero debe registrarse la tienda."
                            );
                        }

                        // Crear TiendaApp (la relación intermedia)
                        var TiendaApps = new TiendaApp
                        {
                            TiendaId = tiendaExistente.Id,  // ✅ FK a Tiendas
                            ClienteId = cliente.Id,          // ✅ FK a Clientes
                            CedulaEncargado = t.CedulaEncargado,
                            EstadoDeComision = "Pendiente",  // O el valor que necesites
                            FechaRegistro = DateTime.UtcNow
                        };

                        var tiendaCreada = await _context.TiendaApps.AddAsync(TiendaApps);
                        await _context.SaveChangesAsync();

                        tiendasCreadas.Add(TiendaApps);
                    }
                }


                // 4. Guardar créditos si existen
                if (modelo.Creditos != null)
                {
                    foreach (var c in modelo.Creditos)
                    {
                        c.ClienteId = cliente.Id;

                        if (tiendasCreadas.Any())
                            c.TiendaAppId = tiendasCreadas.First().Id;
                        else
                            c.TiendaAppId= null;

                        // 🚀 Aquí se hace todo: validaciones, cálculos y guardado
                        await _CreditoServicio.CreateCredito(c);
                    }
                }

                return _mapper.Map<ClienteDTO>(cliente);
            }
            catch
            {
                throw;
            }
        }






        public async Task<bool> UpdateCliente(ClienteDTO cliente)
        {
            try
            {
                var clienteModelo = _mapper.Map<Cliente>(cliente);
                var OdontologoEncontrado = await _clienteRepository2.Obtener(c => c.Id == clienteModelo.Id);
                if (OdontologoEncontrado == null)
                    throw new TaskCanceledException("La cita no existe");
                OdontologoEncontrado.DetalleCliente = clienteModelo.DetalleCliente;
                OdontologoEncontrado.TiendaApps = clienteModelo.TiendaApps;
                var creditosExistentes = OdontologoEncontrado.Creditos.ToList();
                var creditosNuevos = clienteModelo.Creditos ?? new List<Credito>();

                foreach (var c in creditosNuevos)
                {
                    c.ClienteId = OdontologoEncontrado.Id;

                    if (c.Id == 0)
                    {
                        await _CreditoServicio.CreateCredito(_mapper.Map<CreditoDTO>(c));
                    }
                    else
                    {
                        await _CreditoServicio.UpdateCredito(_mapper.Map<CreditoDTO>(c));
                    }
                }

                var idsEnviados = creditosNuevos.Select(x => x.Id).ToList();
                var creditosAEliminar = creditosExistentes.Where(x => !idsEnviados.Contains(x.Id));

                foreach (var credito in creditosAEliminar)
                {
                    await _CreditoServicio.DeleteCredito(credito.Id);
                }


                bool respuesta = await _clienteRepository.Editar(OdontologoEncontrado);
                return respuesta;
            }
            catch
            {
                throw;
            }
        }

        public async Task<bool> DeleteCliente(int id)
        {
            var cliente = await _context.Clientes.FindAsync(id);
            if (cliente == null)
                return false;

            _context.Clientes.Remove(cliente);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<ClienteDTO>> GetClientesPorTienda(int tiendaId)
        {
            var clientes = await _context.Clientes
                .Where(c => c.TiendaApps.Any(t => t.Id == tiendaId))
                .Include(c => c.Usuario)
                .Include(c => c.DetalleCliente)
                 .Include(c => c.TiendaApps)
                .Include(c => c.Creditos)
                .ToListAsync();

            return _mapper.Map<IEnumerable<ClienteDTO>>(clientes);
        }

        public async Task<IEnumerable<ClienteDTO>> GetClientesPorUsuario(int usuarioId)
        {
            var clientes = await _context.Clientes
                .Where(c => c.UsuarioId == usuarioId)
                .Include(c => c.TiendaApps)
                .Include(c => c.Creditos)
                .ToListAsync();

            return _mapper.Map<IEnumerable<ClienteDTO>>(clientes);
        }




        /*
        public async Task<List<ReporteDTO>> Reporte(string fechaInicio, string fechaFin)
        {
            IQueryable<Cliente> query = await _clienteRepository2.Consultar();
            var listaResultado = new List<Cliente>();
          
            try
            {
                if (string.IsNullOrEmpty(fechaInicio) || string.IsNullOrEmpty(fechaFin))
                {
                    listaResultado = await query
                        .Include(p => p.Creditos)
                        .Include(p => p.DetalleCliente)
                        .Include(p => p.Tiendas)
                       
                        .ToListAsync();

                   
                }
                else
                {
                    DateTime fech_Inicio = DateTime.SpecifyKind(
      DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", new CultureInfo("es-EC")),
      DateTimeKind.Utc
  );

                    DateTime fech_Fin = DateTime.SpecifyKind(
                        DateTime.ParseExact(fechaFin, "dd/MM/yyyy", new CultureInfo("es-EC")),
                        DateTimeKind.Utc
                    );
                    listaResultado = await query
                     .Include(p => p.Creditos)
                        .Include(p => p.DetalleCliente)
                        .Include(p => p.Tiendas)

                       .Where(c => c.Creditos.Any(cr => cr.DiaPago >= fech_Inicio && cr.DiaPago <= fech_Fin))
    .ToListAsync();
                }


                // Mapeo manual a ReporteCreditoDTO
                listaResultado = clientes
                    .SelectMany(cliente => cliente.Creditos.Select(credito => new ReporteDTO
                    {
                        // CLIENTE
                        ClienteId = cliente.ClienteId,
                        NombreCliente = cliente.NombreCompleto,
                        Cedula = cliente.Cedula,
                        TelefonoCliente = cliente.DetalleCliente?.Telefono,
                        DireccionCliente = cliente.DetalleCliente?.Direccion,

                        // TIENDA
                        TiendaId = cliente.TiendaId,
                        NombreTienda = cliente.Tiendas?.NombreTienda,
                        EncargadoTienda = cliente.Tiendas?.Encargado,
                        TelefonoTienda = cliente.Tiendas?.Telefono,

                        // CRÉDITO
                        CreditoId = credito.CreditoId,
                        Entrada = credito.Entrada,
                        MontoTotal = credito.MontoTotal,
                        MontoPendiente = credito.MontoPendiente,
                        PlazoCuotas = credito.PlazoCuotas,
                        FrecuenciaPago = credito.FrecuenciaPago,
                        ValorPorCuota = credito.ValorPorCuota,
                        ProximaCuota = credito.ProximaCuota,
                        EstadoCredito = credito.Estado,

                        // FECHAS
                        FechaCreditoStr = cliente.credito.fechaCreacion.ToString("dd/MM/yyyy")
                    }))
                    .ToList();

            }
            catch
            {
                throw;
            }
            return _mapper.Map<List<ReporteDTO>>(listaResultado);
        }
*/

       
        public async Task<List<ReporteDTO>> Reporte(string fechaInicio, string fechaFin)
        {


            await _CreditoServicio.ActualizarEstadosCuotasAsync();

            IQueryable<Cliente> query = await _clienteRepository2.Consultar();
            var listaResultado = new List<ReporteDTO>();

            try
            {
                IQueryable<Cliente> queryConIncludes = query
                    .Include(p => p.Creditos)
                    .Include(p => p.DetalleCliente)
                    .Include(p => p.TiendaApps)
                           .ThenInclude(ta => ta.Tienda);

                List<Cliente> clientes;

                if (string.IsNullOrEmpty(fechaInicio) || string.IsNullOrEmpty(fechaFin))
                {
                    clientes = await queryConIncludes.ToListAsync();
                }
                else
                {
                    DateTime fech_Inicio = DateTime.SpecifyKind(
                        DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", new CultureInfo("es-EC")),
                        DateTimeKind.Utc
                    );
                    DateTime fech_Fin = DateTime.SpecifyKind(
                        DateTime.ParseExact(fechaFin, "dd/MM/yyyy", new CultureInfo("es-EC")),
                        DateTimeKind.Utc
                    );

                    clientes = await queryConIncludes
                        .Where(c => c.Creditos.Any(cr => cr.DiaPago >= fech_Inicio && cr.DiaPago <= fech_Fin))
                        .ToListAsync();
                }
               

                // Mapeo manual a ReporteDTO
                listaResultado = clientes
                    .SelectMany(cliente => cliente.Creditos.Select(credito => new ReporteDTO
                    {
                        
                        CodigoUnico = $"CRE-{credito.FechaCreacion.Year}-{credito.Id:D5}",
                        // CLIENTE
                        ClienteId = cliente.Id,
                        NombreCliente = $"{cliente.DetalleCliente.NombreApellidos}", // Ajustar según tu modelo
                        Cedula = cliente.DetalleCliente.NumeroCedula,
                        TelefonoCliente = cliente.DetalleCliente.Telefono,
                        DireccionCliente = cliente.DetalleCliente.Direccion,
                        

                        // TIENDA
                        TiendaId = credito.TiendaAppId,
                        NombreTienda = cliente.TiendaApps?.FirstOrDefault(t => t.Id == credito.TiendaAppId)?.Tienda.NombreTienda,
                        EncargadoTienda = cliente.TiendaApps?.FirstOrDefault(t => t.Id == credito.TiendaAppId)?.Tienda.NombreEncargado,
                        TelefonoTienda = cliente.TiendaApps?.FirstOrDefault(t => t.Id == credito.TiendaAppId)?.Tienda.Telefono,
                        EstadoDeComision = cliente.TiendaApps?.FirstOrDefault(t => t.Id == credito.TiendaAppId)?.EstadoDeComision,
                        Direccion = cliente.TiendaApps?.FirstOrDefault(t => t.Id == credito.TiendaAppId)?.Tienda.Direccion,
                        ValorComision = cliente.TiendaApps?.FirstOrDefault(t => t.Id == credito.TiendaAppId)?.Tienda.ValorComision ?? 0m,
                        Comentario = cliente.TiendaApps?.FirstOrDefault(t => t.Id == credito.TiendaAppId)?.Tienda.Comentario,
                        // CRÉDITO
                        // CRÉDITO
                        CreditoId = credito.Id,
                        NombrePropietario=credito.NombrePropietario,
                        Imai = credito.IMEI,
                        Entrada = credito.Entrada,
                        Marca = credito.Marca,

                        Modelo = credito.Modelo,
                        Capacidad = credito.Capacidad,
                       
                        MontoTotal = credito.MontoTotal,
                        MontoPendiente = credito.MontoPendiente,
                        PlazoCuotas = credito.PlazoCuotas,
                        FrecuenciaPago = credito.FrecuenciaPago,
                        ValorPorCuota = credito.ValorPorCuota,
                        ProximaCuota = credito.ProximaCuota,
                        EstadoCredito = credito.Estado,
                        AbonadoTotal = credito.AbonadoTotal,
                        // EstadoCuota y AbonadoCuota pueden requerir lógica adicional si están relacionados con cuotas específicas
                        EstadoCuota = credito.EstadoCuota, // Placeholder
                        AbonadoCuota = credito.AbonadoCuota, // Placeholder

                        // FECHAS
                        FechaCreditoStr = credito.FechaCreacion.ToString("dd/MM/yyyy"),

                    }))
                    .ToList();
            }
            catch
            {
                throw;
            }

            return listaResultado;
        }

        public async Task<ClienteMostrarAppDTO> GetClienteParaApp(int usuarioId)
        {
            return await _context.Clientes
                .AsNoTracking() // 🚀 mejora rendimiento
                .Where(c => c.UsuarioId == usuarioId)
                .Select(c => new ClienteMostrarAppDTO
                {
                    Id = c.Id,
                    NombreApellidos = c.DetalleCliente.NombreApellidos,
                    Correo = c.Usuario.Correo,
                    UsuarioId = c.UsuarioId ?? 0,
                })
                .FirstOrDefaultAsync()
                ?? throw new TaskCanceledException("Cliente no encontrado");
        }










    }
}
