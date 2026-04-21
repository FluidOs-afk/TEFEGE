# 👗 Arquitectura de Archivos: Red Social de Moda

Este documento detalla la estructura principal de carpetas y **qué hace cada script** necesario para que el proyecto funcione según la arquitectura que hemos diseñado, tanto en Android como en Python. 

A medida que desarrolles, estos son los archivos clave que tendrás que programar.

---

## 📱 1. Frontend: App Android (Kotlin)
Esta parte del código vivirá en tu Android Studio y utilizará **Jetpack Compose** para la UI y **Retrofit** para hablar con el backend.

### Capa de Interfaz (IU - Jetpack Compose)
* 📄 `FeedScreen.kt`
  * **Qué hace:** Es la pantalla de inicio. Aquí recuperarás la lista de `POSTS` (las publicaciones de tus amigos). Tendrá botones de "Like" y componentes de "Comentarios", además de la foto principal.
* 📄 `WardrobeScreen.kt`
  * **Qué hace:** El Armario Virtual. Leerá de la base de datos local (Room) y mostrará tu ropa (`GARMENTS`) y combinaciones (`OUTFITS`). También tiene el **botón de "Añadir Prenda"** que abre la cámara, toma la foto y se la manda a Python.
* 📄 `ForumScreen.kt` / `ChatScreen.kt`
  * **Qué hace:** Pantallas de comunidad. Se conectan usando WebSockets para que, cuando comentes algo, aparezca de inmediato sin recargar la pantalla.

### Capa de Datos y Conexión (Data)
* 📄 `ApiService.kt` (Retrofit)
  * **Qué hace:** Define todas las "llamadas" que le vas a hacer a Python. Habrá funciones como `@GET("/api/v1/feed")` o `@POST("/api/v1/garment")`.
* 📄 `RoomDatabase.kt` (Room SQLite)
  * **Qué hace:** La base de datos dentro de tu móvil. Cuando entras a tu cuenta, guarda en secreto tus prendas y outfits para que la app vuele de rápido y puedas abrir el Armario Virtual sin WiFi.

### Capa de Lógica (ViewModels)
* 📄 `WardrobeViewModel.kt`
  * **Qué hace:** Intermediario. Controla el momento de tensión cuando subes la ropa: "Tomo la foto -> Le digo a View que ponga un loader de «La IA está analizando» -> Mando la foto por ApiService -> Recibo la confirmación de Celery de que ya se extrajeron los `tags_ai` -> Guardo en Room -> Muestro la prenda recortada".

---

## ⚙️ 2. Backend: Servidor API y IA (Python)
Este proyecto de servidor utilizará **FastAPI** y se conectará directamente a PostgreSQL/Supabase. Es el cerebro de la aplicación.

### Archivo Principal
* 📄 `main.py`
  * **Qué hace:** Es el corazón del servidor. Se arranca con Uvicorn, configura que la app acepte llamadas desde Android (CORS), y arranca la conexión inicial con PostgreSQL.

### Routers (Endpoints, las "Puertas" de tu App)
* 📁 `app/api/routers/auth.py`
  * **Qué hace:** Endpoints de login iniciales. Sirve para recibir el token (ej. de Firebase) desde Android y asegurar que la cuenta en tu BD Postgres existe y crear un UUID si es nuevo.
* 📁 `app/api/routers/wardrobe.py`
  * **Qué hace:** Tiene el código para subir imágenes (`POST /garments`). En vez de procesar la IA aquí y hacer que la app en Android se quede "cargada", este script simplemente coge la imagen y **se la pasa a Celery**, devolviéndole a Kotlin un estado HTTP 202 ("Lo estoy procesando").
* 📁 `app/api/routers/feed.py`
  * **Qué hace:** Tiene el código gordo del SQL. Cuando un usuario hace un `GET /feed`, este script revisa la tabla `FOLLOWERS`, comprueba `status = accepted`, y le devuelve solo los posts de la gente privada autorizada o las cuentas públicas que sigue.
* 📁 `app/api/routers/websockets.py`
  * **Qué hace:** Abre tuberías de datos directas para mantener las pantallas de los usuarios sincronizadas instantáneamente. Crucial para los Foros (`FORUM_MESSAGES`) y Mensajería Privada (`DIRECT_MESSAGES`).

### Base de Datos y Lógica Pesada
* 📁 `app/core/models.py` (SQLAlchemy / SQLModel)
  * **Qué hace:** Traduce el diagrama entidad-relación (ER) que hicimos a código Python. Aquí pondrás que un Profile `has_many` Garments, los campos de UUID y los `JSONB` de `tags_ai`.
* 📁 `app/core/privacy_service.py`
  * **Qué hace:** Un script lleno de funciones utilitarias que debes llamar en casi cada router. Funciones genéricas como: `def can_user_view_profile(mi_id, perfil_a_ver_id):` el cual devuelve `True` si eres amigo aceptado de la cuenta privada, o lanza error `403` cortando el grifo.

### Inteligencia Artificial (Workers Secundarios)
* 📁 `app/workers/ai_celery.py`
  * **Qué hace el trabajador solitario:** Es el script que corre en segundo plano. Recibe la imagen de la camiseta nueva de forma asíncrona. Aquí pones el código para:
    1. Llamar a "Segment Anything" (SAM) para borrarle la percha y el fondo (dejando PNG transparente).
    2. Subir el PNG final a tu AWS S3 o cubo de Supabase Storage.
    3. Llamar a GPT-4 Vision o al modelo open-source pidiendo: *"¿De qué color es esto y qué estilo de moda es?"*.
    4. Guardar ese JSON en el campo `tags_ai` de Postgres.
    5. Mandar una notificación push al móvil de tu usuario con Firebase FCM: *"¡Tu camiseta verde vintage ya está guardada en tu armario!"*.
* 📁 `app/workers/outfit_recommender.py`
  * **Qué hace:** Un script cronometrado que se levanta de madrugada (o cuando el usuario da a un botón). Analiza matemáticamente los `tags_ai` de toda la ropa en la BD y escupe nuevas filas (outfits sugeridos) en la tabla `OUTFITS` con el campo `is_ai_generated = True`.

---

## 🔒 3. Variables de Entorno (`.env`)
En la raíz de tu proyecto Backend (Python), deberás tener un archivo crítico llamado `.../.env` que **nunca** debe subirse a GitHub. Este archivo almacena tus secretos de conexión. 

Un ejemplo de cómo se vería tu `.env` para esta arquitectura:

```env
# Configuración de Base de Datos PostgreSQL
DATABASE_URL=postgresql://usuariodb:tupasswordsecreto@localhost:5432/redsocialropa

# Autenticación (Firebase o Supabase Config)
JWT_SECRET_KEY=clave_super_secreta_para_firmar_tokens
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_KEY=eyJh... (tu clave anon o service role)

# APIs de Inteligencia Artificial (esencial para ai_celery.py)
OPENAI_API_KEY=sk-proj-tu-clave-de-chatgpt

# Almacenamiento de fotos (Ropa, Avatares, Posts)
AWS_ACCESS_KEY_ID=tu_access_key
AWS_SECRET_ACCESS_KEY=tu_secret_key
S3_BUCKET_NAME=armario-virtual-images

# Configuración de los Workers en segundo plano (Celery / Redis)
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0
```
