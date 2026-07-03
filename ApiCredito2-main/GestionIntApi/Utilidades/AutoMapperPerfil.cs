using AutoMapper;
using DocumentFormat.OpenXml.Presentation;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Models.Admin;

namespace GestionIntApi.Utilidades
{
    public class AutoMapperPerfil : Profile
    {


        public AutoMapperPerfil()
        {
            #region Rol
            CreateMap<Rol, RolDTO>().ReverseMap();
            #endregion Rol

            #region Menu
            CreateMap<Menu, MenuDTO>().ReverseMap();
            #endregion Menu

            #region Usuario
            CreateMap<Usuario, UsuarioDTO>()
                 .ForMember(dest => dest.Cliente, opt => opt.Ignore())
                .ForMember(destino =>
                    destino.RolDescripcion,
                    opt => opt.MapFrom(origen => origen.Rol.Descripcion)
                )

                .ForMember(destino =>
                destino.EsActivo,
                opt => opt.MapFrom(origen => origen.EsActivo == true ? 1 : 0)
            );

            CreateMap<Usuario, UsuarioCompletoDto>()
     // Quitamos el .Ignore() de Cliente para que sí lo mapee
     .ForMember(destino => destino.RolDescripcion,
         opt => opt.MapFrom(origen => origen.Rol.Descripcion)
     )
     .ForMember(destino => destino.EsActivo,
         opt => opt.MapFrom(origen => origen.EsActivo == true ? 1 : 0)
     );

            // Para el camino inverso (DTO a Entidad)
            CreateMap<UsuarioDTO, UsuarioCompletoDto>()
                // También quitamos el Ignore de Cliente aquí para poder guardar
              //  .ForMember(destino => destino.Rol, opt => opt.Ignore())
                .ForMember(destino => destino.EsActivo,
                    opt => opt.MapFrom(origen => origen.EsActivo == 1 ? true : false)
                );

            CreateMap<Usuario, SesionDTO>()
                .ForMember(destino =>
                    destino.RolDescripcion,
                    opt => opt.MapFrom(origen => origen.Rol.Descripcion)
                );

            CreateMap<UsuarioDTO, Usuario>()
                  .ForMember(dest => dest.Cliente, opt => opt.Ignore())
                 .ForMember(destino =>
                    destino.Rol,
                    opt => opt.Ignore()
                   )
                 .ForMember(destino =>
                    destino.EsActivo,
                    opt => opt.MapFrom(origen => origen.EsActivo == 1 ? true : false)
                   );

            CreateMap<Credito, CreditoMostrarDTO>()
              .ForMember(dest => dest.ProximaCuotaStr,
        opt => opt.MapFrom(src => src.ProximaCuota.ToString("dd/MM/yyyy")))
              .ForMember(dest => dest.FechaCreditoStr,
        opt => opt.MapFrom(src => src.FechaCreacion.ToString("dd/MM/yyyy")));

            #endregion Usuario
            #region DetalleCliente
            CreateMap<DetalleCliente, DetalleClienteDTO>().ReverseMap();
            CreateMap<ClienteDTO, Cliente>()
    .ForMember(dest => dest.Usuario, opt => opt.Ignore())
   // .ForMember(dest => dest.TiendaApps, opt => opt.MapFrom(src => src.TiendasApps))
    .ReverseMap();

            CreateMap<Cliente, ReporteDTO>().ReverseMap();
        //    CreateMap<Cliente, ClienteMostrarAppDTO>()
        //         .ForMember(dest => dest.NombreApellidos,
        //   opt => opt.MapFrom(src => src.DetalleCliente.NombreApellidos))
        //     .ForMember(dest => dest.Correo,
        //opt => opt.MapFrom(src => src.Usuario.Correo));


            #endregion DetalleCliente
            #region Credito
            CreateMap<Credito, CreditoDTO>()
                .ForMember(dest => dest.ProximaCuotaStr,
               opt => opt.MapFrom(src => src.ProximaCuota.ToString("dd/MM/yyyy")));
            CreateMap<CreditoDTO, Credito>()
    .ForMember(dest => dest.ProximaCuota, opt => opt.MapFrom(src => src.ProximaCuota));

            CreateMap<Credito, PagarCreditoDTO>()
            .ForMember(dest => dest.ProximaCuotaStr,
               opt => opt.MapFrom(src => src.ProximaCuota.ToString("dd/MM/yyyy")));
            

            #endregion Credito
            #region Tienda
            CreateMap<Tienda, TiendaDTO>().ReverseMap();
            CreateMap<Tienda, TiendaMostrarAppDTO>();

            #endregion Tienda


            #region Notificacion

            CreateMap<Notificacion, NotificacionDTO>().ReverseMap();
            #endregion Notificacion



            


            #region Ubicacion

            CreateMap<Ubicacion, UbicacionDTO>().ReverseMap();
           CreateMap<Ubicacion, UbicacionMostrarDTO>().ReverseMap();
           
            #endregion Ubicacion

            #region TiendaApp
            CreateMap<TiendaApp, TiendaAppDTO>().ReverseMap();
            CreateMap<TiendaAdminDTO, Tienda>().ReverseMap();

            #endregion Ubicacion


            CreateMap<TiendaApp, TiendaMostrarAppVentaDTO>()
    .ForMember(dest => dest.FechaRegistroStr,


               opt => opt.MapFrom(src => src.FechaRegistro.ToString("dd/MM/yyyy")));


            CreateMap<TiendaMostrarAppVentaDTO, TiendaApp>();







            #region RolAdmin
            CreateMap<RolAdmin, RolAdminDto>().ReverseMap();
            #endregion RolAdmin

            #region MenuAdmin
            CreateMap<MenuAdmin, MenuAdminDto>().ReverseMap();
            #endregion MenuAdmin

            #region UsuarioAdmin
            CreateMap<UsuarioAdmin, UsuarioAdminDTO>()
                   
                    .ForMember(destino =>
                        destino.RolDescripcion,
                        opt => opt.MapFrom(origen => origen.RolAdmin.Descripcion)
                    )

                    .ForMember(destino =>
                    destino.EsActivo,
                    opt => opt.MapFrom(origen => origen.EsActivo == true ? 1 : 0)
                );


            CreateMap<UsuarioAdmin, SesionDTOAdmin>()
                .ForMember(destino =>
                    destino.RolAdminDescripcion,
                    opt => opt.MapFrom(origen => origen.RolAdmin.Descripcion)
                );

            CreateMap<UsuarioAdminDTO, UsuarioAdmin>()
              
                 .ForMember(destino =>
                    destino.RolAdmin,
                    opt => opt.Ignore()
                   )
                 .ForMember(destino =>
                    destino.EsActivo,
                    opt => opt.MapFrom(origen => origen.EsActivo == 1 ? true : false)
                   );



            #endregion UsuarioAdmin








            CreateMap<Producto, ProductoBodegaDTO>()
    .ForMember(dest => dest.FechaIngreso, opt => opt.MapFrom(src => src.FechaRegistro))
    .ForMember(dest => dest.DiasEnBodega, opt => opt.MapFrom(src => (DateTime.UtcNow - src.FechaRegistro).Days));



            // Esto soluciona tu error "Missing type map configuration"
            CreateMap<ProductoBodegaDTO, Producto>()
                .ForMember(dest => dest.FechaRegistro, opt => opt.Ignore()); // La fecha la maneja la DB o el Service
                                                                             // .ForMember(dest => dest.TiendaId, opt => opt.Ignore())
                                                                             //.ForMember(dest => dest.Movimientos, opt => opt.Ignore());






            #region MovimientoInventario
            CreateMap<MovimientoInventario, MovimientoHistorialDTO>()
                .ForMember(dest => dest.Codigo, opt => opt.MapFrom(src => src.Producto != null ? src.Producto.Codigo : null))
                .ForMember(dest => dest.TipoProducto, opt => opt.MapFrom(src => src.Producto != null ? src.Producto.TipoProducto : null))
                .ForMember(dest => dest.Marca, opt => opt.MapFrom(src => src.Producto != null ? src.Producto.Marca : null))
                .ForMember(dest => dest.Modelo, opt => opt.MapFrom(src => src.Producto != null ? src.Producto.Modelo : null))
                .ForMember(dest => dest.IMEI, opt => opt.MapFrom(src => src.Producto != null ? src.Producto.IMEI : null))
                .ForMember(dest => dest.Serie, opt => opt.MapFrom(src => src.Producto != null ? src.Producto.Serie : null))
                .ForMember(dest => dest.TiendaOrigen, opt => opt.MapFrom(src => src.TiendaOrigen != null ? src.TiendaOrigen.NombreTienda : null))
                .ForMember(dest => dest.TiendaDestino, opt => opt.MapFrom(src => src.TiendaDestino != null ? src.TiendaDestino.NombreTienda : null));

            CreateMap<MovimientoHistorialDTO, MovimientoInventario>();
            #endregion

            #region Tienda
            CreateMap<Tienda, TiendaDestinoDTO>();
            CreateMap<TiendaDestinoDTO, Tienda>();
            #endregion

            #region StockBodega
            CreateMap<StockBodegaDTO, StockBodegaDTO>();
            CreateMap<StockPorTipoDTO, StockPorTipoDTO>();
            #endregion



            // Mapeo de la tabla RegistrosPagos al DTO de historial
            CreateMap<RegistrarPago, PagoRealizadoDTO>()
             // 1. Mapeamos la fecha a String con formato legible
             .ForMember(destino =>
                 destino.FechaPagoStr,
                 opt => opt.MapFrom(origen => origen.FechaPago.ToString("dd/MM/yyyy HH:mm"))
             )
             // 2. Mapeamos el nombre del cliente con protección de nulos
             .ForMember(destino =>
                 destino.NombreCliente,
                 opt => opt.MapFrom(origen =>
                     origen.Credito != null &&
                     origen.Credito.Cliente != null &&
                     origen.Credito.Cliente.DetalleCliente != null
                     ? origen.Credito.Cliente.DetalleCliente.NombreApellidos
                     : "N/A"
                 )
             );



        }







    }
}
