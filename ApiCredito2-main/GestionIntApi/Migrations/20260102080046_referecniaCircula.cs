using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace GestionIntApi.Migrations
{
    /// <inheritdoc />
    public partial class referecniaCircula : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MovimientoInventario");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "MovimientoInventario",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    ProductoId = table.Column<int>(type: "integer", nullable: false),
                    TiendaDestinoId = table.Column<int>(type: "integer", nullable: true),
                    TiendaOrigenId = table.Column<int>(type: "integer", nullable: true),
                    FechaMovimiento = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    MontoVenta = table.Column<decimal>(type: "numeric", nullable: true),
                    Observacion = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    TipoMovimiento = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    UsuarioRegistro = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true)
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
        }
    }
}
