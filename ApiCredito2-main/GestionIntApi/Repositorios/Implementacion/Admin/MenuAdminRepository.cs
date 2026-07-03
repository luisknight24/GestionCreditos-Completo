using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Models.Admin;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces.Admin;

namespace GestionIntApi.Repositorios.Implementacion.Admin
{
    public class MenuAdminRepository: IMenuAdminRepository
    {
        private readonly IGenericRepository<UsuarioAdmin> _UsuarioRepositorio;
        private readonly IGenericRepository<MenuRolAdmin> _MenuRolRepositorio;
        private readonly IGenericRepository<MenuAdmin> _MenuRepositorio;
        private readonly IMapper _mapper;
        public MenuAdminRepository(IGenericRepository<UsuarioAdmin> usuarioRepositorio, IGenericRepository<MenuRolAdmin> menuRolRepositorio, IGenericRepository<MenuAdmin> menuRepositorio, IMapper mapper)
        {
            _UsuarioRepositorio = usuarioRepositorio;
            _MenuRolRepositorio = menuRolRepositorio;
            _MenuRepositorio = menuRepositorio;
            _mapper = mapper;
        }
        public async Task<List<MenuAdminDto>> listaMenus(int usuarioId)
        {
            IQueryable<UsuarioAdmin> tbUsuario = await _UsuarioRepositorio.Consultar(u => u.Id == usuarioId);
            IQueryable<MenuRolAdmin> tbMenuRol = await _MenuRolRepositorio.Consultar();
            IQueryable<MenuAdmin> tbMenu = await _MenuRepositorio.Consultar();
            try
            {
                IQueryable<MenuAdmin> tbResultado = (from u in tbUsuario
                                                join mr in tbMenuRol on u.RolAdminId equals mr.RolAdminId
                                                join m in tbMenu on mr.MenuAdminId equals m.Id
                                                select m).AsQueryable();

                var listaMenus = tbResultado.ToList();
                return _mapper.Map<List<MenuAdminDto>>(listaMenus);
            }
            catch
            {
                throw;
            }
        }
    }
}
