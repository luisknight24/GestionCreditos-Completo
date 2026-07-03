using GestionIntApi.Models;
using GestionIntApi.Repositorios.Interfaces;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class CodigoVerificacionService : ICodigoVerificacionService
    {

        private readonly Dictionary<string, VerificationCode> _codigos = new();

        public void GuardarCodigo(string correo, string codigo)
        {

            Console.WriteLine($"📩 [CODIGO] Guardando código {codigo} para {correo}");
            _codigos[correo] = new VerificationCode
            {
                Correo = correo,
                Codigo = codigo,
                Expira = DateTime.Now.AddMinutes(5)
            };

            Console.WriteLine($"📦 [CODIGO] Total códigos en memoria: {_codigos.Count}");
        }

        public bool ValidarCodigo(string correo, string codigo)
        {

            Console.WriteLine($"🔍 [CODIGO] Validando código {codigo} para {correo}");
            if (!_codigos.ContainsKey(correo))

            {
                Console.WriteLine("❌ [CODIGO] No existe código para ese correo");
                return false;

            }

               

            var data = _codigos[correo];


            if (data.Expira < DateTime.Now)
            {
                Console.WriteLine("⏰ [CODIGO] Código expirado");
                return false;

            }
            Console.WriteLine($"✅ [CODIGO] Código guardado: {data.Codigo}");
            return data.Codigo == codigo;
        }
    }
}
