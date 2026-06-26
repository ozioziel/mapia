# Mapia Backend

Backend de **Mapia**, mapa social ciudadano geolocalizado (La Paz, Bolivia).

Stack: **NestJS 11 + TypeScript + PostgreSQL/PostGIS + TypeORM + JWT + Swagger**.
Arquitectura: monolito modular (Feature First + Clean Architecture ligera).

## Requisitos

- Node.js 22+
- Docker + Docker Compose (para Postgres/PostGIS y Redis locales)

## Puesta en marcha (desarrollo)

```bash
# 1. Variables de entorno
cp .env.example .env

# 2. Levantar Postgres+PostGIS y Redis
docker compose up -d postgres redis

# 3. Instalar dependencias
npm install

# 4. Ejecutar migraciones (crea PostGIS, tablas, índice GIST)
npm run migration:run

# 5. (opcional) Semillas (idiomas)
npm run seed

# 6. Levantar la API en modo watch
npm run start:dev
```

- API: `http://localhost:3000/api/v1`
- Swagger: `http://localhost:3000/docs`
- Healthcheck: `http://localhost:3000/api/v1/health`

## Comandos de migraciones

```bash
npm run migration:run          # aplica migraciones pendientes
npm run migration:revert       # revierte la última
npm run migration:generate src/core/database/migrations/NombreMigracion
```

## Estructura

```
src/
├── core/        # infraestructura transversal (config, db, security, storage, logger)
├── common/      # piezas reutilizables (guards, filters, dtos, decorators...)
└── modules/     # features (auth, users, posts, map, alerts, ...)
```

## Conexión a Google Cloud SQL

- **Local contra Cloud SQL:** usar Cloud SQL Auth Proxy
  ```bash
  cloud-sql-proxy PROJECT:REGION:INSTANCE --port 5432
  ```
  y dejar `DB_HOST=localhost`, `DB_SSL=false` (el proxy cifra).
- **Producción (Cloud Run):** preferir IP privada vía conector VPC, o socket
  `DB_HOST=/cloudsql/PROJECT:REGION:INSTANCE`. Secretos vía Secret Manager,
  nunca en el repositorio.

## Storage

- `STORAGE_DRIVER=local` → guarda en `./uploads` y sirve en `/static` (dev).
- `STORAGE_DRIVER=gcs` → Google Cloud Storage (prod), bucket `GCS_BUCKET_NAME`.

## Fases

- **MVP:** auth, users, profiles, posts, post-media, comments, reactions, map, alerts, locations, settings, languages.
- **Fase 2:** follows, notifications, moderation, reports.
- **Fase 3:** news-agent, analytics, admin.
