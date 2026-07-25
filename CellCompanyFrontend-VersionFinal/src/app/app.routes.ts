import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login';
import { authGuard } from './custom/auth.guard';

export const routes: Routes = [
    { path: '', redirectTo: 'login', pathMatch: 'full' },
    { path: 'login', component: LoginComponent },
    {
        path: 'pages',
        canActivate: [authGuard],
        loadChildren: () => import('./components/layout/layout.routes').then(m => m.LAYOUT_ROUTES)
    },
    { path: '**', redirectTo: 'login', pathMatch: 'full' }
];