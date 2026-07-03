using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface IUbicacionService
    {
        Task<UbicacionDTO> Registrar(double latitud, double longitud, int usuarioId);
        Task<List<UbicacionMostrarDTO>> ObtenerPorUsuario(int usuarioId);
        Task<UbicacionMostrarDTO> ObtenerUltima(int usuarioId);
        Task<List<UbicacionMostrarDTO>> ListarUltimasUbicaciones();
    }
}
