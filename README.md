# MAPIA - Integracion frontend/backend

MAPIA usa Flutter en el frontend, NestJS en el backend y PostgreSQL/PostGIS en Supabase.

## URLs actuales

| Recurso | URL |
| --- | --- |
| API productiva | `http://144.22.43.169:3001/api/v1` |
| Swagger | `http://144.22.43.169:3001/docs` |
| Healthcheck | `http://144.22.43.169:3001/api/v1/health` |

Importante: la API productiva esta en HTTP. Si el frontend web se publica en HTTPS, el navegador bloqueara llamadas HTTP por mixed content. Para produccion web, poner el backend detras de HTTPS y compilar Flutter con esa URL.

## Frontend Flutter

Desarrollo contra backend desplegado:

```bash
cd mapiafrontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://144.22.43.169:3001/api/v1 --dart-define=GOOGLE_MAPS_API_KEY=<GOOGLE_MAPS_API_KEY>
```

Desarrollo contra backend local:

```bash
cd mapiafrontend
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1 --dart-define=GOOGLE_MAPS_API_KEY=<GOOGLE_MAPS_API_KEY>
```

Build web:

```bash
cd mapiafrontend
flutter build web --release --dart-define=API_BASE_URL=<BACKEND_HTTPS_URL>/api/v1 --dart-define=GOOGLE_MAPS_API_KEY=<GOOGLE_MAPS_API_KEY>
```

Build Android:

```bash
cd mapiafrontend
flutter build apk --release --dart-define=API_BASE_URL=http://144.22.43.169:3001/api/v1 --dart-define=GOOGLE_MAPS_API_KEY=<GOOGLE_MAPS_API_KEY>
```

Variables del frontend:

| Variable | Obligatoria | Uso |
| --- | --- | --- |
| `API_BASE_URL` | Si quieres sobrescribir el default | Base del backend, incluyendo `/api/v1`. |
| `GOOGLE_MAPS_API_KEY` | Si usas Google Maps real | Key publica restringida por dominio/app. |

No poner `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET` ni `SUPABASE_SERVICE_ROLE_KEY` en Flutter.

## Backend NestJS

Desarrollo:

```bash
cd mapiabackend
cp .env.example .env
npm install
npm run start:dev
```

Produccion:

```bash
cd mapiabackend
npm ci
npm run build
npm run start:prod
```

Variables minimas en el server:

```env
NODE_ENV=production
PORT=3001
API_PREFIX=api/v1
CORS_ORIGINS=<FRONTEND_URL>,http://localhost:3000,http://localhost:8080

DB_HOST=aws-0-<region>.pooler.supabase.com
DB_PORT=5432
DB_USERNAME=postgres.<project-ref>
DB_PASSWORD=<SUPABASE_DB_PASSWORD>
DB_DATABASE=postgres
DB_SSL=true
DB_RUN_MIGRATIONS=false

JWT_ACCESS_SECRET=<JWT_ACCESS_SECRET>
JWT_REFRESH_SECRET=<JWT_REFRESH_SECRET>
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

STORAGE_DRIVER=supabase
SUPABASE_URL=<SUPABASE_URL>
SUPABASE_SERVICE_ROLE_KEY=<SUPABASE_SERVICE_ROLE_KEY>
SUPABASE_STORAGE_BUCKET=alert-images
STORAGE_PUBLIC_URL=<PUBLIC_STORAGE_URL>

GOOGLE_MAPS_SERVER_API_KEY=<GOOGLE_MAPS_SERVER_API_KEY>
GOOGLE_MAPS_GEOCODING_ENABLED=true
GOOGLE_MAPS_PLACES_ENABLED=true
GROQ_API=<GROQ_API>
GEMINI_API=<GEMINI_API>
```

No correr migraciones destructivas en Supabase. El esquema se aplica manualmente desde los SQL en `mapiabackend/db/`.

## Verificacion

1. Backend vivo:

```bash
curl http://144.22.43.169:3001/api/v1/health
```

2. Login/register:

```bash
curl -X POST http://144.22.43.169:3001/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"<EMAIL>\",\"password\":\"<PASSWORD>\"}"
```

El token debe venir en `tokens.accessToken`. En llamadas privadas enviar `Authorization: Bearer <TOKEN>`.

3. Mapa/publicaciones:

```bash
curl "http://144.22.43.169:3001/api/v1/map/alerts"
curl "http://144.22.43.169:3001/api/v1/news/today/map"
curl "http://144.22.43.169:3001/api/v1/posts"
```

4. Swagger:

Abrir `http://144.22.43.169:3001/docs` y probar endpoints con el bearer token.
