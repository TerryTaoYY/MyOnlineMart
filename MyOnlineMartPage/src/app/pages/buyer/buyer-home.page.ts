import { Component, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { BuyerService } from '../../core/api/buyer.service';
import { BuyerOrderSummary, TopItem } from '../../core/api/api.models';

@Component({
  selector: 'app-buyer-home-page',
  imports: [RouterLink],
  templateUrl: './buyer-home.page.html'
})
export class BuyerHomePage {
  private readonly buyerService = inject(BuyerService);
  private readonly router = inject(Router);

  readonly orders = signal<BuyerOrderSummary[]>([]);
  readonly frequentItems = signal<TopItem[]>([]);
  readonly recentItems = signal<TopItem[]>([]);
  readonly errorMessage = signal<string | null>(null);
  readonly isLoading = signal(false);

  constructor() {
    this.loadData();
  }

  loadData() {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    this.buyerService
      .getOrders()
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (orders) => this.orders.set(orders),
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Failed to load orders.');
        }
      });

    this.buyerService.getTopFrequent().subscribe({
      next: (items) => this.frequentItems.set(items),
      error: () => {
        this.frequentItems.set([]);
      }
    });

    this.buyerService.getTopRecent().subscribe({
      next: (items) => this.recentItems.set(items),
      error: () => {
        this.recentItems.set([]);
      }
    });
  }

  viewOrder(orderId: number) {
    this.router.navigate(['/buyer/orders', orderId]);
  }

  cancelOrder(orderId: number) {
    this.buyerService.cancelOrder(orderId).subscribe({
      next: () => this.loadData(),
      error: (err) => {
        this.errorMessage.set(err?.error?.message ?? 'Unable to cancel this order.');
      }
    });
  }

  formatDate(value: string) {
    return new Date(value).toLocaleString();
  }
}
