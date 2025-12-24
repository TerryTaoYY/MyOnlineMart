import { Component, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { Observable, finalize } from 'rxjs';
import { AdminService } from '../../core/api/admin.service';
import { BuyerService } from '../../core/api/buyer.service';
import { AdminOrder, BuyerOrder } from '../../core/api/api.models';
import { AuthService } from '../../core/auth/auth.service';

@Component({
  selector: 'app-order-detail-page',
  imports: [RouterLink],
  templateUrl: './order-detail.page.html'
})
export class OrderDetailPage {
  private readonly route = inject(ActivatedRoute);
  private readonly buyerService = inject(BuyerService);
  private readonly adminService = inject(AdminService);
  private readonly auth = inject(AuthService);

  readonly order = signal<AdminOrder | BuyerOrder | null>(null);
  readonly errorMessage = signal<string | null>(null);
  readonly isLoading = signal(false);
  readonly mode = signal<'buyer' | 'admin'>('buyer');

  readonly isAdmin = computed(() => this.mode() === 'admin');
  readonly adminOrder = computed(() =>
    this.isAdmin() ? (this.order() as AdminOrder | null) : null
  );

  constructor() {
    const routeMode = this.route.snapshot.data['mode'] as 'buyer' | 'admin' | undefined;
    const fallbackMode = this.auth.role() === 'ADMIN' ? 'admin' : 'buyer';
    this.mode.set(routeMode ?? fallbackMode);

    const orderId = Number(this.route.snapshot.paramMap.get('orderId'));
    if (!Number.isNaN(orderId)) {
      this.loadOrder(orderId);
    } else {
      this.errorMessage.set('Invalid order id.');
    }
  }

  loadOrder(orderId: number) {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    const request: Observable<AdminOrder | BuyerOrder> = this.isAdmin()
      ? this.adminService.getOrder(orderId)
      : this.buyerService.getOrder(orderId);

    request.pipe(finalize(() => this.isLoading.set(false))).subscribe({
      next: (order: AdminOrder | BuyerOrder) => this.order.set(order),
      error: (err: unknown) => {
        this.errorMessage.set(this.resolveErrorMessage(err, 'Unable to load order details.'));
      }
    });
  }

  cancelOrder() {
    const current = this.order();
    if (!current) {
      return;
    }

    const request: Observable<AdminOrder | BuyerOrder> = this.isAdmin()
      ? this.adminService.cancelOrder(current.id)
      : this.buyerService.cancelOrder(current.id);

    request.subscribe({
      next: (order: AdminOrder | BuyerOrder) => this.order.set(order),
      error: (err: unknown) => {
        this.errorMessage.set(this.resolveErrorMessage(err, 'Unable to cancel this order.'));
      }
    });
  }

  refresh() {
    const current = this.order();
    if (!current) {
      return;
    }
    this.loadOrder(current.id);
  }

  completeOrder() {
    const current = this.order();
    if (!current || !this.isAdmin()) {
      return;
    }

    this.adminService.completeOrder(current.id).subscribe({
      next: (order: AdminOrder) => this.order.set(order),
      error: (err: unknown) => {
        this.errorMessage.set(this.resolveErrorMessage(err, 'Unable to complete this order.'));
      }
    });
  }

  productLink(productId: number) {
    return this.isAdmin() ? ['/admin/products', productId] : ['/buyer/products', productId];
  }

  formatCurrency(value: number) {
    return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
  }

  formatDate(value: string) {
    return new Date(value).toLocaleString();
  }

  private resolveErrorMessage(err: unknown, fallback: string) {
    if (typeof err === 'object' && err !== null) {
      const candidate = (err as { error?: { message?: string } }).error?.message;
      if (candidate) {
        return candidate;
      }
    }
    return fallback;
  }
}
