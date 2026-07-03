using AutoMapper;
using BCrypt.Net;
using GestionIntApi.DTO;
using GestionIntApi.Models;
using GestionIntApi.Repositorios;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces;
using Microsoft.AspNetCore.DataProtection.Repositories;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;


namespace GestionIntApi.Repositorios.Implementacion
{
    public class RolRepository: IRolRepository
    {

        private readonly IGenericRepository<Rol> _RolRepositorio;
        private readonly IMapper _mapper;

        public RolRepository(IGenericRepository<Rol> rolRepositorio, IMapper mapper)
        {
            _RolRepositorio = rolRepositorio;
            _mapper = mapper;
        }

        public async Task<List<RolDTO>> listaRoles()
        {
            try
            {
                var listaRoles = await _RolRepositorio.Consultar();
                return _mapper.Map<List<RolDTO>>(listaRoles.ToList());
            }
            catch
            {
                throw;
            }
        }
    }
}
