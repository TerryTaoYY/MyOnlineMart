import { Component, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { AdminService } from '../../core/api/admin.service';
import { AdminOrder } from '../../core/api/api.models';

@Component({
  selector: 'app-admin-orders-page',
  templateUrl: './admin-orders.page.html'
})
export class AdminOrdersPage {
  private readonly adminService = inject(AdminService);
  private readonly router = inject(Router);

  readonly orders = signal<AdminOrder[]>([]);
  readonly errorMessage = signal<string | null>(null);
  readonly isLoading = signal(false);

  constructor() {
    this.loadOrders();
  }

  loadOrders() {
    this.isLoading.set(true);
    this.errorMessage.set(null);
    const collected: AdminOrder[] = [];
    const seen = new Set<number>();

    const loadPage = (page: number) => {
      this.adminService.getOrders(page).subscribe({
        next: (response) => {
          const batch = response.content ?? [];
          const fresh = batch.filter((order) => !seen.has(order.id));
          fresh.forEach((order) => seen.add(order.id));

          if (fresh.length > 0) {
            collected.push(...fresh);
            this.orders.set([...collected]);
          }

          if (batch.length === 0 || fresh.length === 0) {
            this.orders.set(collected);
            this.isLoading.set(false);
            return;
          }

          loadPage(page + 1);
        },
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Unable to load orders.');
          this.isLoading.set(false);
        }
      });
    };

    loadPage(0);
  }

  viewOrder(orderId: number) {
    this.router.navigate(['/admin/orders', orderId]);
  }

  completeOrder(orderId: number) {
    this.adminService.completeOrder(orderId).subscribe({
      next: () => this.loadOrders(),
      error: (err) => {
        this.errorMessage.set(err?.error?.message ?? 'Unable to complete order.');
      }
    });
  }

  cancelOrder(orderId: number) {
    this.adminService.cancelOrder(orderId).subscribe({
      next: () => this.loadOrders(),
      error: (err) => {
        this.errorMessage.set(err?.error?.message ?? 'Unable to cancel order.');
      }
    });
  }

  formatDate(value: string) {
    return new Date(value).toLocaleString();
  }
}
