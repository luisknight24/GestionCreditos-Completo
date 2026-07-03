using AutoMapper;
using GestionIntApi.DTO;
using GestionIntApi.Models;
using GestionIntApi.Repositorios.Contrato;
using GestionIntApi.Repositorios.Interfaces;
using System;
using System.Collections.Generic;

namespace GestionIntApi.Repositorios.Implementacion
{
    public class DetalleClienteService : IDetalleClienteService
    {
        private readonly IGenericRepository<DetalleCliente> _DetalleRepositorio;
        private readonly IMapper _mapper;
        private readonly SistemaGestionDBcontext _context;

        public DetalleClienteService(IGenericRepository<DetalleCliente> usuarioRepositorio, IMapper mapper, SistemaGestionDBcontext sistemaGestionDBcontext)
        {
            _DetalleRepositorio = usuarioRepositorio;
            _mapper = mapper;
            _context = sistemaGestionDBcontext;

        }

        public async Task<List<DetalleClienteDTO>> GetAllDetalles()
        {
            try
            {
                var queryDetalle = await _DetalleRepositorio.Consultar();
                var listaDetalleCliente = queryDetalle.ToList();
            
                return _mapper.Map<List<DetalleClienteDTO>>(listaDetalleCliente);
            }
            catch
            {

                throw;
            }
        }

        public async Task<DetalleClienteDTO> GetDetalleById(int id)
        {
            try
            {
                var detalleEncontrado = await _DetalleRepositorio.Obtenerid(u => u.Id == id);


                if (detalleEncontrado == null)
                    throw new TaskCanceledException("Detalle de cliente no encontrado");
                return _mapper.Map<DetalleClienteDTO>(detalleEncontrado);
            }
            catch
            {
                throw;
            }
        }



        public async Task<DetalleClienteDTO> CreateDetalle(DetalleClienteDTO modelo)
        {
            try
            {




                var UsuarioCreado = await _DetalleRepositorio.Crear(_mapper.Map<DetalleCliente>(modelo));

                if (UsuarioCreado.Id == 0)
                    throw new TaskCanceledException("No se pudo Crear el detalle de cliente");

                return _mapper.Map<DetalleClienteDTO>(UsuarioCreado);
            }
            catch
            {
                throw;
            }
        }

        public async Task<bool> UpdateDetalle(DetalleClienteDTO modelo)
        {
            try
            {


                var DetlleModelo = _mapper.Map<DetalleClienteDTO>(modelo);

                var detalleClienteEncontrado = await _DetalleRepositorio.Obtener(u => u.Id == DetlleModelo.Id);
                if (detalleClienteEncontrado == null)
                    throw new TaskCanceledException("El detalle no existe");
               
                detalleClienteEncontrado.NumeroCedula = DetlleModelo.NumeroCedula;
                detalleClienteEncontrado.NombreApellidos = DetlleModelo.NombreApellidos;
                detalleClienteEncontrado.Telefono = DetlleModelo.Telefono;
                detalleClienteEncontrado.Direccion = DetlleModelo.Direccion;
            //    detalleClienteEncontrado.NombrePropietario = DetlleModelo.NombrePropietario;

                //detalleClienteEncontrado.FotoClienteUrl = DetlleModelo.FotoClienteUrl;
              //  detalleClienteEncontrado.FotoCelularEntregadoUrl = DetlleModelo.FotoCelularEntregadoUrl;
               // detalleClienteEncontrado.FotoContrato = DetlleModelo.FotoContrato;
                bool respuesta = await _DetalleRepositorio.Editar(detalleClienteEncontrado);
                return respuesta;
            }
            catch
            {
                throw;
            }
        }

        public async Task<bool> DeleteDetalle(int id)
        {
            try
            {
                var detalleEncontrado = await _DetalleRepositorio.Obtener(u => u.Id == id);
                if (detalleEncontrado == null)
                    throw new TaskCanceledException("Usuario no existe");
                bool respuesta = await _DetalleRepositorio.Eliminar(detalleEncontrado);
                return respuesta;
            }
            catch
            {
                throw;
            }



        }

        public async Task<bool> UpdateDetalleFotos(DetalleCLienteFotosDTO modelo)
        {
            try
            {
                var DetlleModelo = _mapper.Map<DetalleCLienteFotosDTO>(modelo);
                // Obtener el detalle existente
                var detalleClienteEncontrado = await _DetalleRepositorio.Obtener(u => u.Id == DetlleModelo.Id);
                if (detalleClienteEncontrado == null)
                    throw new TaskCanceledException("El detalle no existe");

                // Solo actualizar las fotos si vienen en el DTO
             //   if (!string.IsNullOrEmpty(modelo.FotoClienteUrl))
               //     detalleClienteEncontrado.FotoClienteUrl = modelo.FotoClienteUrl;

               // if (!string.IsNullOrEmpty(modelo.FotoCelularEntregadoUrl))
                 //   detalleClienteEncontrado.FotoCelularEntregadoUrl = modelo.FotoCelularEntregadoUrl;

                //if (!string.IsNullOrEmpty(modelo.FotoContrato))
                  //  detalleClienteEncontrado.FotoContrato = modelo.FotoContrato;

                // Guardar cambios
                bool respuesta = await _DetalleRepositorio.Editar(detalleClienteEncontrado);
                return respuesta;
            }
            catch
            {
                throw;
            }
        }


        public async Task<DetalleClienteDTO> GetDetalleByClienteId(int clienteId)
        {
            try
            {
                var detalleEncontrado = await _DetalleRepositorio.Obtener(d => d.Cliente.Id == clienteId);

                if (detalleEncontrado == null)
                    throw new TaskCanceledException("Detalle de cliente no encontrado");

                return _mapper.Map<DetalleClienteDTO>(detalleEncontrado);
            }
            catch
            {
                throw;
            }
        }

    }
}
