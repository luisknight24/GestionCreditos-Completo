using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.DTO.Admin;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Implementacion;
using GestionIntApi.Repositorios.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Globalization;

namespace GestionIntApi.Servicios.Implementacion
{
    public class UbicacionService : IUbicacionService
    {
        private readonly IUbicacionService _ubicacionRepository;
        private readonly IMapper _mapper;
        private readonly IGenericRepository<Ubicacion> _clienteRepository2;
        private readonly IGenericRepository<Usuario> _usuarioRepository;

        public UbicacionService(IGenericRepository<Usuario> usuarioRepositor, IGenericRepository<Ubicacion> clienteRepository2, IMapper mapper)
        {
            
            _mapper = mapper;
            _clienteRepository2 = clienteRepository2;
            _usuarioRepository = usuarioRepositor;

        }

        public async Task<UbicacionDTO> Registrar(double latitud, double longitud, int usuarioId)
        {
            try
            {
                var ubicacion = new Ubicacion
                {
                    Latitud = latitud,
                    Longitud = longitud,
                    UsuarioId = usuarioId,
                    Fecha = DateTime.UtcNow
                };

                var ubicacionCreada = await _clienteRepository2.Crear(ubicacion);

                if (ubicacionCreada.Id == 0)
                    throw new TaskCanceledException("No se pudo registrar la ubicación");

                return _mapper.Map<UbicacionDTO>(ubicacionCreada);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al registrar ubicación: {ex.Message}");
            }
        }

        public async Task<List<UbicacionMostrarDTO>> ObtenerPorUsuario(int usuarioId)
        {
            try
            {
                var query = await _clienteRepository2.Consultar(n => n.UsuarioId == usuarioId);
                var lista = await query.OrderByDescending(n => n.Fecha).ToListAsync();

                // Mapear a DTO
                return _mapper.Map<List<UbicacionMostrarDTO>>(lista);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al obtener ubicaciones del usuario {usuarioId}: {ex.Message}");
            }
        }

        public async Task<UbicacionMostrarDTO> ObtenerUltima(int usuarioId)
        {
            try
            {
                // 1. Buscas la última ubicación (como ya lo hacías)
                var query = await _clienteRepository2.Consultar(n => n.UsuarioId == usuarioId);
                var ultima = await query.OrderByDescending(n => n.Fecha).FirstOrDefaultAsync();

                if (ultima == null) return null;

                // 2. Mapeas los datos básicos (Latitud, Longitud, etc.)
                var dto = _mapper.Map<UbicacionMostrarDTO>(ultima);

                // 3. BUSQUEDA MANUAL: Obtienes los datos del usuario por separado
                var usuario = await _usuarioRepository.Obtener(u => u.Id == usuarioId);

                if (usuario != null)
                {
                    // 4. Llenas los campos faltantes del DTO
                    dto.NombreUsuario = usuario.NombreApellidos; // o usuario.NombreApellidos
                    dto.CorreoUsuario = usuario.Correo;
                }

                return dto;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error: {ex.Message}");
            }
        }

        public async Task<List<UbicacionMostrarDTO>> ListarUltimasUbicaciones()
        {
            try
            {
                // 1. Obtener todas las ubicaciones y agrupar por UsuarioId
                var queryUbicaciones = await _clienteRepository2.Consultar();

                // 2. Usamos LINQ para obtener solo la última de cada grupo
                var ultimasUbicacionesList = await queryUbicaciones
                    .GroupBy(u => u.UsuarioId)
                    .Select(g => g.OrderByDescending(x => x.Fecha).FirstOrDefault())
                    .ToListAsync();

                if (ultimasUbicacionesList == null || !ultimasUbicacionesList.Any())
                    return new List<UbicacionMostrarDTO>();

                // 3. Obtener todos los usuarios de una sola vez para no hacer mil consultas
                var idsUsuarios = ultimasUbicacionesList.Select(u => u.UsuarioId).Distinct().ToList();
                var queryUsuarios = await _usuarioRepository.Consultar(u => idsUsuarios.Contains(u.Id));
                var usuarios = await queryUsuarios.ToListAsync();

                // 4. Mapear y combinar manualmente
                var listaResultado = ultimasUbicacionesList.Select(ubi =>
                {
                    var user = usuarios.FirstOrDefault(u => u.Id == ubi.UsuarioId);
                    var dto = _mapper.Map<UbicacionMostrarDTO>(ubi);

                    if (user != null)
                    {
                        dto.NombreUsuario = user.NombreApellidos;
                        dto.CorreoUsuario = user.Correo;
                    }

                    return dto;
                }).ToList();

                return listaResultado;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error al listar últimas ubicaciones: {ex.Message}");
            }
        }


    }
}