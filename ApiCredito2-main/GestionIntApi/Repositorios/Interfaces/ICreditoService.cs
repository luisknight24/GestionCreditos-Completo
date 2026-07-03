using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;

namespace GestionIntApi.Repositorios.Interfaces
{
    public interface ICreditoService
    {
        Task<List<PagoRealizadoDTO>> ListarPagosPorCredito(int creditoId);
        Task<List<CreditoDTO>> GetAllTiendas();
        Task<CreditoDTO> GetTiendaById(int id);
        Task<CreditoDTO> CreateCredito(CreditoDTO tiendaDto);
        Task<bool> UpdateCredito(CreditoDTO tiendaDto);
        Task<bool> DeleteCredito(int id);
        Task<bool> UpdateCreditoSoloDatos(CreditoDTO modelo);
        Task<PagarCreditoDTO> RegistrarPagoAsync(PagoCreditoDTO pago);

        Task<List<CreditoDTO>> GetCreditosPendientesPorCliente(int clienteId);
        Task<List<CreditoMostrarDTO>> GetCreditosPendientesPorCliente1(int clienteId);
        Task<List<CreditoMostrarDTO>> GetCreditosClienteApp(int clienteId);

        Task<List<HistoriaAppDTO>> GetCalendarioPagos(int creditoId, int clienteId);

        Task ActualizarEstadosCuotasAsync();


    }
}
