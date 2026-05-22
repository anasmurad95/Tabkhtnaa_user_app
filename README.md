# Tabkhtnaa User App

Flutter client for the Tabkhtnaa food marketplace (client role).

## Requirements

- Flutter SDK 3.11+
- Running Laravel API at `BackEnd/Tabkhtnaa`

## Configure API URL

Default (Android emulator → host machine):

```text
http://10.0.2.2:8000/api/v1
```

Override at run time:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:8000/api/v1
```

## Run backend

```bash
cd D:/AWM/Tabkhtnaa/BackEnd/Tabkhtnaa
php artisan serve --host=0.0.0.0 --port=8000
```

Ensure `.env` has database configured and run migrations/seeders as needed.

## Run app

```bash
cd D:/AWM/Tabkhtnaa/App/user_app
flutter pub get
flutter run
```

## Auth

Uses Laravel Sanctum bearer tokens. Login: `POST /api/v1/auth/login` with `country_code`, `mobile`, `password`.
