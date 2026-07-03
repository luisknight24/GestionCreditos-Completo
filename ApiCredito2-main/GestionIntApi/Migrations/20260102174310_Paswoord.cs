using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace GestionIntApi.Migrations
{
    /// <inheritdoc />
    public partial class Paswoord : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PasswordResetToken",
                table: "UsuariosAdmin",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ResetTokenExpires",
                table: "UsuariosAdmin",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PasswordResetToken",
                table: "UsuariosAdmin");

            migrationBuilder.DropColumn(
                name: "ResetTokenExpires",
                table: "UsuariosAdmin");
        }
    }
}
