using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GestionIntApi.Migrations
{
    /// <inheritdoc />
    public partial class rol : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "RolesAdmin",
                keyColumn: "Id",
                keyValue: 3,
                column: "Descripcion",
                value: "Cajero/a");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "RolesAdmin",
                keyColumn: "Id",
                keyValue: 3,
                column: "Descripcion",
                value: "Cajera");
        }
    }
}
