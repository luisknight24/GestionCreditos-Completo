using GestionIntApi.DTO;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface IReporteService
    {
        Task<List<ReporteDTO>> ObtenerReporte(string fechaInicio,
    string fechaFin);
        Task<byte[]> ExportarReporteExcel(
   string fechaInicio,
   string fechaFin
);
    }
}
