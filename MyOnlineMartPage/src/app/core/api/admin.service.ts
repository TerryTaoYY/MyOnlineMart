import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { map } from 'rxjs';
import { API_BASE_URL } from './api.config';
import {
  AdminOrder,
  AdminProduct,
  PagedResponse,
  PopularProductSummary,
  ProfitSummary,
  TotalSoldSummary
} from './api.models';

@Injectable({ providedIn: 'root' })
export class AdminService {
  private readonly http = inject(HttpClient);
  private readonly apiBase = inject(API_BASE_URL);

  getProducts() {
    return this.http.get<AdminProduct[]>(`${this.apiBase}/api/admin/products`);
  }

  createProduct(payload: Omit<AdminProduct, 'id'>) {
    return this.http.post<AdminProduct>(`${this.apiBase}/api/admin/products`, payload);
  }

  getProduct(productId: number) {
    return this.http.get<AdminProduct>(`${this.apiBase}/api/admin/products/${productId}`);
  }

  updateProduct(productId: number, payload: Partial<Omit<AdminProduct, 'id'>>) {
    return this.http.patch<AdminProduct>(
      `${this.apiBase}/api/admin/products/${productId}`,
      payload
    );
  }

  getOrders(page: number) {
    return this.http
      .get<PagedResponse<AdminOrder> | AdminOrder[]>(
        `${this.apiBase}/api/admin/orders?page=${page}`
      )
      .pipe(
        map((response) => (Array.isArray(response) ? { content: response } : response))
      );
  }

  getOrder(orderId: number) {
    return this.http.get<AdminOrder>(`${this.apiBase}/api/admin/orders/${orderId}`);
  }

  completeOrder(orderId: number) {
    return this.http.patch<AdminOrder>(`${this.apiBase}/api/admin/orders/${orderId}/complete`, {});
  }

  cancelOrder(orderId: number) {
    return this.http.patch<AdminOrder>(`${this.apiBase}/api/admin/orders/${orderId}/cancel`, {});
  }

  getProfitSummary() {
    return this.http.get<ProfitSummary>(`${this.apiBase}/api/admin/summary/profit`);
  }

  getPopularProducts() {
    return this.http.get<PopularProductSummary[]>(`${this.apiBase}/api/admin/summary/popular`);
  }

  getTotalSold() {
    return this.http.get<TotalSoldSummary>(`${this.apiBase}/api/admin/summary/total-sold`);
  }
}
