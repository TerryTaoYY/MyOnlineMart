import { Injectable, signal } from '@angular/core';
import { BuyerProduct, CartItem } from '../api/api.models';

@Injectable({ providedIn: 'root' })
export class CartService {
  private readonly itemsSignal = signal<CartItem[]>([]);
  readonly items = this.itemsSignal.asReadonly();

  addItem(product: BuyerProduct) {
    this.itemsSignal.update((items) => {
      const existing = items.find((item) => item.productId === product.id);
      if (existing) {
        return items.map((item) =>
          item.productId === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      }
      return [
        ...items,
        {
          productId: product.id,
          description: product.description,
          unitPrice: product.retailPrice,
          quantity: 1
        }
      ];
    });
  }

  updateQuantity(productId: number, quantity: number) {
    const safeQuantity = Math.max(1, Math.floor(quantity));
    this.itemsSignal.update((items) =>
      items.map((item) =>
        item.productId === productId ? { ...item, quantity: safeQuantity } : item
      )
    );
  }

  removeItem(productId: number) {
    this.itemsSignal.update((items) => items.filter((item) => item.productId !== productId));
  }

  clear() {
    this.itemsSignal.set([]);
  }

  total() {
    return this.itemsSignal()
      .reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);
  }
}
