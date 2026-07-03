using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.Repositorios.Contrato;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;

using GestionIntApi.Repositorios.Interfaces;
using GestionIntApi.Repositorios;
using GestionIntApi.Models;
using GestionIntApi.DTO;
using GestionIntApi.Models.Admin;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Repositorios.Interfaces.Admin;

namespace GestionIntApi.Repositorios.Implementacion.Admin
{
    public class RolAdminRepository : IRolAdminRepository
    {

        private readonly IGenericRepository<RolAdmin> _RolRepositorio;
        private readonly IMapper _mapper;

        public RolAdminRepository(IGenericRepository<RolAdmin> rolRepositorio, IMapper mapper)
        {
            _RolRepositorio = rolRepositorio;
            _mapper = mapper;
        }

        public async Task<List<RolAdminDto>> listaRoles()
        {
            try
            {
                var listaRoles = await _RolRepositorio.Consultar();
                return _mapper.Map<List<RolAdminDto>>(listaRoles.ToList());
            }
            catch
            {
                throw;
            }
        }
    }
}
