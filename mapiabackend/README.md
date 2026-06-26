# Mapia Backend

Backend de **Mapia**, mapa social ciudadano geolocalizado (La Paz, Bolivia).

**Stack:** NestJS 11 · TypeScript · PostgreSQL + **PostGIS** · TypeORM · JWT (argon2) · Swagger.
**Arquitectura:** monolito modular (Feature First + Clean Architecture ligera).
La cercanía se calcula en el backend con **PostGIS** (`ST_DWithin`), no con Google Maps.

---

## Requisitos

- **Node.js 22+**
- **PostgreSQL 17** con **PostGIS** (instalación local nativa — sin Docker)

---

## Puesta en marcha local (sin Docker)

### Paso 1 — Base de datos (PostGIS + rol + base)

Requiere permisos de administrador (instalar PostGIS) y la contraseña del
superusuario `postgres`. Todo está automatizado en un script:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup-local-db.ps1
```

El script (se auto-eleva con UAC):
1. Instala **PostGIS 3.6** en tu PostgreSQL 17 si falta (modo desatendido).
2. Ejecuta `db/bootstrap.sql`: crea el rol `mapia_user`, la base `mapia_db`
   y activa las extensiones `postgis` y `uuid-ossp`.

> **Alternativa manual** (si prefieres no usar el script):
> 1. Instala PostGIS con Stack Builder: `C:\Program Files\PostgreSQL\17\bin\stackbuilder.exe`
>    → instancia PostgreSQL 17 → **Spatial Extensions → PostGIS Bundle**.
> 2. Crea rol/base/extensiones:
>    ```powershell
>    & "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres -f db/bootstrap.sql
>    ```

### Paso 2 — App (dependencias, migraciones, arranque)

```bash
cp .env.example .env       # ya apunta a localhost / mapia_user / mapia_db
npm install
npm run migration:run      # crea tablas, índice GIST y trigger de location
npm run seed               # idiomas (opcional)
npm run start:dev
```

### URLs

| Recurso | URL |
|---|---|
| API | `http://localhost:3000/api/v1` |
| Swagger (docs) | `http://localhost:3000/docs` |
| Healthcheck | `http://localhost:3000/api/v1/health` |
| Archivos locales (dev) | `http://localhost:3000/static/...` |

El `/health` devuelve la versión de PostGIS: útil para confirmar que la base quedó bien.

---

## Variables de entorno

Copiar `.env.example` a `.env`. Claves principales:

| Variable | Default (dev) | Descripción |
|---|---|---|
| `PORT` | `3000` | Puerto HTTP |
| `API_PREFIX` | `api/v1` | Prefijo global |
| `CORS_ORIGINS` | `*` | Orígenes permitidos (coma-separados) |
| `DB_HOST` / `DB_PORT` | `localhost` / `5432` | Conexión PostgreSQL |
| `DB_USERNAME` / `DB_PASSWORD` | `mapia_user` / `mapia_password` | Credenciales app |
| `DB_DATABASE` | `mapia_db` | Base de datos |
| `DB_SSL` | `false` | SSL (true si IP pública en cloud) |
| `DB_RUN_MIGRATIONS` | `true` | Correr migraciones al arrancar |
| `JWT_ACCESS_SECRET` / `JWT_REFRESH_SECRET` | `change_me_*` | Secretos JWT (cambiar) |
| `STORAGE_DRIVER` | `local` | `local` (disco) o `gcs` (prod) |
| `DEFAULT_RADIUS_KM` / `MAX_RADIUS_KM` | `3` / `50` | Radio por defecto y tope |
| `GOOGLE_MAPS_API_KEY` | _(vacío)_ | Sin key → geocoding responde **mock** |

> Nunca commitear el `.env`. En producción los secretos van en **Secret Manager**.

---

## Comandos útiles

```bash
npm run start:dev                 # API en watch
npm run build                     # compilar a dist/
npm run migration:run             # aplicar migraciones pendientes
npm run migration:revert          # revertir la última
npm run migration:generate src/core/database/migrations/NombreMigracion
npm run seed                      # semillas (idiomas)
```

---

## Estructura

```
src/
├── main.ts                # bootstrap (helmet, cors, swagger, static)
├── app.module.ts          # wiring + guards/filtros/pipes globales
├── core/                  # infraestructura transversal
│   ├── config/  env/      # configuración tipada + validación (Joi)
│   ├── database/          # TypeORM datasource + migraciones + seeds
│   ├── security/          # argon2 (PasswordService)
│   └── storage/           # puerto storage: local (dev) / gcs (prod)
├── common/                # decorators, dtos, guards, filters, enums, utils
└── modules/               # features
    ├── auth/ users/ profiles/ settings/ languages/
    ├── posts/ post-media/ comments/ reactions/
    ├── map/ alerts/ locations/
    └── health/
```

---

## Endpoints principales (MVP)

| Área | Endpoints |
|---|---|
| **Auth** | `POST /auth/register` · `POST /auth/login` · `POST /auth/refresh` · `POST /auth/logout` · `GET /auth/me` |
| **Profiles** | `GET /profiles/me` · `PATCH /profiles/me` · `POST /profiles/me/avatar` · `GET /profiles/:username` |
| **Posts** | `POST /posts` · `GET /posts` · `GET /posts/:id` · `PATCH /posts/:id` · `DELETE /posts/:id` · `GET /posts/user/:userId` |
| **Media** | `POST /posts/:postId/media` · `DELETE /post-media/:mediaId` |
| **Comments** | `POST /posts/:postId/comments` · `GET /posts/:postId/comments` · `DELETE /comments/:id` |
| **Reactions** | `POST /posts/:postId/like` · `DELETE /posts/:postId/like` · `GET /posts/:postId/reactions` |
| **Map** | `GET /map/posts?bbox=...` · `GET /map/posts/nearby?lat&lng&radiusKm` |
| **Alerts** | `GET /alerts/nearby-summary?lat&lng&radiusKm` · `GET /alerts/nearby-posts?lat&lng&type&radiusKm` |
| **Locations** | `GET /locations/reverse?lat&lng` · `GET /locations/search?q` |
| **Settings** | `GET /settings/me` · `PATCH /settings/me` |
| **Languages** | `GET /languages` |

Todo documentado en Swagger (`/docs`). Las rutas de lectura del mapa/posts son públicas;
las de escritura requieren `Authorization: Bearer <accessToken>`.

---

## Storage de archivos

- `STORAGE_DRIVER=local` → guarda en `./uploads` y sirve en `/static` (desarrollo).
- `STORAGE_DRIVER=gcs` → Google Cloud Storage (producción), bucket `GCS_BUCKET_NAME`.

El driver se elige por variable de entorno; el código de los módulos no cambia.

---

## Despliegue en Google Cloud (opcional, futuro)

Guía completa en [`docs/deploy-gcp.md`](docs/deploy-gcp.md):
**Cloud SQL** (base de datos, misma migración PostGIS) + **Cloud Storage** (archivos)
+ **Cloud Run** (API) + **Secret Manager** (credenciales).

---

## Roadmap por fases

- **MVP (hecho):** auth, users, profiles, posts, post-media, comments, reactions, map, alerts, locations, settings, languages.
- **Fase 2:** follows, notifications, moderation, reports.
- **Fase 3:** news-agent, analytics, admin.
