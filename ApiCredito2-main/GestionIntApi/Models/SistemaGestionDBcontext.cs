using GestionIntApi.Models.Admin;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using System;
using System.Collections.Generic;

namespace GestionIntApi.Models
{
    public class SistemaGestionDBcontext: DbContext
    {


        public SistemaGestionDBcontext(DbContextOptions<SistemaGestionDBcontext> options)
            : base(options)
        {
        }


        public DbSet<Usuario> Usuarios { get; set; }
       public virtual DbSet<Rol> Rol { get; set; } = null!;
        public virtual DbSet<MenuRol> MenuRols { get; set; } = null!;
        public virtual DbSet<Menu> Menus { get; set; } = null!;
        public DbSet<EmailSettings> EmailSettings { get; set; }

        public DbSet<VerificationCode> VerificationCodes { get; set; }

        public DbSet<VerificationCode> CodigosVerificacion { get; set; }
        public DbSet<Tienda> Tiendas { get; set; }

        public DbSet<TiendaApp> TiendaApps { get; set; }
        public DbSet<Cliente> Clientes { get; set; }
        public DbSet<DetalleCliente> DetallesCliente { get; set; }
        public DbSet<Credito> Creditos { get; set; }

        public DbSet<Notificacion> Notificacions { get; set; }

        public DbSet<Ubicacion> Ubicacions { get; set; }

        public DbSet<RegistrarPago> RegistrosPagos { get; set; }

        public DbSet<UsuarioAdmin> UsuariosAdmin { get; set; }
        public DbSet<RolAdmin> RolesAdmin { get; set; }
        public DbSet<MenuAdmin> MenusAdmin { get; set; }
        public DbSet<MenuRolAdmin> MenuRolAdmin { get; set; }
        public DbSet<MovimientoInventario> MovimientosInventario { get; set; }
        public DbSet<Producto> Productos { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Rol>().HasData(
      new Rol { Id = 1, Descripcion = "Administrador", FechaRegistro = new DateTime(2025, 12, 12, 0, 0, 0, DateTimeKind.Utc) },
      new Rol { Id = 2, Descripcion = "Cliente", FechaRegistro = new DateTime(2025, 12, 12, 0, 0, 0, DateTimeKind.Utc) },
      new Rol { Id = 3, Descripcion = "Cajera", FechaRegistro = new DateTime(2025, 12, 12, 0, 0, 0, DateTimeKind.Utc) }
  );

            // 2. Seed Menus (App Móvil)
            modelBuilder.Entity<Menu>().HasData(
                new Menu { Id = 1, Nombre = "DashBoard", Icono = "dashboard", Url = "/pages/dashboard" },
                new Menu { Id = 2, Nombre = "Pagos", Icono = "payments", Url = "/pages/pagos" },
                new Menu { Id = 3, Nombre = "Usuario App", Icono = "person", Url = "/pages/usuarioApp" },
                new Menu { Id = 4, Nombre = "Usuario Admin", Icono = "admin_panel_settings", Url = "/pages/usuarioAdmin" },
                new Menu { Id = 5, Nombre = "Registrar Bodega", Icono = "inventory", Url = "/pages/bodega/registrar" },
                new Menu { Id = 6, Nombre = "Editar Bodega", Icono = "edit_attributes", Url = "/pages/bodega/editar" },
                new Menu { Id = 7, Nombre = "Registrar Tienda", Icono = "storefront", Url = "/pages/tienda/registrar" },
                new Menu { Id = 8, Nombre = "Movimientos", Icono = "history", Url = "/pages/movimientos" },
                new Menu { Id = 9, Nombre = "Reportes", Icono = "assessment", Url = "/pages/reportes" },
                new Menu { Id = 10, Nombre = "Ubicacion", Icono = "location_on", Url = "/pages/ubicacion" }
            );

            // 3. Seed MenuRols (App Móvil)
            modelBuilder.Entity<MenuRol>().HasData(
                // PERMISOS PARA EL ADMINISTRADOR (RolId = 1) - Acceso completo
                new MenuRol { Id = 1, MenuId = 1, RolId = 1 },   // Dashboard
                new MenuRol { Id = 2, MenuId = 2, RolId = 1 },   // Pagos
                new MenuRol { Id = 3, MenuId = 3, RolId = 1 },   // Usuario App
                new MenuRol { Id = 4, MenuId = 4, RolId = 1 },   // Usuario Admin
                new MenuRol { Id = 5, MenuId = 5, RolId = 1 },   // Registrar Bodega
                new MenuRol { Id = 6, MenuId = 6, RolId = 1 },   // Editar Bodega
                new MenuRol { Id = 7, MenuId = 7, RolId = 1 },   // Registrar Tienda
                new MenuRol { Id = 8, MenuId = 8, RolId = 1 },   // Movimientos
                new MenuRol { Id = 9, MenuId = 9, RolId = 1 },   // Reportes
                new MenuRol { Id = 10, MenuId = 10, RolId = 1 }, // Ubicacion

                // PERMISOS PARA LA CAJERA (RolId = 3) - Acceso limitado
                new MenuRol { Id = 11, MenuId = 1, RolId = 3 },  // Dashboard
                new MenuRol { Id = 12, MenuId = 2, RolId = 3 },  // Pagos
                new MenuRol { Id = 13, MenuId = 3, RolId = 3 },  // Usuario App
                new MenuRol { Id = 14, MenuId = 5, RolId = 3 },  // Registrar Bodega
                new MenuRol { Id = 15, MenuId = 7, RolId = 3 },  // Registrar Tienda
                new MenuRol { Id = 16, MenuId = 8, RolId = 3 },  // Movimientos
                new MenuRol { Id = 17, MenuId = 9, RolId = 3 }   // Reportes
                                                                 // NOTA: Cajera NO tiene acceso a MenuId 4 (Usuario Admin), 6 (Editar Bodega), 10 (Ubicacion)
            );


            // ============================================================================
            // SEED PARA PANEL ADMINISTRATIVO WEB
            // ============================================================================

            // 4. Seed RolAdmin (Panel Web)
            modelBuilder.Entity<RolAdmin>().HasData(
                new RolAdmin { Id = 1, Descripcion = "Administrador", FechaRegistro = new DateTime(2025, 12, 12, 0, 0, 0, DateTimeKind.Utc) },
                //new RolAdmin { Id = 2, Descripcion = "Cliente", FechaRegistro = new DateTime(2025, 12, 12, 0, 0, 0, DateTimeKind.Utc) },
                new RolAdmin { Id = 3, Descripcion = "Team", FechaRegistro = new DateTime(2025, 12, 12, 0, 0, 0, DateTimeKind.Utc) }
            );

            // 5. Seed MenuAdmin (Panel Web)
            modelBuilder.Entity<MenuAdmin>().HasData(
                new MenuAdmin { Id = 1, Nombre = "Dashboard", Icono = "dashboard", Url = "panel-control" },
                new MenuAdmin { Id = 2, Nombre = "Usuarios Admin", Icono = "admin_panel_settings", Url = "gestion-administradores" },
                new MenuAdmin { Id = 3, Nombre = "Registro App Móvil", Icono = "how_to_reg", Url = "registro-usuarios-app/nuevo" },
                new MenuAdmin { Id = 4, Nombre = "Pagos", Icono = "payments", Url = "gestion-pagos" },
                new MenuAdmin { Id = 5, Nombre = "Ubicación", Icono = "location_on", Url = "geolocalizacion-tiendas" },
                new MenuAdmin { Id = 6, Nombre = "Registrar Bodega", Icono = "inventory", Url = "inventario/registro-bodega" },
                new MenuAdmin { Id = 7, Nombre = "Editar Bodega", Icono = "edit_attributes", Url = "inventario/configuracion-bodega" },
                new MenuAdmin { Id = 8, Nombre = "Registrar Tienda", Icono = "storefront", Url = "gestion-tiendas/nueva-sucursal" },
                new MenuAdmin { Id = 9, Nombre = "Movimientos", Icono = "history", Url = "historial-movimientos" },
                new MenuAdmin { Id = 10, Nombre = "Reportes", Icono = "assessment", Url = "reportes-generales" }
            );

            // 6. Seed MenuRolAdmin (Panel Web)
            modelBuilder.Entity<MenuRolAdmin>().HasData(
                // PERMISOS PARA EL ADMINISTRADOR (RolAdminId = 1) - Acceso completo a los 10 menús
                new MenuRolAdmin { Id = 1, MenuAdminId = 1, RolAdminId = 1 },   // Dashboard
                new MenuRolAdmin { Id = 2, MenuAdminId = 2, RolAdminId = 1 },   // Usuarios Admin
                new MenuRolAdmin { Id = 3, MenuAdminId = 3, RolAdminId = 1 },   // Registro App Móvil
                new MenuRolAdmin { Id = 4, MenuAdminId = 4, RolAdminId = 1 },   // Pagos
                new MenuRolAdmin { Id = 5, MenuAdminId = 5, RolAdminId = 1 },   // Ubicación
                new MenuRolAdmin { Id = 6, MenuAdminId = 6, RolAdminId = 1 },   // Registrar Bodega
                new MenuRolAdmin { Id = 7, MenuAdminId = 7, RolAdminId = 1 },   // Editar Bodega
                new MenuRolAdmin { Id = 8, MenuAdminId = 8, RolAdminId = 1 },   // Registrar Tienda
                new MenuRolAdmin { Id = 9, MenuAdminId = 9, RolAdminId = 1 },   // Movimientos
                new MenuRolAdmin { Id = 10, MenuAdminId = 10, RolAdminId = 1 }, // Reportes

                // PERMISOS PARA LA CAJERA (RolAdminId = 3) - Acceso limitado
               // new MenuRolAdmin { Id = 11, MenuAdminId = 1, RolAdminId = 3 },  // Dashboard
                new MenuRolAdmin { Id = 12, MenuAdminId = 3, RolAdminId = 3 },  // Registro App Móvil
                new MenuRolAdmin { Id = 13, MenuAdminId = 4, RolAdminId = 3 },  // Pagos
                new MenuRolAdmin { Id = 14, MenuAdminId = 6, RolAdminId = 3 },  // Registrar Bodega
                new MenuRolAdmin { Id = 15, MenuAdminId = 8, RolAdminId = 3 },  // Registrar Tienda
                new MenuRolAdmin { Id = 16, MenuAdminId = 9, RolAdminId = 3 },  // Movimientos
                new MenuRolAdmin { Id = 17, MenuAdminId = 10, RolAdminId = 3 }  // Reportes
                                                                                // NOTA: Cajera NO tiene acceso a MenuAdminId 2 (Usuarios Admin), 5 (Ubicación), 7 (Editar Bodega)
            );



        }




    }

}

