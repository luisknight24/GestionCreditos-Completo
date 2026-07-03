using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GestionIntApi.Migrations
{
    /// <inheritdoc />
    public partial class roles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "RolesAdmin",
                keyColumn: "Id",
                keyValue: 2);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "RolesAdmin",
                columns: new[] { "Id", "Descripcion", "FechaRegistro" },
                values: new object[] { 2, "Cliente", new DateTime(2025, 12, 12, 0, 0, 0, 0, DateTimeKind.Utc) });
        }
    }
}
