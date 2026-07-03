using Microsoft.EntityFrameworkCore;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;
using System.Linq.Expressions;

namespace GestionIntApi.Repositorios.Interfaces
{
    public class GenericRepository<Tmodelo> : IGenericRepository<Tmodelo> where Tmodelo : class
    {
        private readonly SistemaGestionDBcontext _DbContext;
        public GenericRepository(SistemaGestionDBcontext dbContext)
        {
            _DbContext = dbContext;
        }
        public async Task<Tmodelo> Obtener(Expression<Func<Tmodelo, bool>> filtro)
        {
            try
            {
                Tmodelo modelo = await _DbContext.Set<Tmodelo>().FirstOrDefaultAsync(filtro);
                return modelo;
            }
            catch
            {
                throw;
            }
        }
        public async Task<Tmodelo> Crear(Tmodelo modelo)
        {
            try
            {
                _DbContext.Set<Tmodelo>().Add(modelo);
                await _DbContext.SaveChangesAsync();
                return modelo;
            }
            catch
            {
                throw;
            }
        }
        public async Task<bool> Editar(Tmodelo modelo)
        {
            try
            {
                _DbContext.Set<Tmodelo>().Update(modelo);
                await _DbContext.SaveChangesAsync();
                return true;
            }
            catch
            {
                throw;
            }
        }
        public async Task<bool> Eliminar(Tmodelo modelo)
        {
            try
            {
                _DbContext.Set<Tmodelo>().Remove(modelo);
                await _DbContext.SaveChangesAsync();
                return true;
            }
            catch
            {
                throw;
            }
        }
        public async Task<IQueryable<Tmodelo>> Consultar(Expression<Func<Tmodelo, bool>> filtro = null)
        {
            try
            {
                IQueryable<Tmodelo> queryModelo = filtro == null ? _DbContext.Set<Tmodelo>() : _DbContext.Set<Tmodelo>().Where(filtro);
                return queryModelo;
            }
            catch
            {
                throw;
            }
        }
        public async Task<IQueryable<Tmodelo>> Obtenerid(Expression<Func<Tmodelo, bool>> filtro)
        {
            try
            {
                IQueryable<Tmodelo> modelo = filtro == null ? _DbContext.Set<Tmodelo>() : _DbContext.Set<Tmodelo>().Where(filtro);
                return modelo;
            }
            catch
            {
                throw;
            }
        }
    }
}
