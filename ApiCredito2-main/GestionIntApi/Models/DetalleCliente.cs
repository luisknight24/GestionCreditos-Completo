namespace GestionIntApi.Models
{
    public class DetalleCliente
    {
        public int Id { get; set; }

        public string NumeroCedula { get; set; }
        public string NombreApellidos { get; set; }

    //    public string? NombrePropietario { get; set; }

        public string Telefono { get; set; }
        public string Direccion { get; set; }

      //  public string FotoClienteUrl { get; set; }

        public Cliente Cliente { get; set; }
    }
}
