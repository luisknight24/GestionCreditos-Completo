using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace GestionIntApi.Migrations
{
    /// <inheritdoc />
    public partial class nuevastablas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Producto_Tiendas_TiendaId",
                table: "Producto");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Producto",
                table: "Producto");

            migrationBuilder.RenameTable(
                name: "Producto",
                newName: "Productos");

            migrationBuilder.RenameIndex(
                name: "IX_Producto_TiendaId",
                table: "Productos",
                newName: "IX_Productos_TiendaId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Productos",
                table: "Productos",
                column: "Id");

            migrationBuilder.CreateTable(
                name: "MovimientosInventario",
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
                    table.PrimaryKey("PK_MovimientosInventario", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MovimientosInventario_Productos_ProductoId",
                        column: x => x.ProductoId,
                        principalTable: "Productos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MovimientosInventario_Tiendas_TiendaDestinoId",
                        column: x => x.TiendaDestinoId,
                        principalTable: "Tiendas",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_MovimientosInventario_Tiendas_TiendaOrigenId",
                        column: x => x.TiendaOrigenId,
                        principalTable: "Tiendas",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_MovimientosInventario_ProductoId",
                table: "MovimientosInventario",
                column: "ProductoId");

            migrationBuilder.CreateIndex(
                name: "IX_MovimientosInventario_TiendaDestinoId",
                table: "MovimientosInventario",
                column: "TiendaDestinoId");

            migrationBuilder.CreateIndex(
                name: "IX_MovimientosInventario_TiendaOrigenId",
                table: "MovimientosInventario",
                column: "TiendaOrigenId");

            migrationBuilder.AddForeignKey(
                name: "FK_Productos_Tiendas_TiendaId",
                table: "Productos",
                column: "TiendaId",
                principalTable: "Tiendas",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Productos_Tiendas_TiendaId",
                table: "Productos");

            migrationBuilder.DropTable(
                name: "MovimientosInventario");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Productos",
                table: "Productos");

            migrationBuilder.RenameTable(
                name: "Productos",
                newName: "Producto");

            migrationBuilder.RenameIndex(
                name: "IX_Productos_TiendaId",
                table: "Producto",
                newName: "IX_Producto_TiendaId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Producto",
                table: "Producto",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Producto_Tiendas_TiendaId",
                table: "Producto",
                column: "TiendaId",
                principalTable: "Tiendas",
                principalColumn: "Id");
        }
    }
}
