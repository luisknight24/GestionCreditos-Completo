import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';

export const authGuard: CanActivateFn = (route, state) => {
  const token = localStorage.getItem('jwt_token');
  const router = inject(Router);

  if (token) {
    return true;
  }

  router.navigate(['/login']);
  return false;
};
