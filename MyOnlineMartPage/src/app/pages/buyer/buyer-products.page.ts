import { Component, computed, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { BuyerService } from '../../core/api/buyer.service';
import { BuyerProduct } from '../../core/api/api.models';
import { CartService } from '../../core/cart/cart.service';

@Component({
  selector: 'app-buyer-products-page',
  imports: [RouterLink],
  templateUrl: './buyer-products.page.html'
})
export class BuyerProductsPage {
  private readonly buyerService = inject(BuyerService);
  private readonly cart = inject(CartService);
  private readonly router = inject(Router);

  readonly products = signal<BuyerProduct[]>([]);
  readonly watchlist = signal<BuyerProduct[]>([]);
  readonly errorMessage = signal<string | null>(null);
  readonly isLoading = signal(false);
  readonly isPlacing = signal(false);

  readonly cartItems = this.cart.items;
  readonly cartTotal = computed(() => this.cart.total());

  constructor() {
    this.loadProducts();
    this.loadWatchlist();
  }

  loadProducts() {
    this.isLoading.set(true);
    this.errorMessage.set(null);
    this.buyerService
      .getProducts()
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (products) => this.products.set(products),
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Unable to load products.');
        }
      });
  }

  loadWatchlist() {
    this.buyerService.getWatchlist().subscribe({
      next: (items) => this.watchlist.set(items),
      error: () => this.watchlist.set([])
    });
  }

  addToCart(product: BuyerProduct) {
    this.cart.addItem(product);
  }

  addToWatchlist(productId: number) {
    this.buyerService.addToWatchlist(productId).subscribe({
      next: () => this.loadWatchlist(),
      error: (err) => {
        this.errorMessage.set(err?.error?.message ?? 'Unable to update watchlist.');
      }
    });
  }

  removeFromWatchlist(productId: number) {
    this.buyerService.removeFromWatchlist(productId).subscribe({
      next: () => this.loadWatchlist(),
      error: (err) => {
        this.errorMessage.set(err?.error?.message ?? 'Unable to update watchlist.');
      }
    });
  }

  updateQuantity(productId: number, event: Event) {
    const value = Number((event.target as HTMLInputElement).value);
    if (Number.isNaN(value)) {
      return;
    }
    this.cart.updateQuantity(productId, value);
  }

  removeFromCart(productId: number) {
    this.cart.removeItem(productId);
  }

  placeOrder() {
    const items = this.cartItems().map((item) => ({
      productId: item.productId,
      quantity: item.quantity
    }));

    if (items.length === 0) {
      this.errorMessage.set('Add items to your cart before placing an order.');
      return;
    }

    this.isPlacing.set(true);
    this.errorMessage.set(null);
    this.buyerService
      .createOrder({ items })
      .pipe(finalize(() => this.isPlacing.set(false)))
      .subscribe({
        next: (order) => {
          this.cart.clear();
          this.router.navigate(['/buyer/orders', order.id]);
        },
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Unable to place order.');
        }
      });
  }

  formatCurrency(value: number) {
    return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
  }
}
