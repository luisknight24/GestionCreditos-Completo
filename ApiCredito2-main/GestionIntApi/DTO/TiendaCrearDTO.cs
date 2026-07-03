namespace GestionIntApi.DTO
{
    public class TiendaCrearDTO
    {
        public string NombreTienda { get; set; }
        public string NombreEncargado { get; set; }
        public string Telefono { get; set; }
        public string Direccion { get; set; }
        public string CodigoTienda { get; set; }

        // Opcional: logo como base64 o archivo
        public string? LogoBase64 { get; set; }
    }
}
