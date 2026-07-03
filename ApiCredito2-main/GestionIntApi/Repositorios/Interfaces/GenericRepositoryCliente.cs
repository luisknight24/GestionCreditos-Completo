using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;
using Microsoft.EntityFrameworkCore;

namespace GestionIntApi.Repositorios.Interfaces
{
    public class GenericRepositoryCliente: IClienteRepository
    {
        private readonly SistemaGestionDBcontext _context;
        public GenericRepositoryCliente(SistemaGestionDBcontext context)
        {
            _context = context;
        }

        // Registrar Cliente
        public async Task<Cliente> Registrar(Cliente modelo)
        {
            _context.Clientes.Add(modelo);
            await _context.SaveChangesAsync();
            return modelo;
        }

        // Obtener TODOS los clientes con todas las relaciones
        public async Task<IEnumerable<Cliente>> ObtenerClientesCompletos()
        {
            return await _context.Clientes
                .Include(c => c.Usuario)
                .Include(c => c.DetalleCliente)
                .Include(c => c.TiendaApps)
                .Include(c => c.Creditos)
                .ToListAsync();
        }

        // Obtener SOLO UN CLIENTE con todas las relaciones
        public async Task<Cliente> ObtenerClienteId(int id)
        {
            return await _context.Clientes
                .Include(c => c.Usuario)
                .Include(c => c.DetalleCliente)
                .Include(c => c.TiendaApps)
                .Include(c => c.Creditos)
                .FirstOrDefaultAsync(c => c.Id == id);
        }

        // Editar Cliente
        public async Task<bool> Editar(Cliente modelo)
        {
            _context.Clientes.Update(modelo);
            return await _context.SaveChangesAsync() > 0;
        }

        public async Task<bool> Eliminar(Cliente clienteID)
        {
            try
            {
                _context.Set<Cliente>().Remove(clienteID);
                await _context.SaveChangesAsync();
                return true;
            }
            catch
            {
                throw;
            }
        }






    }

}

