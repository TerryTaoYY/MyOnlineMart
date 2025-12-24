import { HttpClient } from '@angular/common/http';
import { Injectable, computed, inject, signal } from '@angular/core';
import { tap } from 'rxjs';
import { API_BASE_URL } from '../api/api.config';
import { AuthResponse, LoginRequest, RegisterRequest, UserRole } from '../api/api.models';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly apiBase = inject(API_BASE_URL);
  private readonly storageKey = 'my-online-mart.auth';
  private readonly userSignal = signal<AuthResponse | null>(this.readStoredUser());

  readonly user = this.userSignal.asReadonly();
  readonly role = computed(() => this.userSignal()?.role ?? null);
  readonly token = computed(() => this.userSignal()?.token ?? null);
  readonly isLoggedIn = computed(() => !!this.userSignal());

  login(payload: LoginRequest) {
    return this.http
      .post<AuthResponse>(`${this.apiBase}/api/auth/login`, payload)
      .pipe(tap((response) => this.setUser(response)));
  }

  register(payload: RegisterRequest) {
    return this.http
      .post<AuthResponse>(`${this.apiBase}/api/auth/register`, payload)
      .pipe(tap((response) => this.setUser(response)));
  }

  logout() {
    this.userSignal.set(null);
    localStorage.removeItem(this.storageKey);
  }

  hasRole(role: UserRole) {
    return this.role() === role;
  }

  private setUser(user: AuthResponse) {
    this.userSignal.set(user);
    localStorage.setItem(this.storageKey, JSON.stringify(user));
  }

  private readStoredUser(): AuthResponse | null {
    const raw = localStorage.getItem(this.storageKey);
    if (!raw) {
      return null;
    }

    try {
      return JSON.parse(raw) as AuthResponse;
    } catch {
      localStorage.removeItem(this.storageKey);
      return null;
    }
  }
}
