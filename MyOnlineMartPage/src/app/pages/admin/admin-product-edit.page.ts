import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { AdminService } from '../../core/api/admin.service';
import { AdminProduct } from '../../core/api/api.models';

@Component({
  selector: 'app-admin-product-edit-page',
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './admin-product-edit.page.html'
})
export class AdminProductEditPage {
  private readonly adminService = inject(AdminService);
  private readonly fb = inject(FormBuilder);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);

  readonly product = signal<AdminProduct | null>(null);
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

    this.adminService
      .getProduct(productId)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (product) => {
          this.product.set(product);
          this.productForm.reset({
            description: product.description,
            wholesalePrice: product.wholesalePrice,
            retailPrice: product.retailPrice,
            stockQuantity: product.stockQuantity
          });
        },
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Unable to load product.');
        }
      });
  }

  saveChanges() {
    const current = this.product();
    if (!current) {
      return;
    }

    if (this.productForm.invalid) {
      this.productForm.markAllAsTouched();
      return;
    }

    const value = this.productForm.getRawValue();
    this.isSaving.set(true);
    this.adminService
      .updateProduct(current.id, {
        description: value.description,
        wholesalePrice: Number(value.wholesalePrice),
        retailPrice: Number(value.retailPrice),
        stockQuantity: Number(value.stockQuantity)
      })
      .pipe(finalize(() => this.isSaving.set(false)))
      .subscribe({
        next: (updated) => {
          this.product.set(updated);
          this.router.navigate(['/admin/products', updated.id]);
        },
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Unable to update product.');
        }
      });
  }
}
