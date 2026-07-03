namespace GestionIntApi.Repositorios.Interfaces
{
    public interface ICodigoVerificacionService
    {
        void GuardarCodigo(string correo, string codigo);
        bool ValidarCodigo(string correo, string codigo);
    }
}
