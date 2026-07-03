namespace GestionIntApi.DTO.Admin
{
    public class UbicacionMostrarDTO
    {
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; }
        public string CorreoUsuario { get; set; }
        public double Latitud { get; set; }
        public double Longitud { get; set; }
        public DateTime Fecha { get; set; }
    }
}
