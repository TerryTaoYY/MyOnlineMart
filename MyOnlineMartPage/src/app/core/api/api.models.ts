export type UserRole = 'BUYER' | 'ADMIN';

export interface AuthResponse {
  token: string;
  role: UserRole;
  username: string;
  userId: number;
}

export interface LoginRequest {
  usernameOrEmail: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  email: string;
  password: string;
}

export interface BuyerProduct {
  id: number;
  description: string;
  retailPrice: number;
}

export interface AdminProduct extends BuyerProduct {
  wholesalePrice: number;
  stockQuantity: number;
}

export type OrderStatus = 'PROCESSING' | 'COMPLETED' | 'CANCELED';

export interface OrderStatusUpdate {
  orderId: number;
  status: OrderStatus;
}

export interface OrderItem {
  productId: number;
  description: string;
  quantity: number;
  unitRetailPrice: number;
}

export interface BuyerOrder {
  id: number;
  placedAt: string;
  status: OrderStatus;
  items: OrderItem[];
}

export interface BuyerOrderSummary {
  id: number;
  placedAt: string;
  status: OrderStatus;
}

export interface BuyerOrderCreateRequest {
  items: Array<{ productId: number; quantity: number }>;
}

export interface CartItem {
  productId: number;
  description: string;
  unitPrice: number;
  quantity: number;
}

export interface TopItem {
  productId: number;
  description?: string;
  totalQuantity?: number;
  lastPurchasedAt?: string;
}

export interface AdminOrderItem extends OrderItem {
  unitWholesalePrice?: number;
}

export interface AdminOrder {
  id: number;
  placedAt: string;
  status: OrderStatus;
  buyerUsername?: string;
  items?: AdminOrderItem[];
}

export interface PagedResponse<T> {
  content: T[];
  number?: number;
  totalPages?: number;
  totalElements?: number;
}

export interface ProfitSummary {
  productId?: number;
  description?: string;
  totalProfit?: number;
}

export interface PopularProductSummary {
  productId?: number;
  description?: string;
  totalQuantity?: number;
}

export interface TotalSoldSummary {
  totalItems?: number;
}
