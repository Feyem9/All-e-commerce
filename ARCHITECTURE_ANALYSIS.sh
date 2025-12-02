#!/bin/bash

# ============================================================================
# 🏗️ E-COMMERCE APPLICATION - COMPLETE ARCHITECTURE ANALYSIS
# ============================================================================
# This document maps the entire project structure and identifies issues
# Generated: 2 décembre 2025
# ============================================================================

echo "
╔════════════════════════════════════════════════════════════════════════════╗
║                     E-COMMERCE APP ARCHITECTURE                           ║
║                    FRONTEND + BACKEND + DATABASE                          ║
╚════════════════════════════════════════════════════════════════════════════╝
"

# ============================================================================
# PART 1: PROJECT STRUCTURE
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. PROJECT DIRECTORY STRUCTURE                                              │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'
FullStackApp/
│
├── 📁 frontend/
│   └── E-COMMERCE_APP/                    # Angular 18 Application
│       ├── src/
│       │   ├── app/
│       │   │   ├── app.component.ts       # Root component
│       │   │   ├── app.module.ts          # Main module with imports
│       │   │   ├── app-routing.module.ts  # Route definitions
│       │   │   │
│       │   │   ├── 📁 navbar/             # Navigation component
│       │   │   │   ├── navbar.component.ts
│       │   │   │   ├── navbar.component.html
│       │   │   │   └── navbar.component.scss
│       │   │   │
│       │   │   ├── 📁 home/               # Home/Landing page
│       │   │   │   ├── home.component.ts
│       │   │   │   ├── home.component.html
│       │   │   │   └── home.component.scss
│       │   │   │
│       │   │   ├── 📁 product/            # Products listing
│       │   │   │   ├── product.component.ts
│       │   │   │   ├── product.component.html
│       │   │   │   └── product.component.scss
│       │   │   │
│       │   │   ├── 📁 cart/               # Shopping cart
│       │   │   │   ├── cart.component.ts
│       │   │   │   ├── cart.component.html
│       │   │   │   └── cart.component.scss
│       │   │   │
│       │   │   ├── 📁 customers/          # Authentication & User management
│       │   │   │   ├── auth.service.ts    # ⚠️ AUTH SERVICE (HAS INFINITE LOOP)
│       │   │   │   ├── 📁 login/
│       │   │   │   │   ├── login.component.ts
│       │   │   │   │   ├── login.component.html
│       │   │   │   │   └── login.component.scss
│       │   │   │   ├── 📁 register/
│       │   │   │   │   ├── register.component.ts
│       │   │   │   │   ├── register.component.html
│       │   │   │   │   └── register.component.scss
│       │   │   │   └── 📁 profile/
│       │   │   │       ├── profile.component.ts
│       │   │   │       ├── profile.component.html
│       │   │   │       └── profile.component.scss
│       │   │   │
│       │   │   ├── 📁 services/           # Business logic services
│       │   │   │   ├── api.service.ts     # HTTP client
│       │   │   │   ├── cart.service.ts    # ⚠️ CART SERVICE (INFINITE LOOP ISSUE)
│       │   │   │   └── ...
│       │   │   │
│       │   │   ├── 📁 service/
│       │   │   │   └── products.service.ts
│       │   │   │
│       │   │   ├── 📁 models/             # TypeScript interfaces
│       │   │   │   ├── products.ts
│       │   │   │   └── user.model.ts
│       │   │   │
│       │   │   ├── 📁 payment/            # Payment processing
│       │   │   ├── 📁 transaction/        # Order transactions
│       │   │   ├── 📁 favorite/           # Favorites/Wishlist
│       │   │   ├── 📁 categories/         # Product categories
│       │   │   ├── 📁 ordered/            # Order history
│       │   │   ├── 📁 help/               # Help/Support pages
│       │   │   └── 📁 guards/             # Route guards
│       │   │
│       │   ├── main.ts                    # Application entry point
│       │   └── styles.scss                # Global styles
│       │
│       ├── package.json                   # Dependencies
│       ├── angular.json                   # Angular configuration
│       ├── tsconfig.json                  # TypeScript configuration
│       └── server.ts                      # SSR server config
│
├── 📁 backend/
│   └── E-COMMERCE_APP/                    # Flask Python Application
│       ├── app.py                         # Main Flask app
│       ├── config.py                      # Configuration
│       ├── cloudinary_config.py          # Image storage config
│       │
│       ├── 📁 models/                     # Database models
│       │   ├── product_model.py
│       │   ├── customer_model.py
│       │   ├── cart_model.py
│       │   ├── order_model.py
│       │   ├── category_model.py
│       │   ├── transaction_model.py
│       │   └── favorite_model.py
│       │
│       ├── 📁 controllers/                # Business logic
│       │   ├── product_controller.py
│       │   ├── customer_controller.py
│       │   ├── cart_controller.py
│       │   ├── order_conttroller.py       # Note: typo in filename
│       │   └── ...
│       │
│       ├── 📁 routes/                     # API endpoints
│       │   ├── product_route.py
│       │   ├── customer_route.py
│       │   ├── cart_route.py
│       │   └── ...
│       │
│       ├── 📁 migrations/                 # Database migrations
│       ├── 📁 static/                     # Static files
│       ├── 📁 templates/                  # HTML templates
│       ├── 📁 utility/                    # Utility functions
│       ├── requirements.txt               # Python dependencies
│       └── populate_db.py                 # Database seeding
│
└── 📋 Documentation files
    ├── IMAGE_ACCESS_GUIDE.md
    ├── IMAGE_LOADING_SOLUTION.md
    ├── FINAL_SUMMARY.md
    └── ...

EOF

# ============================================================================
# PART 2: DATA FLOW ARCHITECTURE
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. DATA FLOW ARCHITECTURE                                                   │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'

USER INTERACTION FLOW
═════════════════════

1. PRODUCT BROWSING
   ┌──────────────────────┐
   │  User opens app      │
   │  http://localhost:4200
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────┐
   │ Angular loads        │
   │ Home Component       │
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────┐
   │ ProductsService      │
   │ calls API            │
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────────────┐
   │ Backend API                  │
   │ GET /product/                │
   │ (returns JSON with images)   │
   └──────────┬────────────────────┘
              │
              ▼
   ┌──────────────────────────────┐
   │ Cloudinary                   │
   │ Serves images               │
   │ res.cloudinary.com/...      │
   └──────────┬────────────────────┘
              │
              ▼
   ┌──────────────────────┐
   │  Products displayed  │
   │  with images         │
   └──────────────────────┘

2. SHOPPING CART FLOW ⚠️ (HAS INFINITE LOOP)
   ┌──────────────────────┐
   │ User clicks          │
   │ "Add to Cart"        │
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────┐
   │ CartService          │
   │ addToCart()          │
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────────────┐
   │ Backend API                  │
   │ POST /cart/add-to-cart/<id>  │
   └──────────┬────────────────────┘
              │
              ▼
   ┌──────────────────────────────┐
   │ getCartItems() called         │ ◄─────┐
   │ (subscribes to observable)   │       │
   │ updateCartState() emitted    │       │
   │ triggers loadCartItems()      │───────┘
   │ INFINITE LOOP DETECTED! ⚠️   │
   └──────────────────────────────┘

3. AUTHENTICATION FLOW ⚠️ (PARTIALLY FIXED)
   ┌──────────────────────┐
   │ User fills login     │
   │ form                 │
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────┐
   │ LoginComponent       │
   │ onSubmit()          │
   └──────────┬───────────┘
              │
              ▼
   ┌──────────────────────────────┐
   │ AuthService                  │
   │ login(payload)              │
   │ - Stores token in localStorage
   │ - Updates BehaviorSubjects   │
   └──────────┬────────────────────┘
              │
              ▼
   ┌──────────────────────┐
   │ User logged in ✓     │
   │ Redirected to        │
   │ /profile            │
   └──────────────────────┘

EOF

# ============================================================================
# PART 3: KEY FILES DETAILED ANALYSIS
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. KEY FILES ANALYSIS                                                       │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'

🔴 CRITICAL FILES WITH ISSUES:
═══════════════════════════════

A. auth.service.ts (PARTIALLY FIXED)
   Location: frontend/E-COMMERCE_APP/src/app/customers/auth.service.ts
   
   ISSUES FOUND:
   ✓ FIXED: getUserId() method had unmanaged subscription
   ✓ FIXED: BehaviorSubjects initialized with method calls
   
   Current Status: Partially safe, needs review
   
   Methods:
   - login(payload): ✓ Stores token, updates subjects
   - logout(): ✓ Clears storage, resets subjects
   - isAuthenticated(): ✓ Checks for token
   - getToken(): ✓ Safe access with SSR check
   - getUserId(): ✓ Now returns from BehaviorSubject value
   - profile(): ✓ Gets user profile with auth header

B. cart.service.ts (INFINITE LOOP CONFIRMED ⚠️)
   Location: frontend/E-COMMERCE_APP/src/app/services/cart.service.ts
   
   INFINITE LOOP ISSUE:
   ❌ loadCartItems() → getCartItems().subscribe()
   ❌ getCartItems() uses tap() to call updateCartState()
   ❌ updateCartState() triggers loadCartItems() again
   ❌ Creates cascading subscription loop
   
   Affected Methods:
   - initializeCart(): calls loadCartItems()
   - loadCartItems(): subscribes to getCartItems()
   - getCartItems(): uses tap() operator
   - addToCart(): calls getCartItems() after add
   - removeFromCart(): calls getCartItems() after remove
   - updateQuantity(): calls getCartItems() after update
   
   Impact: App freezes, 100% CPU usage

C. navbar.component.ts (PARTIALLY FIXED)
   Location: frontend/E-COMMERCE_APP/src/app/navbar/navbar.component.ts
   
   ISSUES FOUND:
   ✓ FIXED: Added OnDestroy with takeUntil
   ✓ FIXED: Proper subscription cleanup
   
   But still issues:
   ❌ Calls cartService.loadCartItems() in ngOnInit
   ❌ Triggers infinite loop on app start
   
   Current subscriptions:
   - cartCount$ (now unsubscribes)
   - isLoggedIn$ (now unsubscribes)
   - user$ (now unsubscribes)
   
   Status: Needs cartService fix

D. app.module.ts
   Location: frontend/E-COMMERCE_APP/src/app/app.module.ts
   
   Status: ✓ GOOD
   - No QRCodeModule (removed ✓)
   - CommonModule imported
   - FormsModule imported
   - ReactiveFormsModule imported
   - HttpClientModule imported
   - All components declared

E. api.service.ts
   Location: frontend/E-COMMERCE_APP/src/app/services/api.service.ts
   
   Status: ✓ GOOD
   - Proper error handling
   - SSR-safe with isPlatformBrowser check
   - Auth headers management
   - Retry logic on failures
   - Good error messages

EOF

# ============================================================================
# PART 4: INFINITE LOOP ROOT CAUSE
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. INFINITE LOOP ROOT CAUSE ANALYSIS                                        │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'

PROBLEM SEQUENCE:
════════════════

1. App Startup
   └─→ AppComponent loads
       └─→ NavbarComponent.ngOnInit() runs
           └─→ cartService.loadCartItems() called
               └─→ getCartItems().subscribe({ next: (items) => {...} })
                   └─→ tap() operator executes
                       └─→ updateCartState(items)
                           └─→ Updates cartItemsSubject
                               └─→ Updates cartCountSubject

2. Problem: CartService Constructor
   ┌─────────────────────────────────────────┐
   │ constructor() {                         │
   │   this.initializeCart();                │
   │ }                                       │
   │                                         │
   │ private initializeCart(): void {        │
   │   this.loadCartFromStorage();           │
   │   this.loadCartItems(); // ⚠️ LOOP!    │
   │ }                                       │
   │                                         │
   │ loadCartItems(): void {                 │
   │   this.getCartItems().subscribe({       │
   │     next: (items) => {                  │
   │       // Already handled in getCartItems
   │     }                                   │
   │   });                                   │
   │ }                                       │
   │                                         │
   │ getCartItems(): Observable<Cart[]> {   │
   │   return this.apiService.get(...)      │
   │     .pipe(                              │
   │       tap((items) => {                  │
   │         this.updateCartState(items); ◄─┼─ Updates subject
   │       }),                               │
   │       catchError(...),                  │
   │       finalize(...)                     │
   │     );                                  │
   │ }                                       │
   └─────────────────────────────────────────┘

3. Each Subscription Triggers New Update
   - NavbarComponent subscribes in ngOnInit
   - CartComponent subscribes to cartItems$
   - Each update triggers change detection
   - Change detection may trigger more subscriptions
   - Multiple API calls happening simultaneously

SEQUENCE OF CALLS:
==================

1st Call: 
  constructor → initializeCart() → loadCartItems() → subscribe()
  └─→ updateCartState() 
      └─→ Changes BehaviorSubject
          └─→ NavbarComponent gets notified
              └─→ Another loadCartItems() may be triggered

2nd Call (if navbar not yet loaded):
  NavbarComponent.ngOnInit() → loadCartItems() → subscribe()
  └─→ Another updateCartState()
      └─→ Another BehaviorSubject update
          └─→ More subscribers notified
              └─→ Potential for exponential subscriptions

VISUAL INFINITE LOOP:
═════════════════════

    ┌─────────────────────┐
    │ loadCartItems()     │
    │ called              │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ getCartItems()      │
    │ subscribes          │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ API Response        │
    │ tap() executes      │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ updateCartState()   │
    │ triggered           │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ BehaviorSubject     │
    │ .next() emits       │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ Component subscribes│
    │ or re-renders       │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │ loadCartItems()     │ ◄─────────┐
    │ called AGAIN        │           │
    └─────────────────────┘           │
                                      │
                └──────────────────────┘
                  (INFINITE LOOP!)

EOF

# ============================================================================
# PART 5: SOLUTIONS
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 5. SOLUTIONS TO FIX INFINITE LOOPS                                          │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'

SOLUTION 1: Remove loadCartItems() from Constructor
════════════════════════════════════════════════════

Current (WRONG):
  constructor() {
    this.initializeCart(); // Calls loadCartItems()
  }

Fixed:
  constructor() {
    this.loadCartFromStorage(); // Only load from storage
    // Don't call loadCartItems() here
  }

  ngOnInit() {  // In components that use this service
    // Only call once when needed
    this.cartService.getCartItems().subscribe(...);
  }

SOLUTION 2: Separate Subscribe and Update
═══════════════════════════════════════════

Current (WRONG):
  loadCartItems(): void {
    this.getCartItems().subscribe({
      next: (items) => {
        // Already updated in tap()
      }
    });
  }

Fixed:
  loadCartItems(): Observable<Cart[]> {
    return this.getCartItems(); // Return, don't subscribe
  }

  // Only subscribe when needed in components

SOLUTION 3: Prevent Duplicate Subscriptions
═════════════════════════════════════════════

Use shareReplay() operator:

  private cartItemsCache$ = this.apiService.get<Cart[]>('/cart/')
    .pipe(
      shareReplay(1), // Cache the result
      tap((items) => this.updateCartState(items)),
      catchError(error => {
        this.setError('Error loading cart');
        return of(this.cartItemsSubject.value);
      })
    );

  getCartItems(): Observable<Cart[]> {
    return this.cartItemsCache$; // Always return same cached observable
  }

SOLUTION 4: Use takeUntil for Subscriptions
════════════════════════════════════════════

  private destroy$ = new Subject<void>();

  ngOnInit(): void {
    this.cartService.cartCount$
      .pipe(takeUntil(this.destroy$))
      .subscribe(count => this.cartCount = count);
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

SOLUTION 5: Lazy Load Cart Items
═════════════════════════════════

Don't load cart on app startup:

  constructor(
    private http: HttpClient,
    private apiService: ApiService
  ) {
    // Don't call initializeCart()
  }

  loadCartItemsOnDemand(): void {
    // Only call when user navigates to cart or clicks cart icon
    this.getCartItems().subscribe(...);
  }

SUMMARY OF RECOMMENDED FIXES:
═════════════════════════════

1. ✓ Remove loadCartItems() call from cart service constructor
2. ✓ Make getCartItems() return Observable instead of subscribing
3. ✓ Add shareReplay() to cache API responses
4. ✓ Implement proper component cleanup with takeUntil
5. ✓ Only subscribe to cart items when actually needed
6. ✓ Use OnPush change detection strategy where possible

EOF

# ============================================================================
# PART 6: BACKEND ARCHITECTURE
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 6. BACKEND ARCHITECTURE (Flask)                                             │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'

FLASK APPLICATION STRUCTURE:
════════════════════════════

app.py
├─ Initializes Flask app
├─ Configures database (SQLAlchemy)
├─ Registers blueprints (routes)
├─ Sets up JWT authentication
└─ Enables CORS for Angular frontend

Database Models (SQLAlchemy ORM):
├─ Products
│  ├─ id (PK)
│  ├─ name
│  ├─ description
│  ├─ current_price
│  ├─ discount_price
│  ├─ quantity
│  └─ picture (Cloudinary URL) ✓
│
├─ Customers
│  ├─ id (PK)
│  ├─ email
│  ├─ name
│  ├─ password (hashed)
│  ├─ phone
│  ├─ address
│  └─ created_at
│
├─ Carts
│  ├─ id (PK)
│  ├─ customer_id (FK)
│  ├─ product_id (FK)
│  └─ quantity
│
├─ Orders
│  ├─ id (PK)
│  ├─ customer_id (FK)
│  ├─ total_price
│  ├─ status
│  └─ created_at
│
├─ Transactions
│  ├─ id (PK)
│  ├─ order_id (FK)
│  ├─ payment_method
│  └─ status
│
├─ Categories
│  ├─ id (PK)
│  └─ name
│
└─ Favorites
   ├─ id (PK)
   ├─ customer_id (FK)
   └─ product_id (FK)

API Routes/Endpoints:
════════════════════

PRODUCTS:
  GET  /product/                    # Get all products
  GET  /product/view-product/<id>   # Get single product
  POST /product/create              # Create product
  POST /product/update-product/<id> # Update product
  POST /product/delete-product/<id> # Delete product
  GET  /product/search              # Search products

CUSTOMERS/AUTH:
  POST /customer/register           # Register new user
  POST /customer/login              # Login user
  POST /customer/logout             # Logout user
  GET  /customer/profile            # Get user profile
  PUT  /customer/profile            # Update profile

CART:
  GET  /cart/                       # Get cart items
  POST /cart/add-to-cart/<id>       # Add item
  POST /cart/remove-from-cart/<id>  # Remove item
  POST /cart/update-quantity/<id>   # Update quantity
  POST /cart/clear                  # Clear cart

ORDERS:
  GET  /order/                      # Get all orders
  GET  /order/<id>                  # Get specific order
  POST /order/create                # Create order
  POST /order/update/<id>           # Update order

TRANSACTIONS:
  POST /transaction/initiate         # Start payment
  POST /transaction/confirm          # Confirm payment
  GET  /transaction/                 # Get transactions

CATEGORIES:
  GET  /categories/                 # Get all categories
  POST /category/create             # Create category

FAVORITES:
  GET  /favorite/                   # Get favorites
  POST /favorite/add/<id>           # Add to favorites
  POST /favorite/remove/<id>        # Remove from favorites

Cloudinary Integration:
═══════════════════════
cloudinary_config.py:
  - cloud_name: "dzqbzqgjw"         # Account ID
  - api_key: "398615211289795"
  - api_secret: (stored securely)
  
  Used for:
  ✓ Storing product images
  ✓ Generating URLs for display
  ✓ Image optimization and delivery

Database Connection:
════════════════════
config.py:
  - Database type: PostgreSQL or SQLite
  - Connection string: SQLALCHEMY_DATABASE_URI
  - Flask-Migrate for migrations
  - Flask-SQLAlchemy for ORM

EOF

# ============================================================================
# PART 7: ISSUES SUMMARY
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 7. COMPLETE ISSUES SUMMARY                                                  │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'

🔴 CRITICAL ISSUES:
═══════════════════

1. INFINITE LOOP IN CART SERVICE
   File: frontend/E-COMMERCE_APP/src/app/services/cart.service.ts
   
   Severity: CRITICAL ⚠️
   Status: NOT YET FIXED
   Impact: App freezes, 100% CPU usage
   
   Root Cause:
   - loadCartItems() subscribes to getCartItems()
   - getCartItems() uses tap() to emit updates
   - Updates trigger change detection
   - Change detection may trigger new subscriptions
   - Creates cascading infinite loop
   
   How to Fix:
   → Remove loadCartItems() from constructor
   → Return Observable instead of subscribing in service
   → Use shareReplay() for caching
   → Only subscribe in components with proper cleanup

2. NAVBAR CALLS loadCartItems()
   File: frontend/E-COMMERCE_APP/src/app/navbar/navbar.component.ts
   
   Severity: CRITICAL ⚠️
   Status: PARTIALLY FIXED
   Impact: Triggers infinite loop on app start
   
   Current Code:
   ngOnInit() {
     this.cartService.loadCartItems(); // ← This triggers infinite loop
   }
   
   How to Fix:
   → Remove this call or make it conditional
   → Only load cart when user interacts with it

🟠 HIGH PRIORITY ISSUES:
════════════════════════

3. SUBSCRIPTION CLEANUP
   File: All components with subscriptions
   
   Severity: HIGH
   Status: PARTIALLY FIXED (navbar done, others pending)
   
   Not implemented in:
   - cart.component.ts
   - product.component.ts
   - home.component.ts
   - Any component with .subscribe()
   
   Solution: Add OnDestroy with takeUntil to all

4. API BASE URL MISMATCH
   File: frontend/E-COMMERCE_APP/src/app/customers/auth.service.ts
   
   Severity: HIGH
   Issue: auth.service uses 'http://127.0.0.1:5000'
   But other services use 'https://e-commerce-app-1-islr.onrender.com'
   
   Impact: Auth requests may fail in production
   
   Fix: Standardize on production URL

🟡 MEDIUM PRIORITY ISSUES:
═════════════════════════

5. NO UNSUBSCRIBE IN AUTH SERVICE
   Need to implement OnDestroy for all auth subscriptions

6. POTENTIAL RACE CONDITIONS
   Multiple simultaneous API calls to cart endpoint
   May cause data inconsistency

7. ERROR HANDLING
   Some error cases not properly handled
   May cause silent failures

🟢 RESOLVED ISSUES:
═══════════════════

✓ QRCodeModule removed (was breaking Angular 18)
✓ Observable/Promise mismatch fixed in payment component
✓ SSR localStorage issues addressed
✓ BehaviorSubject initialization issues fixed
✓ getUserId() infinite subscription removed
✓ Navbar subscriptions now have proper cleanup

EOF

# ============================================================================
# PART 8: ACTION PLAN
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 8. ACTION PLAN TO FIX ALL ISSUES                                            │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'

PRIORITY ORDER:
═══════════════

STEP 1: Fix Cart Service Infinite Loop (TODAY)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files to modify:
  1. src/app/services/cart.service.ts
     - Remove loadCartItems() from constructor
     - Add shareReplay() to cache
     - Remove subscribe in loadCartItems

  2. src/app/navbar/navbar.component.ts
     - Remove loadCartItems() call from ngOnInit
     - Load cart only on demand

  3. src/app/cart/cart.component.ts
     - Load cart when component initializes
     - Add OnDestroy with takeUntil

Commands:
  cd frontend/E-COMMERCE_APP
  git pull origin front-end
  # Apply fixes below...
  git add -A
  git commit -m "Fix infinite loop in cart service"
  git push origin front-end

STEP 2: Fix API URL Consistency (1 hour)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files to modify:
  1. src/app/customers/auth.service.ts
     - Change: private readonly apiBase = 'http://127.0.0.1:5000'
     - To: private readonly apiBase = 'https://e-commerce-app-1-islr.onrender.com'
     - Or use environment configuration

STEP 3: Add Subscription Cleanup (2 hours)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Apply OnDestroy pattern to:
  - cart.component.ts
  - product.component.ts
  - home.component.ts
  - categories.component.ts
  - favorite.component.ts
  - order.component.ts
  - transaction.component.ts
  - profile.component.ts

Pattern:
  import { Subject } from 'rxjs';
  import { takeUntil } from 'rxjs/operators';

  export class MyComponent implements OnInit, OnDestroy {
    private destroy$ = new Subject<void>();

    ngOnInit() {
      this.service.data$
        .pipe(takeUntil(this.destroy$))
        .subscribe(data => { ... });
    }

    ngOnDestroy() {
      this.destroy$.next();
      this.destroy$.complete();
    }
  }

STEP 4: Testing (1 hour)
━━━━━━━━━━━━━━━━━━━━━━

Tests to perform:
  1. App loads without freezing
  2. Navigation works smoothly
  3. Cart operations work
  4. Login/Register works
  5. Product browsing works
  6. No memory leaks (DevTools)
  7. No console errors

STEP 5: Production Build (30 min)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  cd frontend/E-COMMERCE_APP
  ng build
  # Check for build errors
  # Verify dist/ folder

TOTAL ESTIMATED TIME: 5 hours

EOF

# ============================================================================
# PART 9: DEVELOPMENT GUIDE
# ============================================================================

echo "
┌─────────────────────────────────────────────────────────────────────────────┐
│ 9. DEVELOPMENT GUIDE & BEST PRACTICES                                       │
└─────────────────────────────────────────────────────────────────────────────┘
"

cat << 'EOF'

DEVELOPMENT COMMANDS:
═════════════════════

Start Development Server:
  cd frontend/E-COMMERCE_APP
  npm install
  ng serve

Build for Production:
  ng build

Build with SSR:
  ng build --ssr

Run Tests:
  ng test

Lint Code:
  ng lint

CODING STANDARDS:
═════════════════

1. Subscription Management:
   ✓ Always use takeUntil in subscriptions
   ✓ Implement OnDestroy for cleanup
   ✓ Use unsubscribe() as fallback

2. Error Handling:
   ✓ Handle API errors in all services
   ✓ Show user-friendly error messages
   ✓ Log errors to console for debugging

3. Component Structure:
   ✓ Keep components focused (single responsibility)
   ✓ Use services for data management
   ✓ Use RxJS operators for data transformation

4. Services:
   ✓ Return Observables, don't subscribe
   ✓ Use shareReplay() for caching
   ✓ Handle API errors gracefully

5. Type Safety:
   ✓ Use TypeScript interfaces for all models
   ✓ Avoid 'any' type
   ✓ Use strict mode in tsconfig.json

GIT WORKFLOW:
═════════════

Always work on 'front-end' branch:
  git checkout front-end
  git pull origin front-end
  # Make changes
  git add -A
  git commit -m "Fix: description"
  git push origin front-end

Then merge to master when ready:
  git checkout master
  git pull origin master
  git merge front-end
  git push origin master

DEBUGGING:
══════════

Browser DevTools:
  1. Open Developer Tools (F12)
  2. Go to Network tab
  3. Check API calls
  4. Go to Console for errors
  5. Use Debugger to step through code
  6. Check Application tab for localStorage

Angular DevTools:
  1. Install Angular DevTools extension
  2. Open DevTools → Angular tab
  3. Inspect components
  4. View change detection
  5. Check BehaviorSubjects state

Performance:
  1. Use Performance tab
  2. Record user interactions
  3. Identify bottlenecks
  4. Check for unnecessary re-renders

EOF

echo "
╔════════════════════════════════════════════════════════════════════════════╗
║                    ARCHITECTURE ANALYSIS COMPLETE                         ║
║                  Next: Apply fixes in priority order                       ║
╚════════════════════════════════════════════════════════════════════════════╝
"
