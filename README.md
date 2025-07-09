# PitStop Admin

PitStop is a Flutter-based admin application designed to manage service bookings, customers, mechanics, and services for an automotive service business.

## Features

- User authentication with login and registration.
- Admin dashboard with navigation to various data management pages.
- Customer management: View and manage customer data.
- Mechanic management: View, add, and edit mechanic information.
- Service management: Manage types of services offered.
- Booking management: View and manage service bookings.
- PDF report generation for bookings with detailed tables showing user, mechanic, services, date, time, status, notes, and total price.
- Localization support for Indonesian language and currency formatting.
- State management using Flutter Bloc.
- Routing with GoRouter for smooth page transitions.
- Integration with Supabase backend for data storage and authentication.

## Database Structure
![DB-Pitstop-img](assets\images\DB-PitStop-img.png)

## Getting Started

### Figma Preview UI Design
1. [Figma Design UI](https://www.figma.com/design/wUkH9LGSvuhkPjQuR0RI0i/Pit-Stop?node-id=40-188&t=eMb3jbxcnzfcn3BX-0)

### Prerequisites

- Flutter 3.27.2 or later
- Dart 3.6.1 or later
- Supabase account and project for backend services
- Environment variables configured in `.env` file for Supabase URL and Key

### Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd pitstop
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Configure environment variables in `.env` file:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_anon_key
   ```
5. Run the app:
   ```
   flutter run
   ```

## Project Structure

- `lib/main.dart`: Application entry point, routing, and app initialization.
- `lib/admin/`: Contains admin-related pages and features including booking, customer, mechanic, and service management.
- `lib/auth/`: Authentication pages and logic.
- `lib/data/`: Data models and utilities including PDF generation helpers.
- `lib/home/`: User home and profile pages.
- `lib/utils/`: Utility functions and helpers.

## License

This project is licensed under the MIT License.

---

For more information, refer to the Flutter documentation and the Supabase documentation for backend integration.
