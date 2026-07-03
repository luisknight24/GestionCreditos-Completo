using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.Models
{
    public class Menu
    {
        public int Id { get; set; }
        public string? Nombre { get; set; }
        public string? Icono { get; set; }
        public string? Url { get; set; }
        public ICollection<MenuRol> MenuRols { get; set; }

    }
}
