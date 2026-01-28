# Aspro App - Laundry Service Application

## 📱 Project Overview

Aspro App is a comprehensive mobile application designed to connect users with laundry services. The app allows users to browse nearby laundry providers, book services, track orders, make payments, and communicate with service providers through an integrated chat system.

## ✨ Features

- **User Authentication**: Secure login and registration system
- **Laundry Discovery**: Browse and search for nearby laundry services
- **Booking System**: Schedule laundry services with date and time selection
- **Order Management**: Track the status of current and past orders
- **Payment Integration**: Multiple payment methods including wallet functionality
- **Promo Codes**: Apply discount codes to orders
- **In-app Chat**: Direct communication with laundry service providers
- **User Profiles**: Manage personal information and preferences
- **Multi-language Support**: Localization capabilities

## 🛠️ Technologies Used

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js
- **Database**: SQL (PostgreSQL)
- **State Management**: Provider pattern
- **Authentication**: Token-based authentication
- **UI/UX**: Custom theme with responsive design

## 📋 Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Node.js and npm (for server)
- PostgreSQL
- Android Studio / Xcode (for mobile development)

## 🚀 Installation

### Client (Flutter App)

1. Clone the repository:
   ```
   git clone https://github.com/ambetasallufi11/Aspro-App.git
   cd aspro_app
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

### Server

1. Navigate to the server directory:
   ```
   cd server
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Set up environment variables:
   - Create a `.env` file based on the provided example
   - Configure database connection details

4. Initialize the database:
   ```
   psql -U <username> -d <database> -f schema.sql
   psql -U <username> -d <database> -f seed.sql
   ```

5. Start the server:
   ```
   npm start
   ```

## 📁 Project Structure

```
aspro_app/
├── assets/                  # Images and static assets
├── lib/
│   ├── data/                # Data sources and repositories
│   ├── l10n/                # Localization files
│   ├── models/              # Data models
│   ├── providers/           # State management
│   ├── screens/             # UI screens
│   ├── services/            # API and business logic services
│   ├── theme/               # App theme and styling
│   ├── utils/               # Utility functions
│   ├── widgets/             # Reusable UI components
│   └── main.dart            # App entry point
├── server/
│   ├── admin/               # Admin panel
│   ├── src/                 # Server source code
│   ├── schema.sql           # Database schema
│   └── seed.sql             # Initial data
└── [Platform-specific folders]
```

## 🔧 Configuration

The app can be configured through various files:

- `lib/main.dart`: App initialization and global providers
- `lib/theme/app_theme.dart`: UI theme configuration
- `server/.env`: Server environment variables

## 🧪 Testing

Run tests with:

```
flutter test
```

## 📱 Supported Platforms

- Android
- iOS
- Web
- macOS
- Linux
- Windows

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

For any inquiries, please reach out to the project maintainers.

---

Developed by Ambeta & Alkida