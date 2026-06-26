# MAPIA Frontend

Flutter app conectada al backend NestJS de MAPIA.

## Configuracion de API

La app lee la URL del backend desde `--dart-define=API_BASE_URL`.

Si no se define, usa por defecto:

```text
http://144.22.43.169:3001/api/v1
```

Ejecutar contra produccion:

```bash
flutter run --dart-define=API_BASE_URL=http://144.22.43.169:3001/api/v1 --dart-define=GOOGLE_MAPS_API_KEY=<GOOGLE_MAPS_API_KEY>
```

Ejecutar contra backend local:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1 --dart-define=GOOGLE_MAPS_API_KEY=<GOOGLE_MAPS_API_KEY>
```

Build web:

```bash
flutter build web --release --dart-define=API_BASE_URL=<BACKEND_HTTPS_URL>/api/v1 --dart-define=GOOGLE_MAPS_API_KEY=<GOOGLE_MAPS_API_KEY>
```

No incluir secretos de backend en Flutter. `SUPABASE_SERVICE_ROLE_KEY`, `JWT_ACCESS_SECRET` y `JWT_REFRESH_SECRET` van solo en el servidor.
