import { Component, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { AdminService } from '../../core/api/admin.service';
import {
  AdminOrder,
  AdminProduct,
  PopularProductSummary,
  ProfitSummary,
  TotalSoldSummary
} from '../../core/api/api.models';

@Component({
  selector: 'app-admin-home-page',
  imports: [RouterLink],
  templateUrl: './admin-home.page.html'
})
export class AdminHomePage {
  private readonly adminService = inject(AdminService);
  private readonly router = inject(Router);

  readonly orders = signal<AdminOrder[]>([]);
  readonly products = signal<AdminProduct[]>([]);
  readonly profitSummary = signal<ProfitSummary | null>(null);
  readonly popularProducts = signal<PopularProductSummary[]>([]);
  readonly totalSold = signal<TotalSoldSummary | null>(null);
  readonly errorMessage = signal<string | null>(null);
  readonly isLoading = signal(false);

  constructor() {
    this.loadData();
  }

  loadData() {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    this.adminService
      .getOrders(0)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (response) => this.orders.set(response.content ?? []),
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Unable to load orders.');
        }
      });

    this.adminService.getProducts().subscribe({
      next: (products) => this.products.set(products),
      error: (err) => {
        this.products.set([]);
        this.errorMessage.set(err?.error?.message ?? 'Unable to load products.');
      }
    });

    this.adminService.getProfitSummary().subscribe({
      next: (summary) => this.profitSummary.set(summary),
      error: () => this.profitSummary.set(null)
    });

    this.adminService.getPopularProducts().subscribe({
      next: (items) => this.popularProducts.set(items),
      error: () => this.popularProducts.set([])
    });

    this.adminService.getTotalSold().subscribe({
      next: (summary) => this.totalSold.set(summary),
      error: () => this.totalSold.set(null)
    });
  }

  viewOrder(orderId: number) {
    this.router.navigate(['/admin/orders', orderId]);
  }

  completeOrder(orderId: number) {
    this.adminService.completeOrder(orderId).subscribe({
      next: () => this.loadData(),
      error: (err) => {
        this.errorMessage.set(err?.error?.message ?? 'Unable to complete order.');
      }
    });
  }

  cancelOrder(orderId: number) {
    this.adminService.cancelOrder(orderId).subscribe({
      next: () => this.loadData(),
      error: (err) => {
        this.errorMessage.set(err?.error?.message ?? 'Unable to cancel order.');
      }
    });
  }

  formatDate(value: string) {
    return new Date(value).toLocaleString();
  }

  formatCurrency(value: number) {
    return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
  }
}
