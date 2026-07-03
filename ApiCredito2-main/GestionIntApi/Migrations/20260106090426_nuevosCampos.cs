using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GestionIntApi.Migrations
{
    /// <inheritdoc />
    public partial class nuevosCampos : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "MenuRolAdmin",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.RenameColumn(
                name: "PrecioVenta",
                table: "Productos",
                newName: "PrecioVentaCredito");

            migrationBuilder.AddColumn<string>(
                name: "Comentario",
                table: "Tiendas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "ValorComision",
                table: "Tiendas",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "IMEI2",
                table: "Productos",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Observaciones",
                table: "Productos",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "PrecioVentaContado",
                table: "Productos",
                type: "numeric",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PropietarioDelProducto",
                table: "Productos",
                type: "text",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "RolesAdmin",
                keyColumn: "Id",
                keyValue: 3,
                column: "Descripcion",
                value: "Team");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Comentario",
                table: "Tiendas");

            migrationBuilder.DropColumn(
                name: "ValorComision",
                table: "Tiendas");

            migrationBuilder.DropColumn(
                name: "IMEI2",
                table: "Productos");

            migrationBuilder.DropColumn(
                name: "Observaciones",
                table: "Productos");

            migrationBuilder.DropColumn(
                name: "PrecioVentaContado",
                table: "Productos");

            migrationBuilder.DropColumn(
                name: "PropietarioDelProducto",
                table: "Productos");

            migrationBuilder.RenameColumn(
                name: "PrecioVentaCredito",
                table: "Productos",
                newName: "PrecioVenta");

            migrationBuilder.InsertData(
                table: "MenuRolAdmin",
                columns: new[] { "Id", "MenuAdminId", "RolAdminId" },
                values: new object[] { 11, 1, 3 });

            migrationBuilder.UpdateData(
                table: "RolesAdmin",
                keyColumn: "Id",
                keyValue: 3,
                column: "Descripcion",
                value: "Cajero/a");
        }
    }
}
