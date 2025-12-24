import { Component, computed, inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from './core/auth/auth.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  readonly user = this.auth.user;
  readonly isLoggedIn = computed(() => !!this.user());
  readonly role = computed(() => this.user()?.role ?? null);

  logout() {
    this.auth.logout();
    this.router.navigateByUrl('/login');
  }
}
