import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { AdminService } from '../../core/api/admin.service';
import { AdminProduct } from '../../core/api/api.models';

@Component({
  selector: 'app-admin-products-page',
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './admin-products.page.html'
})
export class AdminProductsPage {
  private readonly adminService = inject(AdminService);
  private readonly fb = inject(FormBuilder);

  readonly products = signal<AdminProduct[]>([]);
  readonly errorMessage = signal<string | null>(null);
  readonly isLoading = signal(false);
  readonly isSaving = signal(false);

  readonly productForm = this.fb.nonNullable.group({
    description: ['', Validators.required],
    wholesalePrice: [0, [Validators.required, Validators.min(0)]],
    retailPrice: [0, [Validators.required, Validators.min(0)]],
    stockQuantity: [0, [Validators.required, Validators.min(0)]]
  });

  constructor() {
    this.loadProducts();
  }

  loadProducts() {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    this.adminService
      .getProducts()
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (products) => this.products.set(products),
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Unable to load products.');
        }
      });
  }

  createProduct() {
    if (this.productForm.invalid) {
      this.productForm.markAllAsTouched();
      return;
    }

    const value = this.productForm.getRawValue();
    this.isSaving.set(true);
    this.adminService
      .createProduct({
        description: value.description,
        wholesalePrice: Number(value.wholesalePrice),
        retailPrice: Number(value.retailPrice),
        stockQuantity: Number(value.stockQuantity)
      })
      .pipe(finalize(() => this.isSaving.set(false)))
      .subscribe({
        next: () => {
          this.productForm.reset({
            description: '',
            wholesalePrice: 0,
            retailPrice: 0,
            stockQuantity: 0
          });
          this.loadProducts();
        },
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Unable to create product.');
        }
      });
  }

  formatCurrency(value: number) {
    return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
  }
}
