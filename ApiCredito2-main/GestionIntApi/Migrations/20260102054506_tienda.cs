using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GestionIntApi.Migrations
{
    /// <inheritdoc />
    public partial class tienda : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Producto_Tiendas_TiendaActualId",
                table: "Producto");

            migrationBuilder.RenameColumn(
                name: "TiendaActualId",
                table: "Producto",
                newName: "TiendaId");

            migrationBuilder.RenameIndex(
                name: "IX_Producto_TiendaActualId",
                table: "Producto",
                newName: "IX_Producto_TiendaId");

            migrationBuilder.AddForeignKey(
                name: "FK_Producto_Tiendas_TiendaId",
                table: "Producto",
                column: "TiendaId",
                principalTable: "Tiendas",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Producto_Tiendas_TiendaId",
                table: "Producto");

            migrationBuilder.RenameColumn(
                name: "TiendaId",
                table: "Producto",
                newName: "TiendaActualId");

            migrationBuilder.RenameIndex(
                name: "IX_Producto_TiendaId",
                table: "Producto",
                newName: "IX_Producto_TiendaActualId");

            migrationBuilder.AddForeignKey(
                name: "FK_Producto_Tiendas_TiendaActualId",
                table: "Producto",
                column: "TiendaActualId",
                principalTable: "Tiendas",
                principalColumn: "Id");
        }
    }
}
