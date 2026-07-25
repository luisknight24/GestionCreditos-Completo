import { Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Sesion } from '../interfaces/sesion';

@Injectable({
  providedIn: 'root'
})
export class RolNavegacionService {

  constructor(private _snackBar: MatSnackBar) { }

  mostrarAlerta(mensaje: string, tipo: string) {
    this._snackBar.open(mensaje, tipo, {
      horizontalPosition: "end",
      verticalPosition: "top",
      duration: 3000
    });
  }

  guardarSesionUsuario(usuarioSeccion: Sesion) {
    localStorage.setItem("usuario", JSON.stringify(usuarioSeccion));
    if (usuarioSeccion.token) {
      localStorage.setItem("jwt_token", usuarioSeccion.token);
    }
  }

  obtenerSession(): Sesion | null {
    const dataCadena = localStorage.getItem("usuario");
    if (!dataCadena) return null;
    return JSON.parse(dataCadena);
  }

  obtenerToken(): string | null {
    return localStorage.getItem("jwt_token");
  }

  eliminarSession() {
    localStorage.removeItem("usuario");
    localStorage.removeItem("jwt_token");
  }
}