import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { finalize } from 'rxjs';
import { AuthService } from '../../core/auth/auth.service';

@Component({
  selector: 'app-auth-page',
  imports: [ReactiveFormsModule],
  templateUrl: './auth.page.html',
  styleUrl: './auth.page.css'
})
export class AuthPage {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  readonly mode = signal<'login' | 'register'>('login');
  readonly errorMessage = signal<string | null>(null);
  readonly isBusy = signal(false);

  readonly loginForm = this.fb.nonNullable.group({
    usernameOrEmail: ['', Validators.required],
    password: ['', Validators.required]
  });

  readonly registerForm = this.fb.nonNullable.group({
    username: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required]
  });

  switchMode(mode: 'login' | 'register') {
    this.mode.set(mode);
    this.errorMessage.set(null);
  }

  submitLogin() {
    if (this.loginForm.invalid) {
      this.loginForm.markAllAsTouched();
      return;
    }

    this.isBusy.set(true);
    this.errorMessage.set(null);
    this.auth
      .login(this.loginForm.getRawValue())
      .pipe(finalize(() => this.isBusy.set(false)))
      .subscribe({
        next: (user) => {
          const target = user.role === 'ADMIN' ? '/admin' : '/buyer/products';
          this.router.navigateByUrl(target);
        },
        error: (err) => {
          this.errorMessage.set(err?.error?.message ?? 'Login failed. Please try again.');
        }
      });
  }

  submitRegister() {
    if (this.registerForm.invalid) {
      this.registerForm.markAllAsTouched();
      return;
    }

    this.isBusy.set(true);
    this.errorMessage.set(null);
    this.auth
      .register(this.registerForm.getRawValue())
      .pipe(finalize(() => this.isBusy.set(false)))
      .subscribe({
        next: (user) => {
          const target = user.role === 'ADMIN' ? '/admin' : '/buyer/products';
          this.router.navigateByUrl(target);
        },
        error: (err) => {
          this.errorMessage.set(
            err?.error?.message ?? 'Registration failed. Please check your details.'
          );
        }
      });
  }
}
