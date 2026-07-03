using System.ComponentModel.DataAnnotations;

namespace GestionIntApi.DTO
{
    public class DetalleCLienteFotosDTO
    {

        public int Id { get; set; }

        [Url(ErrorMessage = "La URL de la foto del cliente no es válida")]
        public string? FotoClienteUrl { get; set; }

        [Url(ErrorMessage = "La URL del contrato no es válida")]
        public string? FotoContrato { get; set; }

        [Url(ErrorMessage = "La URL de la foto del celular entregado no es válida")]
        public string? FotoCelularEntregadoUrl { get; set; }

    }
}
