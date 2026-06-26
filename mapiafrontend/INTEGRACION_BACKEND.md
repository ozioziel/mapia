# Integración Frontend (Flutter) ↔ Backend (NestJS)

Qué necesita la app Flutter de **Mapia** del backend para funcionar: configuración base,
endpoints, formato de requests/responses y **mapeo a las entidades del frontend**.

> Estado actual del frontend: usa **datasources mock** (`*_mock_datasource.dart`) y los
> archivos `core/network/api_client.dart` y `core/network/api_endpoints.dart` están **vacíos**.
> Este documento es el contrato para reemplazar los mocks por llamadas reales.

Backend base: `http://<host>:3000/api/v1` · Swagger: `http://<host>:3000/docs`.

---

## 1. Configuración base que debe implementar el frontend

### 1.1 Base URL según plataforma (¡pitfall clásico!)

| Entorno | Base URL |
|---|---|
| Emulador **Android** | `http://10.0.2.2:3000/api/v1` |
| Simulador **iOS** / Desktop / Web | `http://localhost:3000/api/v1` |
| Dispositivo físico | `http://<IP-LAN-de-tu-PC>:3000/api/v1` |

Configurar en `core/config/app_config.dart`. `10.0.2.2` es el alias del host desde el
emulador de Android; `localhost` dentro del emulador apunta al propio teléfono.

### 1.2 Autenticación (JWT)

- Header en cada request protegido: `Authorization: Bearer <accessToken>`.
- Guardar `accessToken` y `refreshToken` con `shared_preferences` (ya es dependencia).
- **Access token** dura 15 min; **refresh token** 7 días.
- Al recibir **401**, llamar `POST /auth/refresh` con el `refreshToken`, guardar los
  nuevos tokens y reintentar la request original una vez. Si el refresh también falla → logout.

### 1.3 Convenciones globales

- **Fechas:** ISO 8601 UTC (`2026-06-26T15:30:00.000Z`). Parsear con `DateTime.parse`.
  El `timeAgo` que muestra la UI se calcula en el cliente (ya existe `core/utils/time_ago.dart`).
- **Paginación:** query `?page=1&limit=20`. Respuesta:
  ```json
  { "data": [ ... ], "meta": { "page": 1, "limit": 20, "total": 53, "totalPages": 3 } }
  ```
- **Errores:** formato uniforme (ver §14).
- **Rutas públicas** (sin token): `register`, `login`, `refresh`, `GET /posts`, `GET /posts/:id`,
  `GET /posts/user/:id`, comentarios/reacciones de lectura, `map/*`, `alerts/*`, `locations/*`, `languages`.

---

## 2. Enums: mapeo PostType (backend ⇄ Flutter)

El backend usa `UPPER_SNAKE`; el `enum PostType` de Flutter usa `camelCase`.

| Backend | Flutter (`PostType`) |
|---|---|
| `NEWS` | `news` |
| `NOVELTY` | `novelty` |
| `PARTY` | `party` |
| `FOOD_DEAL` | `foodDeal` |
| `SALE` | `sale` |
| `TRAFFIC` | `traffic` |
| `BLOCKADE` | `blockade` |
| `ACCIDENT` | `accident` |
| `SERVICE_CUT` | `serviceCut` |
| `SECURITY` | `security` |
| `LOST_FOUND` | `lostFound` |
| `OTHER` | `other` |

> El frontend debe convertir en sus `*_model.dart` (p. ej. `PostType.values.byName(toCamel(json))`).
> ⚠️ El `enum MapPostCategory` del mapa NO coincide 1:1 (tiene `event`, le falta `novelty`/`party`).
> Recomendación: en el mapa usar también `PostType` y derivar el estilo, o mapear
> `PARTY→event`. Ver §7.

---

## 3. Auth — `features/auth`

Pantallas: `login_screen`, `register_screen`.

### POST `/auth/register`
```json
// request
{
  "email": "carla@example.com", "password": "Sup3rSegura!",
  "firstName": "Carla", "lastName": "Méndez", "username": "carla_m",
  "phone": "+59171234567"
}
```
`phone` es opcional. `firstName` y `lastName` son requeridos.
```json
// response 201
{
  "user": {
    "id": "uuid", "email": "carla@example.com", "role": "USER",
    "username": "carla_m", "name": "Carla Méndez",
    "firstName": "Carla", "lastName": "Méndez",
    "phone": "+59171234567", "phoneVerified": false
  },
  "tokens": { "accessToken": "jwt...", "refreshToken": "jwt..." }
}
```

### POST `/auth/login`
```json
// request
{ "email": "carla@example.com", "password": "Sup3rSegura!" }
// response 200 -> igual a register
```

### POST `/auth/refresh`
```json
{ "refreshToken": "jwt..." }   // -> { user, tokens }
```

### POST `/auth/logout`  (con Bearer) → `{ "success": true }`
### GET `/auth/me`  (con Bearer) → `{ "id","email","role","username","name","firstName","lastName","phone","phoneVerified" }`

> ✅ **Implementado:** el backend ya recibe `firstName`/`lastName`/`phone` y los devuelve.
> El campo `name` se deriva de `firstName + lastName`.

---

## 4. Profile — `features/profile`

Pantallas: `profile_screen`, `edit_profile_screen`, `verify_phone_screen`.

### GET `/profiles/me`  (Bearer)
```json
{
  "id": "uuid", "userId": "uuid",
  "firstName": "Carla", "lastName": "Méndez", "name": "Carla Méndez",
  "username": "carla_m",
  "phone": "+59171234567", "phoneVerified": true,
  "bio": "Vecina de Sopocachi", "avatarUrl": "https://.../avatars/x.jpg",
  "followersCount": 0, "followingCount": 0, "postsCount": 4, "likesCount": 12,
  "createdAt": "2026-06-26T...", "updatedAt": "2026-06-26T..."
}
```

### GET `/profiles/:username`  (público) → mismo shape.
### PATCH `/profiles/me`  (Bearer)
```json
{ "firstName": "Carla", "lastName": "M.", "username": "carla_mendez", "bio": "Texto...", "phone": "+59171234567" }
```
Todos opcionales. **Cambiar `phone` pone `phoneVerified = false`** (hay que reverificar).

### POST `/profiles/me/avatar`  (Bearer, `multipart/form-data`, campo `file`) → Profile actualizado.

### Verificación de teléfono (OTP) ✅ implementado
- `POST /profiles/me/phone/send-code` (Bearer) → body opcional `{ "phone": "+59171234567" }`
  (si se envía, actualiza el teléfono). Respuesta: `{ "sent": true, "devCode": "123456" }`.
  > En **desarrollo** el código es siempre `123456` y se incluye como `devCode` (solo dev).
  > En producción se genera aleatorio y `devCode` no se devuelve (se enviaría por SMS).
- `POST /profiles/me/phone/verify` (Bearer) → body `{ "code": "123456" }` → Profile con `phoneVerified: true`.
  Código inválido/expirado → `401`. Expira en 5 min, máx 5 intentos.

**Mapeo a `ProfileEntity`:**

| `ProfileEntity` (Flutter) | Origen backend |
|---|---|
| `firstName`, `lastName`, `name` | ✅ directo |
| `username`, `bio`, `avatarUrl` | directo |
| `phone`, `phoneVerified` | ✅ directo |
| `followersCount`, `followingCount`, `likesCount`, `postsCount` | directo |
| `email` | viene de `/auth/me` (está en User, no en Profile) |
| `posts` (lista del perfil) | usar `GET /posts/user/:userId` (§5) |
| `createdAt` | directo |
| `canPublish` (getter = phoneVerified) | usar `phoneVerified` del perfil |

> ✅ El flujo de OTP del frontend (`sendPhoneVerificationCode`, `verifyPhoneCode`,
> `verify_phone_screen`) ya tiene endpoints reales. El `OtpService` mock puede
> reemplazarse por estas llamadas (en dev el código sigue siendo `123456`).

---

## 5. Posts — `features/posts`

Pantallas: `posts_feed_screen`, `post_detail_screen`, `create_post_screen`.

### GET `/posts?page=1&limit=20&type=FOOD_DEAL`  (público, paginado)
### GET `/posts/:id`  (público)
### GET `/posts/user/:userId?page=1&limit=20`  (público) — posts de un usuario (para el perfil)

`PostResponseDto`:
```json
{
  "id": "uuid",
  "title": "Pollo barato cerca de la plaza",
  "description": "Promo de almuerzo...",
  "type": "FOOD_DEAL",
  "status": "PUBLISHED",
  "visibility": "PUBLIC",
  "latitude": -16.5, "longitude": -68.15,
  "address": "Sopocachi, La Paz",
  "isVerified": false,
  "likesCount": 3, "commentsCount": 1, "reportsCount": 0,
  "isLiked": false,
  "author": { "id": "uuid", "name": "Carla Méndez", "username": "carla_m", "avatarUrl": "https://..." },
  "media": [ { "id": "uuid", "url": "https://...", "type": "IMAGE" } ],
  "createdAt": "2026-06-26T...", "updatedAt": "2026-06-26T..."
}
```
> ✅ `isLiked` indica si el **usuario autenticado** dio like. En `GET /posts`, `/posts/:id`
> y `/posts/user/:id` usa **auth opcional**: si mandas el `Bearer` viene el valor real;
> sin token siempre `false`.

### POST `/posts`  (Bearer)
```json
{ "title": "...", "description": "...", "type": "FOOD_DEAL", "latitude": -16.5, "longitude": -68.15, "address": "opcional" }
```
### PATCH `/posts/:id`  (Bearer, solo autor) — campos opcionales.
### DELETE `/posts/:id`  (Bearer, solo autor) → `{ "success": true }` (soft delete).

**Mapeo a `PostEntity`:**

| `PostEntity` (Flutter) | Origen backend |
|---|---|
| `title`, `description`, `latitude`, `longitude`, `address` | directo |
| `type` | mapear enum (§2) |
| `likesCount`, `commentsCount`, `isVerified`, `createdAt` | directo |
| `authorName` | `author.name` |
| `authorAvatarUrl` | `author.avatarUrl` |
| `mediaUrl` | `media[0].url` (el backend devuelve **lista**; usar el primero) |
| `mediaType` | `media[0].type` → `image`/`video`; sin media → `none` |
| `isLiked` | ✅ directo (manda el Bearer para obtener el valor real) |

**Flujo de "crear post" del frontend** (`create_post_provider`):
1. Verifica `canPublish` (= `phoneVerified`). Usar OTP de §4 si aún no está verificado.
2. Toma `usesCurrentLocation` → obtener lat/lng del dispositivo (geolocator) y opcional
   `GET /locations/reverse` para el `address`.
3. `POST /posts` con título, descripción, tipo, lat/lng, address.
4. Si hay imagen (`imageSource`): `POST /posts/:postId/media` (multipart) con la respuesta del paso 3.

---

## 6. Media, Comentarios y Reacciones

### Media — `features/posts` (post_media_viewer, post_photo_picker)
- `POST /posts/:postId/media` (Bearer, `multipart/form-data`, campo `file`) → `{ id, postId, url, type, storageKey, createdAt }`
- `DELETE /post-media/:mediaId` (Bearer) → `{ "success": true }`
- Tipos aceptados: `image/jpeg|png|webp`, `video/mp4`. Límite 25 MB.

### Comentarios — `comments_section`, `comment_input`
- `POST /posts/:postId/comments` (Bearer) → body `{ "content": "texto", "parentId": "opcional-uuid" }`
- `GET /posts/:postId/comments?page=1&limit=20` (público, paginado)
- `DELETE /comments/:id` (Bearer, solo autor) → `{ "success": true }`

Respuesta de listado (cada item):
```json
{
  "id": "uuid", "postId": "uuid", "authorId": "uuid",
  "content": "¿Sigue disponible?", "parentId": null,
  "author": { "id": "uuid", "profile": { "name": "Juan P.", "username": "juanp", "avatarUrl": "https://..." } },
  "createdAt": "2026-06-26T...", "updatedAt": "2026-06-26T..."
}
```
**Mapeo a `CommentEntity`:** `authorName = author.profile.name`, `content`, `createdAt`, `postId` directos.
> ✅ El **POST** de comentario ya devuelve `author.profile` (mismo shape que el listado),
> así que puedes pintar el comentario recién creado sin refetch.

### Reacciones (like) — `post_interaction_bar`
- `POST /posts/:postId/like` (Bearer) → `{ "liked": true, "likesCount": 4 }`
- `DELETE /posts/:postId/like` (Bearer) → `{ "liked": false }`
- `GET /posts/:postId/reactions?page&limit` (público) — lista de usuarios que dieron like.
- Regla: un like por usuario/post (segundo like → 409).

---

## 7. Map — `features/map`

Pantallas: `map_screen` (+ `google_map_view`, `mock_map_view`). Devuelve marcadores compactos.

### GET `/map/posts/nearby?lat=-16.5&lng=-68.15&radiusKm=3&type=FOOD_DEAL`  (público)
### GET `/map/posts?bbox=-68.20,-16.55,-68.10,-16.45&type=FOOD_DEAL`  (público, viewport)

`MapMarkerDto[]`:
```json
[
  {
    "id": "uuid", "title": "Pollo barato", "type": "FOOD_DEAL",
    "latitude": -16.5, "longitude": -68.15, "address": "Sopocachi",
    "isVerified": true,
    "author": { "id": "uuid", "name": "Carla Méndez", "avatarUrl": "https://..." }
  }
]
```

**Mapeo a `MapPostEntity`:**

| `MapPostEntity` (Flutter) | Origen backend |
|---|---|
| `id`, `title`, `latitude/longitude` (usar lat/lng reales) | directo |
| `category` | mapear desde `type` (§2). El mock usa `mapX/mapY`; con datos reales usar lat/lng en `GoogleMap`. |
| `author` (string) | `author.name` |
| `locationName` | `address` |
| `timeAgo` | calcular en cliente desde `createdAt` (no viene en el marker; usar detalle si se necesita) |
| `likesCount`, `commentsCount`, `isLiked` | ⚠️ no vienen en el marker compacto; obtenerlos del detalle `GET /posts/:id` al abrir el preview |
| `status` | derivar de `isVerified` (✅ ya viene en el marker): true→"verificado" |
| `trustScore` | ⚠️ no existe; queda para futuro (moderación/IA) |
| `mapX`, `mapY` | solo para el `mock_map_view`; con `google_map_view` usar lat/lng |

> El marker es **compacto a propósito** (rendimiento). Para likes/comentarios/descripción
> completa, al tocar un marcador llamar `GET /posts/:id`.

---

## 8. Alerts — `features/alerts`

Pantallas: `alerts_screen`, `nearby_posts_screen` (+ `alert_radius_selector`).

### GET `/alerts/nearby-summary?lat=-16.5&lng=-68.15&radiusKm=3`  (público)
```json
[
  { "type": "BLOCKADE", "count": 4, "title": "Bloqueos", "description": "Hay 4 bloqueos cerca de ti", "radiusKm": 3 },
  { "type": "FOOD_DEAL", "count": 3, "title": "Comida barata", "description": "Hay 3 comidas baratas cerca de ti", "radiusKm": 3 }
]
```
✅ **Coincide casi 1:1 con `NearbyAlertGroupEntity`** (`type, title, description, count, radiusKm`).
El frontend ya genera sus propios textos en `NearbyAlertGroupModel`; puede usar los del backend
o ignorar `title/description` y generarlos localmente (ambos sirven).

### GET `/alerts/nearby-posts?lat=-16.5&lng=-68.15&type=FOOD_DEAL&radiusKm=3`  (público)
```json
[
  {
    "id": "uuid", "title": "...", "type": "FOOD_DEAL",
    "latitude": -16.5, "longitude": -68.15, "address": "Sopocachi",
    "distanceMeters": 320,
    "author": { "name": "Carla Méndez", "avatarUrl": "https://..." },
    "createdAt": "2026-06-26T..."
  }
]
```
`alert_radius_selector` → manda `radiusKm` (1–50). El radio por defecto del usuario sale de Settings (§9).

---

## 9. Settings — (radio, idioma, notificaciones)

Usado por `alert_radius_selector` (radio por defecto) y `language_settings_screen`.

### GET `/settings/me`  (Bearer)
### PATCH `/settings/me`  (Bearer)
```json
{ "languageCode": "es", "defaultRadiusKm": 3, "notificationsEnabled": true }   // opcionales
```
Respuesta:
```json
{ "id":"uuid","userId":"uuid","languageCode":"es","defaultRadiusKm":3,"notificationsEnabled":true,"createdAt":"...","updatedAt":"..." }
```

---

## 10. Languages & Locations

### Languages — `features/language`
- `GET /languages`  (público) → `[ { "code":"es","name":"Spanish","nativeName":"Español","enabled":true }, ... ]`
- El frontend ya tiene un catálogo local grande (`l10n_extra/*`) y persiste el idioma con
  `language_local_datasource`. El backend solo aporta el catálogo "oficial" habilitado y
  guarda la preferencia en `settings.languageCode`. **Mapeo:** `code→Locale`, `name`, `nativeName`.
  El `status` (`available/partial/preparing`) es propio del frontend.

### Locations — `features/location`
- `GET /locations/reverse?lat=-16.5&lng=-68.15` (público) → `{ "formattedAddress","latitude","longitude","source" }`
- `GET /locations/search?q=Sopocachi` (público) → lista de lo anterior.
- `source` es `"google"` o `"mock"` (sin API key el backend responde mock). Mapea a `AppLocationEntity`
  (`latitude`, `longitude`, `address = formattedAddress`).

---

## 11. Reports — `features/reports`  ✅ implementado

Pantalla: `create_report_screen`.

### POST `/posts/:postId/report`  (Bearer)
```json
{ "reason": "FALSE_INFO", "description": "opcional, máx 500" }
```
`reason` ∈ `SPAM | FALSE_INFO | OFFENSIVE | DANGEROUS | OTHER`. Reportar dos veces el
mismo post → `409`. Respuesta: el reporte creado.

### GET `/reports`  (Bearer, solo `MODERATOR`/`ADMIN`, paginado) — para moderación.

---

## 12. Follows — `features/profile` (seguidores)

Usado por `profile_stats`.

- `POST /follows/:userId`  (Bearer) → `{ "following": true }`  (no puedes seguirte: `400`; duplicado: `409`)
- `DELETE /follows/:userId`  (Bearer) → `{ "following": false }`
- `GET /follows/:userId/followers`  (público, paginado) → lista de `{ userId, username, name, avatarUrl }`
- `GET /follows/:userId/following`  (público, paginado) → igual shape

Los contadores `followersCount`/`followingCount` del perfil se actualizan solos.

---

## 13. Estado de los gaps (todos resueltos en backend)

| # | Gap | Estado |
|---|---|---|
| 1 | Verificación por teléfono (OTP) | ✅ `POST /profiles/me/phone/send-code` y `/verify` (§4) |
| 2 | `firstName`/`lastName` | ✅ en Profile, register y respuestas |
| 3 | `phone` | ✅ en Profile (cambiarlo resetea `phoneVerified`) |
| 4 | `isLiked` por usuario | ✅ en `GET /posts`, `/posts/:id`, `/posts/user/:id` (auth opcional) |
| 5 | Reports de contenido | ✅ `POST /posts/:postId/report`, `GET /reports` (§11) |
| 6 | Follows (seguir/dejar de seguir) | ✅ módulo follows (§12) |
| 7 | Media múltiple vs única | El backend devuelve `media[]`; el frontend usa `media[0]` (galería opcional) |
| 8 | Autor en POST de comentario | ✅ el POST devuelve `author.profile` |
| 9 | `status`/`trustScore` en mapa | `status` derivable de `isVerified` (✅ en marker); `trustScore` futuro |

---

## 14. Manejo de errores

Todas las respuestas de error tienen el mismo formato:
```json
{
  "statusCode": 400,
  "error": "BadRequest",
  "message": "title must be longer than or equal to 3 characters",
  "path": "/api/v1/posts",
  "timestamp": "2026-06-26T15:30:00.000Z"
}
```
- `message` puede ser **string** o **array de strings** (errores de validación de varios campos).
- Códigos típicos: `400` validación, `401` token inválido/expirado (→ refresh), `403` sin permiso
  (p. ej. editar post ajeno), `404` no encontrado, `409` conflicto (email/username/like duplicado).

---

## 15. Checklist de cableado (orden sugerido en el frontend)

1. `app_config.dart`: base URL por plataforma.
2. `api_client.dart`: cliente HTTP con interceptor de `Authorization` + refresh en 401.
3. `api_endpoints.dart`: constantes de rutas (de este documento).
4. Auth (login/register/me) + persistencia de tokens en `shared_preferences`.
5. Reemplazar mocks por datasources reales feature por feature:
   `posts` → `map` → `alerts` → `profile` → `settings` → `comments/reactions` →
   `reports` → `follows` → `locations` → `languages`.
6. Para publicar: verificar teléfono con el OTP (§4) — `canPublish = phoneVerified`.

> ✅ **Todos los gaps del contrato están implementados en el backend.** El frontend solo
> debe reemplazar sus mocks por las llamadas reales descritas aquí.

> Referencia viva: Swagger en `http://<host>:3000/docs` lista todos los endpoints, DTOs y errores.
