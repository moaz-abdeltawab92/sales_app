# Odoo Sales Mobile Application

A Flutter mobile application built for enterprise sales teams. The application integrates with **Odoo ERP**, featuring offline-first capabilities with automatic data synchronization, Clean Architecture, BLoC state management, and a custom UI design.

---

## User Flow & Application Screenshots

| 1. Authentication | 2. Customer List (Home) | 3. Customer Details |
| :---: | :---: | :---: |
| <img src="Images/login.png" width="240" alt="Login Screen" /> | <img src="Images/home.png" width="240" alt="Customer List" /> | <img src="Images/customer_details.png" width="240" alt="Customer Details" /> |

| 4. Sales Orders List | 5. Sales Order Details |
| :---: | :---: |
| <img src="Images/sales_orders.png" width="240" alt="Sales Orders" /> | <img src="Images/sales_orders_details.png" width="240" alt="Sales Order Details" /> |

---

## Features & Functional Requirements

### 1. Authentication & Session Management
- **Odoo Credential Authentication**: Authenticates users against Odoo credentials (REST API with XML-RPC fallback architecture).
- **Role-Based Access Control**: Distinguishes between internal sales users (`base.group_user`) and standard users to conditionally grant access to sales order management.
- **Error Handling**: Displays feedback banners for invalid credentials or network failures.

### 2. Customer Management (`res.partner`)
- **Filtered Customer Querying**: Enforces strict Odoo domain filtering where `customer_rank > 0`.
- **Customer Overview**: Displays essential partner details: Name, Phone Number, and City.
- **Interactive Live Search**: Filter clients by name in real time.
- **Customer Profile**: Detailed view including Name, Phone, Email, and Address.
- **In-Place Phone Updating**: Allows updating customer phone numbers and saving changes back to Odoo.

### 3. Offline Handling & Auto-Sync (Bonus Requirement)
- **Local Data Caching**: Offline viewing of cached customers using persistent local storage (`SharedPreferences`).
- **Network Status Detection**: Real-time network monitoring via `connectivity_plus` with visual offline status indicator.
- **Pending Sync Queue**: Edits made offline are marked with a `Pending Sync` badge and stored locally.
- **Automatic Background Sync**: Pending updates automatically synchronize with Odoo once internet connection is restored.

### 4. Sales Orders Workflow (`sale.order`)
- **Sales Orders Dashboard**: Accessible to internal users (`base.group_user`). Displays Order Number, Customer Name, Order Date, Total Amount, and Status Badge (`Quotation` vs `Confirmed`).
- **Order Details**: Shows line items, quantities, unit prices, line subtotals, and total amounts.
- **Swipe-to-Confirm (`slide_to_act`)**: Slide gesture to convert draft quotations to confirmed sale orders, preventing accidental order confirmation in Odoo.
- **Visual Feedback**: Micro-interaction feedback upon successful order confirmation.

---

## Architecture & Project Structure

The project follows **Clean Architecture** with a **Feature-First Pattern** and **BLoC/Cubit** for state management. This ensures modularity, testability, and clear separation of business logic from the UI.

```
lib/
├── core/                         # Shared utilities, constants, & themes
│   ├── constants/                # App colors and styling tokens
│   ├── errors/                   # Exception and Failure definitions
│   ├── routing/                  # Navigation routes
│   ├── theme/                    # Material 3 theme configuration
│   ├── utils/                    # Date formatters & Skeleton loaders
│   └── widgets/                  # Reusable UI components
│
└── features/                     # Feature modules
    ├── auth/                     # Authentication
    │   ├── data/                 # Models, Data Sources, Repository Implementation
    │   ├── domain/               # Entities, Repository Interfaces, Use Cases
    │   └── presentation/         # Cubit, State, Pages
    │
    ├── customers/                # Customer Management
    │   ├── data/                 # Customer Model, Local/Remote Data Sources, Repository
    │   ├── domain/               # Customer Entity, Repository Interface, Use Cases
    │   └── presentation/         # Cubit, State, Pages, Widgets (CustomerCard)
    │
    └── sales_orders/             # Sales Orders
        ├── data/                 # Sales Order Model, Remote Data Source, Repository
        ├── domain/               # Sale Order & Line Entities, Use Cases
        └── presentation/         # Cubit, State, Pages, Widgets (SalesOrderCard, OrderStatusBadge)
```

---

## Design Decisions & Technical Rationale

| Design Decision | Technical Rationale |
| :--- | :--- |
| **Clean Architecture** | Decouples data sources from presentation. Data sources are defined as abstract contracts (`AuthRemoteDataSource`, `CustomerRemoteDataSource`), enabling seamless switching from mock data to live Odoo APIs without changing UI code. |
| **BLoC / Cubit Pattern** | Provides explicit state management (Loading, Empty, Loaded, Error, Saving, Success) and prevents unnecessary rebuilds using `Equatable`. |
| **Offline-First Repository** | Ensures usability when connection is weak or unavailable. Reads fall back to local cache, and writes queue locally until back online. |
| **Swipe-to-Confirm Gesture** | Confirming a Sales Order in Odoo changes system state and stock allocation. `SlideAction` requires deliberate user interaction to prevent accidental taps. |
| **Skeleton Loaders** | Replaces default spinners with layout-matching shimmer placeholders for smoother loading states. |

---

## Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.9.0`)
- **State Management**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) & [`equatable`](https://pub.dev/packages/equatable)
- **Persistence**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **Connectivity**: [`connectivity_plus`](https://pub.dev/packages/connectivity_plus)
- **UI Components**: [`slide_to_act`](https://pub.dev/packages/slide_to_act)

---

## Setup & Running the Project

### Prerequisites
- Flutter SDK (`3.19.0` or higher)
- Dart SDK (`3.3.0` or higher)

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/sales_app.git
   cd sales_app
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run static analysis:
   ```bash
   flutter analyze
   ```

4. Run the app:
   ```bash
   flutter run
   ```

---

## Odoo Integration Mapping

- **Partner Model (`res.partner`)**:
  - Filter: `[('customer_rank', '>', 0)]`
  - Mapped fields: `id`, `name`, `phone`, `email`, `city`, `street`
- **Sales Order Model (`sale.order`)**:
  - Action: `action_confirm` (transitions state from `draft` to `sale`)
