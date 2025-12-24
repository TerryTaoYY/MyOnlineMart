import { Component, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { AdminService } from '../../core/api/admin.service';
import { BuyerService } from '../../core/api/buyer.service';
import { AdminProduct, BuyerProduct } from '../../core/api/api.models';
import { AuthService } from '../../core/auth/auth.service';

@Component({
  selector: 'app-product-detail-page',
  imports: [RouterLink],
  templateUrl: './product-detail.page.html'
})
export class ProductDetailPage {
  private readonly route = inject(ActivatedRoute);
  private readonly buyerService = inject(BuyerService);
  private readonly adminService = inject(AdminService);
  private readonly auth = inject(AuthService);

  readonly product = signal<AdminProduct | BuyerProduct | null>(null);
  readonly errorMessage = signal<string | null>(null);
  readonly isLoading = signal(false);
  readonly mode = signal<'buyer' | 'admin'>('buyer');

  readonly isAdmin = computed(() => this.mode() === 'admin');
  readonly adminProduct = computed(() =>
    this.isAdmin() ? (this.product() as AdminProduct | null) : null
  );

  constructor() {
    const routeMode = this.route.snapshot.data['mode'] as 'buyer' | 'admin' | undefined;
    const fallbackMode = this.auth.role() === 'ADMIN' ? 'admin' : 'buyer';
    this.mode.set(routeMode ?? fallbackMode);

    const productId = Number(this.route.snapshot.paramMap.get('productId'));
    if (!Number.isNaN(productId)) {
      this.loadProduct(productId);
    } else {
      this.errorMessage.set('Invalid product id.');
    }
  }

  loadProduct(productId: number) {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    const request = this.isAdmin()
      ? this.adminService.getProduct(productId)
      : this.buyerService.getProduct(productId);

    request.pipe(finalize(() => this.isLoading.set(false))).subscribe({
      next: (product) => this.product.set(product),
      error: (err) => {
        this.errorMessage.set(err?.error?.message ?? 'Unable to load product details.');
      }
    });
  }

  formatCurrency(value: number) {
    return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
  }
}
