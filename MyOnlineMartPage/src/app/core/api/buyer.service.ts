import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { API_BASE_URL } from './api.config';
import {
  BuyerOrder,
  BuyerOrderCreateRequest,
  BuyerOrderSummary,
  BuyerProduct,
  TopItem
} from './api.models';

@Injectable({ providedIn: 'root' })
export class BuyerService {
  private readonly http = inject(HttpClient);
  private readonly apiBase = inject(API_BASE_URL);

  getProducts() {
    return this.http.get<BuyerProduct[]>(`${this.apiBase}/api/buyer/products`);
  }

  getProduct(productId: number) {
    return this.http.get<BuyerProduct>(`${this.apiBase}/api/buyer/products/${productId}`);
  }

  createOrder(payload: BuyerOrderCreateRequest) {
    return this.http.post<BuyerOrder>(`${this.apiBase}/api/buyer/orders`, payload);
  }

  getOrders() {
    return this.http.get<BuyerOrderSummary[]>(`${this.apiBase}/api/buyer/orders`);
  }

  getOrder(orderId: number) {
    return this.http.get<BuyerOrder>(`${this.apiBase}/api/buyer/orders/${orderId}`);
  }

  cancelOrder(orderId: number) {
    return this.http.patch<BuyerOrder>(`${this.apiBase}/api/buyer/orders/${orderId}/cancel`, {});
  }

  getTopFrequent() {
    return this.http.get<TopItem[]>(`${this.apiBase}/api/buyer/orders/top/frequent`);
  }

  getTopRecent() {
    return this.http.get<TopItem[]>(`${this.apiBase}/api/buyer/orders/top/recent`);
  }

  addToWatchlist(productId: number) {
    return this.http.post<void>(`${this.apiBase}/api/buyer/watchlist/${productId}`, {});
  }

  removeFromWatchlist(productId: number) {
    return this.http.delete<void>(`${this.apiBase}/api/buyer/watchlist/${productId}`);
  }

  getWatchlist() {
    return this.http.get<BuyerProduct[]>(`${this.apiBase}/api/buyer/watchlist`);
  }
}
