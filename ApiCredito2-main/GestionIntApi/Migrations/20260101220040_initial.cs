using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace GestionIntApi.Migrations
{
    /// <inheritdoc />
    public partial class initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DetallesCliente",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    NumeroCedula = table.Column<string>(type: "text", nullable: false),
                    NombreApellidos = table.Column<string>(type: "text", nullable: false),
                    Telefono = table.Column<string>(type: "text", nullable: false),
                    Direccion = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DetallesCliente", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "EmailSettings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    From = table.Column<string>(type: "text", nullable: false),
                    Password = table.Column<string>(type: "text", nullable: false),
                    Host = table.Column<string>(type: "text", nullable: false),
                    Port = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EmailSettings", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Menus",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Nombre = table.Column<string>(type: "text", nullable: true),
                    Icono = table.Column<string>(type: "text", nullable: true),
                    Url = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Menus", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "MenusAdmin",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Nombre = table.Column<string>(type: "text", nullable: true),
                    Icono = table.Column<string>(type: "text", nullable: true),
                    Url = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MenusAdmin", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Rol",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Descripcion = table.Column<string>(type: "text", nullable: true),
                    FechaRegistro = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Rol", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "RolesAdmin",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Descripcion = table.Column<string>(type: "text", nullable: true),
                    FechaRegistro = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RolesAdmin", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Tiendas",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    NombreTienda = table.Column<string>(type: "text", nullable: false),
                    Direccion = table.Column<string>(type: "text", nullable: false),
                    NombreEncargado = table.Column<string>(type: "text", nullable: false),
                    CedulaEncargado = table.Column<string>(type: "text", nullable: false),
                    Telefono = table.Column<string>(type: "text", nullable: false),
                    FechaRegistro = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Tiendas", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Ubicacions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UsuarioId = table.Column<int>(type: "integer", nullable: false),
                    Latitud = table.Column<double>(type: "double precision", nullable: false),
                    Longitud = table.Column<double>(type: "double precision", nullable: false),
                    Fecha = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Ubicacions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "VerificationCode",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Correo = table.Column<string>(type: "text", nullable: false),
                    Codigo = table.Column<string>(type: "text", nullable: false),
                    Expira = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_VerificationCode", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "MenuRols",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MenuId = table.Column<int>(type: "integer", nullable: true),
                    RolId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MenuRols", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MenuRols_Menus_MenuId",
                        column: x => x.MenuId,
                        principalTable: "Menus",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_MenuRols_Rol_RolId",
                        column: x => x.RolId,
                        principalTable: "Rol",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Usuarios",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    NombreApellidos = table.Column<string>(type: "text", nullable: true),
                    Correo = table.Column<string>(type: "text", nullable: true),
                    RolId = table.Column<int>(type: "integer", nullable: true),
                    Clave = table.Column<string>(type: "text", nullable: true),
                    EsActivo = table.Column<bool>(type: "boolean", nullable: false),
                    FechaRegistro = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    PasswordResetToken = table.Column<string>(type: "text", nullable: true),
                    ResetTokenExpires = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Usuarios", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Usuarios_Rol_RolId",
                        column: x => x.RolId,
                        principalTable: "Rol",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "MenuRolAdmin",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MenuAdminId = table.Column<int>(type: "integer", nullable: true),
                    RolAdminId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MenuRolAdmin", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MenuRolAdmin_MenusAdmin_MenuAdminId",
                        column: x => x.MenuAdminId,
                        principalTable: "MenusAdmin",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_MenuRolAdmin_RolesAdmin_RolAdminId",
                        column: x => x.RolAdminId,
                        principalTable: "RolesAdmin",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UsuariosAdmin",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    NombreApellidos = table.Column<string>(type: "text", nullable: true),
                    Correo = table.Column<string>(type: "text", nullable: true),
                    RolAdminId = table.Column<int>(type: "integer", nullable: true),
                    Clave = table.Column<string>(type: "text", nullable: true),
                    EsActivo = table.Column<bool>(type: "boolean", nullable: true),
                    FechaRegistro = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UsuariosAdmin", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UsuariosAdmin_RolesAdmin_RolAdminId",
                        column: x => x.RolAdminId,
                        principalTable: "RolesAdmin",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Producto",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Codigo = table.Column<string>(type: "text", nullable: false),
                    TipoProducto = table.Column<string>(type: "text", nullable: false),
                    IMEI = table.Column<string>(type: "text", nullable: true),
                    Serie = table.Column<string>(type: "text", nullable: true),
                    Marca = table.Column<string>(type: "text", nullable: false),
                    Modelo = table.Column<string>(type: "text", nullable: false),
                    Color = table.Column<string>(type: "text", nullable: true),
                    Tamano = table.Column<string>(type: "text", nullable: true),
                    Estado = table.Column<string>(type: "text", nullable: false),
                    TiendaActualId = table.Column<int>(type: "integer", nullable: true),
                    PrecioCompra = table.Column<decimal>(type: "numeric", nullable: false),
                    PrecioVenta = table.Column<decimal>(type: "numeric", nullable: true),
                    Descripcion = table.Column<string>(type: "text", nullable: true),
                    FechaRegistro = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Producto", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Producto_Tiendas_TiendaActualId",
                        column: x => x.TiendaActualId,
                        principalTable: "Tiendas",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Clientes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UsuarioId = table.Column<int>(type: "integer", nullable: true),
                    DetalleClienteID = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Clientes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Clientes_DetallesCliente_DetalleClienteID",
                        column: x => x.DetalleClienteID,
                        principalTable: "DetallesCliente",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Clientes_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "MovimientoInventario",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    TipoMovimiento = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    FechaMovimiento = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ProductoId = table.Column<int>(type: "integer", nullable: false),
                    TiendaOrigenId = table.Column<int>(type: "integer", nullable: true),
                    TiendaDestinoId = table.Column<int>(type: "integer", nullable: true),
                    Observacion = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    UsuarioRegistro = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    MontoVenta = table.Column<decimal>(type: "numeric", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MovimientoInventario", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovimientoInventario_Producto_ProductoId",
                        column: x => x.ProductoId,
                        principalTable: "Producto",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MovimientoInventario_Tiendas_TiendaDestinoId",
                        column: x => x.TiendaDestinoId,
                        principalTable: "Tiendas",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_MovimientoInventario_Tiendas_TiendaOrigenId",
                        column: x => x.TiendaOrigenId,
                        principalTable: "Tiendas",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Notificacions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ClienteId = table.Column<int>(type: "integer", nullable: false),
                    Tipo = table.Column<string>(type: "text", nullable: false),
                    Mensaje = table.Column<string>(type: "text", nullable: false),
                    Fecha = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Leida = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notificacions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Notificacions_Clientes_ClienteId",
                        column: x => x.ClienteId,
                        principalTable: "Clientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TiendaApps",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    TiendaId = table.Column<int>(type: "integer", nullable: false),
                    CedulaEncargado = table.Column<string>(type: "text", nullable: false),
                    EstadoDeComision = table.Column<string>(type: "text", nullable: false),
                    FechaRegistro = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ClienteId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TiendaApps", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TiendaApps_Clientes_ClienteId",
                        column: x => x.ClienteId,
                        principalTable: "Clientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TiendaApps_Tiendas_TiendaId",
                        column: x => x.TiendaId,
                        principalTable: "Tiendas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Creditos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MontoTotal = table.Column<decimal>(type: "numeric", nullable: false),
                    NombrePropietario = table.Column<string>(type: "text", nullable: true),
                    MontoPendiente = table.Column<decimal>(type: "numeric", nullable: false),
                    Entrada = table.Column<decimal>(type: "numeric", nullable: false),
                    PlazoCuotas = table.Column<int>(type: "integer", nullable: false),
                    FrecuenciaPago = table.Column<string>(type: "text", nullable: false),
                    DiaPago = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ValorPorCuota = table.Column<decimal>(type: "numeric", nullable: false),
                    TotalPagar = table.Column<decimal>(type: "numeric", nullable: false),
                    ProximaCuota = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Estado = table.Column<string>(type: "text", nullable: false),
                    Marca = table.Column<string>(type: "text", nullable: false),
                    Modelo = table.Column<string>(type: "text", nullable: false),
                    TipoProducto = table.Column<string>(type: "text", nullable: false),
                    Capacidad = table.Column<decimal>(type: "numeric", nullable: false),
                    IMEI = table.Column<string>(type: "text", nullable: true),
                    AbonadoTotal = table.Column<decimal>(type: "numeric", nullable: false),
                    AbonadoCuota = table.Column<decimal>(type: "numeric", nullable: false),
                    EstadoCuota = table.Column<string>(type: "text", nullable: false),
                    MetodoPago = table.Column<string>(type: "text", nullable: true),
                    FechaCreacion = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    ClienteId = table.Column<int>(type: "integer", nullable: false),
                    TiendaAppId = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Creditos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Creditos_Clientes_ClienteId",
                        column: x => x.ClienteId,
                        principalTable: "Clientes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Creditos_TiendaApps_TiendaAppId",
                        column: x => x.TiendaAppId,
                        principalTable: "TiendaApps",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "RegistrosPagos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    CreditoId = table.Column<int>(type: "integer", nullable: false),
                    MontoPagado = table.Column<decimal>(type: "numeric", nullable: false),
                    MetodoPago = table.Column<string>(type: "text", nullable: false),
                    FechaPago = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RegistrosPagos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RegistrosPagos_Creditos_CreditoId",
                        column: x => x.CreditoId,
                        principalTable: "Creditos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Menus",
                columns: new[] { "Id", "Icono", "Nombre", "Url" },
                values: new object[,]
                {
                    { 1, "dashboard", "DashBoard", "/pages/dashboard" },
                    { 2, "payments", "Pagos", "/pages/pagos" },
                    { 3, "person", "Usuario App", "/pages/usuarioApp" },
                    { 4, "admin_panel_settings", "Usuario Admin", "/pages/usuarioAdmin" },
                    { 5, "inventory", "Registrar Bodega", "/pages/bodega/registrar" },
                    { 6, "edit_attributes", "Editar Bodega", "/pages/bodega/editar" },
                    { 7, "storefront", "Registrar Tienda", "/pages/tienda/registrar" },
                    { 8, "history", "Movimientos", "/pages/movimientos" },
                    { 9, "assessment", "Reportes", "/pages/reportes" },
                    { 10, "location_on", "Ubicacion", "/pages/ubicacion" }
                });

            migrationBuilder.InsertData(
                table: "MenusAdmin",
                columns: new[] { "Id", "Icono", "Nombre", "Url" },
                values: new object[,]
                {
                    { 1, "dashboard", "Dashboard", "panel-control" },
                    { 2, "admin_panel_settings", "Usuarios Admin", "gestion-administradores" },
                    { 3, "how_to_reg", "Registro App Móvil", "registro-usuarios-app/nuevo" },
                    { 4, "payments", "Pagos", "gestion-pagos" },
                    { 5, "location_on", "Ubicación", "geolocalizacion-tiendas" },
                    { 6, "inventory", "Registrar Bodega", "inventario/registro-bodega" },
                    { 7, "edit_attributes", "Editar Bodega", "inventario/configuracion-bodega" },
                    { 8, "storefront", "Registrar Tienda", "gestion-tiendas/nueva-sucursal" },
                    { 9, "history", "Movimientos", "historial-movimientos" },
                    { 10, "assessment", "Reportes", "reportes-generales" }
                });

            migrationBuilder.InsertData(
                table: "Rol",
                columns: new[] { "Id", "Descripcion", "FechaRegistro" },
                values: new object[,]
                {
                    { 1, "Administrador", new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 2, "Cliente", new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 3, "Cajera", new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.InsertData(
                table: "RolesAdmin",
                columns: new[] { "Id", "Descripcion", "FechaRegistro" },
                values: new object[,]
                {
                    { 1, "Administrador", new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 2, "Cliente", new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { 3, "Cajera", new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.InsertData(
                table: "MenuRolAdmin",
                columns: new[] { "Id", "MenuAdminId", "RolAdminId" },
                values: new object[,]
                {
                    { 1, 1, 1 },
                    { 2, 2, 1 },
                    { 3, 3, 1 },
                    { 4, 4, 1 },
                    { 5, 5, 1 },
                    { 6, 6, 1 },
                    { 7, 7, 1 },
                    { 8, 8, 1 },
                    { 9, 9, 1 },
                    { 10, 10, 1 },
                    { 11, 1, 3 },
                    { 12, 3, 3 },
                    { 13, 4, 3 },
                    { 14, 6, 3 },
                    { 15, 8, 3 },
                    { 16, 9, 3 },
                    { 17, 10, 3 }
                });

            migrationBuilder.InsertData(
                table: "MenuRols",
                columns: new[] { "Id", "MenuId", "RolId" },
                values: new object[,]
                {
                    { 1, 1, 1 },
                    { 2, 2, 1 },
                    { 3, 3, 1 },
                    { 4, 4, 1 },
                    { 5, 5, 1 },
                    { 6, 6, 1 },
                    { 7, 7, 1 },
                    { 8, 8, 1 },
                    { 9, 9, 1 },
                    { 10, 10, 1 },
                    { 11, 1, 3 },
                    { 12, 2, 3 },
                    { 13, 3, 3 },
                    { 14, 5, 3 },
                    { 15, 7, 3 },
                    { 16, 8, 3 },
                    { 17, 9, 3 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Clientes_DetalleClienteID",
                table: "Clientes",
                column: "DetalleClienteID",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Clientes_UsuarioId",
                table: "Clientes",
                column: "UsuarioId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Creditos_ClienteId",
                table: "Creditos",
                column: "ClienteId");

            migrationBuilder.CreateIndex(
                name: "IX_Creditos_TiendaAppId",
                table: "Creditos",
                column: "TiendaAppId");

            migrationBuilder.CreateIndex(
                name: "IX_MenuRolAdmin_MenuAdminId",
                table: "MenuRolAdmin",
                column: "MenuAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_MenuRolAdmin_RolAdminId",
                table: "MenuRolAdmin",
                column: "RolAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_MenuRols_MenuId",
                table: "MenuRols",
                column: "MenuId");

            migrationBuilder.CreateIndex(
                name: "IX_MenuRols_RolId",
                table: "MenuRols",
                column: "RolId");

            migrationBuilder.CreateIndex(
                name: "IX_MovimientoInventario_ProductoId",
                table: "MovimientoInventario",
                column: "ProductoId");

            migrationBuilder.CreateIndex(
                name: "IX_MovimientoInventario_TiendaDestinoId",
                table: "MovimientoInventario",
                column: "TiendaDestinoId");

            migrationBuilder.CreateIndex(
                name: "IX_MovimientoInventario_TiendaOrigenId",
                table: "MovimientoInventario",
                column: "TiendaOrigenId");

            migrationBuilder.CreateIndex(
                name: "IX_Notificacions_ClienteId",
                table: "Notificacions",
                column: "ClienteId");

            migrationBuilder.CreateIndex(
                name: "IX_Producto_TiendaActualId",
                table: "Producto",
                column: "TiendaActualId");

            migrationBuilder.CreateIndex(
                name: "IX_RegistrosPagos_CreditoId",
                table: "RegistrosPagos",
                column: "CreditoId");

            migrationBuilder.CreateIndex(
                name: "IX_TiendaApps_ClienteId",
                table: "TiendaApps",
                column: "ClienteId");

            migrationBuilder.CreateIndex(
                name: "IX_TiendaApps_TiendaId",
                table: "TiendaApps",
                column: "TiendaId");

            migrationBuilder.CreateIndex(
                name: "IX_Usuarios_RolId",
                table: "Usuarios",
                column: "RolId");

            migrationBuilder.CreateIndex(
                name: "IX_UsuariosAdmin_RolAdminId",
                table: "UsuariosAdmin",
                column: "RolAdminId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EmailSettings");

            migrationBuilder.DropTable(
                name: "MenuRolAdmin");

            migrationBuilder.DropTable(
                name: "MenuRols");

            migrationBuilder.DropTable(
                name: "MovimientoInventario");

            migrationBuilder.DropTable(
                name: "Notificacions");

            migrationBuilder.DropTable(
                name: "RegistrosPagos");

            migrationBuilder.DropTable(
                name: "Ubicacions");

            migrationBuilder.DropTable(
                name: "UsuariosAdmin");

            migrationBuilder.DropTable(
                name: "VerificationCode");

            migrationBuilder.DropTable(
                name: "MenusAdmin");

            migrationBuilder.DropTable(
                name: "Menus");

            migrationBuilder.DropTable(
                name: "Producto");

            migrationBuilder.DropTable(
                name: "Creditos");

            migrationBuilder.DropTable(
                name: "RolesAdmin");

            migrationBuilder.DropTable(
                name: "TiendaApps");

            migrationBuilder.DropTable(
                name: "Clientes");

            migrationBuilder.DropTable(
                name: "Tiendas");

            migrationBuilder.DropTable(
                name: "DetallesCliente");

            migrationBuilder.DropTable(
                name: "Usuarios");

            migrationBuilder.DropTable(
                name: "Rol");
        }
    }
}
