import { Routes } from '@angular/router';
import { authGuard } from './core/auth/auth.guard';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'login' },
  {
    path: 'login',
    loadComponent: () => import('./pages/auth/auth.page').then((m) => m.AuthPage)
  },
  {
    path: 'buyer',
    pathMatch: 'full',
    redirectTo: 'buyer/products'
  },
  {
    path: 'buyer/products',
    canActivate: [authGuard],
    data: { role: 'BUYER' },
    loadComponent: () =>
      import('./pages/buyer/buyer-products.page').then((m) => m.BuyerProductsPage)
  },
  {
    path: 'buyer/orders',
    canActivate: [authGuard],
    data: { role: 'BUYER' },
    loadComponent: () => import('./pages/buyer/buyer-home.page').then((m) => m.BuyerHomePage)
  },
  {
    path: 'buyer/products/:productId',
    canActivate: [authGuard],
    data: { role: 'BUYER', mode: 'buyer' },
    loadComponent: () =>
      import('./pages/product/product-detail.page').then((m) => m.ProductDetailPage)
  },
  {
    path: 'buyer/orders/:orderId',
    canActivate: [authGuard],
    data: { role: 'BUYER', mode: 'buyer' },
    loadComponent: () =>
      import('./pages/order/order-detail.page').then((m) => m.OrderDetailPage)
  },
  {
    path: 'admin',
    canActivate: [authGuard],
    data: { role: 'ADMIN' },
    loadComponent: () => import('./pages/admin/admin-home.page').then((m) => m.AdminHomePage)
  },
  {
    path: 'admin/products',
    canActivate: [authGuard],
    data: { role: 'ADMIN' },
    loadComponent: () =>
      import('./pages/admin/admin-products.page').then((m) => m.AdminProductsPage)
  },
  {
    path: 'admin/products/:productId/edit',
    canActivate: [authGuard],
    data: { role: 'ADMIN' },
    loadComponent: () =>
      import('./pages/admin/admin-product-edit.page').then((m) => m.AdminProductEditPage)
  },
  {
    path: 'admin/products/:productId',
    canActivate: [authGuard],
    data: { role: 'ADMIN', mode: 'admin' },
    loadComponent: () =>
      import('./pages/product/product-detail.page').then((m) => m.ProductDetailPage)
  },
  {
    path: 'admin/orders',
    canActivate: [authGuard],
    data: { role: 'ADMIN' },
    loadComponent: () =>
      import('./pages/admin/admin-orders.page').then((m) => m.AdminOrdersPage)
  },
  {
    path: 'admin/orders/:orderId',
    canActivate: [authGuard],
    data: { role: 'ADMIN', mode: 'admin' },
    loadComponent: () =>
      import('./pages/order/order-detail.page').then((m) => m.OrderDetailPage)
  },
  { path: '**', redirectTo: 'login' }
];
