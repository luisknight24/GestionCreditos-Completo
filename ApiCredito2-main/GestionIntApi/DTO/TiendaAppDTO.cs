namespace GestionIntApi.DTO
{
    public class TiendaAppDTO
    {
        public int Id { get; set; }

        // Se usa para validar que la tienda exista
        public string CedulaEncargado { get; set; }

        public string EstadoDeComision { get; set; }

        public DateTime FechaRegistro { get; set; }


        // Relación (la mantienes, no hay problema con JWT)
        public int ClienteId { get; set; }
    }
}
