# OUTFY — Red Social de Moda

> **Trabajo Fin de Grado (TFG) · DAM 2025**
> Aplicación móvil Flutter para descubrir, organizar y compartir moda con tu comunidad.

---

## ¿Qué es OUTFY?

OUTFY es una red social centrada en la moda que permite a sus usuarios gestionar su armario virtual, publicar sus looks, descubrir tendencias y conectar con una comunidad de apasionados por el estilo. Combina las funcionalidades típicas de una red social (feed, perfiles, foro) con herramientas propias de un asistente de moda inteligente (armario virtual, generador de outfits con IA).

---

## Pantallas y funcionalidades actuales

### Inicio (Feed)
- Scroll vertical de publicaciones de la comunidad
- Filtros por categoría de prenda (tops, pantalones, vestidos, zapatos, accesorios, abrigos)
- Sistema de likes y comentarios
- Notificaciones en tiempo real (UI)

### Armario Virtual
- Catálogo personal de prendas organizado por categoría
- Filtros rápidos por tipo de ropa
- Añadir prendas con foto desde la cámara o galería
- Vista grid con iconos personalizados por categoría

### AI Outfits
- Generador de outfits con selección de ocasión y temporada
- Sugerencias visuales combinando prendas del armario
- Interfaz de resultado con vista detallada del conjunto

### Foro
- Comunidad con hilos de discusión por categorías (tendencias, consejos, marcas, sostenibilidad…)
- Creación de nuevos hilos con imagen adjunta
- Sistema de respuestas y votos

### Perfil
- Cabecera con avatar de iniciales, nombre completo y @usuario
- Estadísticas: publicaciones, seguidores, siguiendo, prendas
- Tres pestañas: posts propios, armario y guardados
- Edición de perfil completa con cooldown de username (7 días)

### Ajustes
- Privacidad: cuenta privada, mostrar ubicación, estado en línea
- Notificaciones: activar/desactivar push
- Información de la app y acceso a editar perfil

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3 (Dart 3.11+) |
| UI | Material 3 · Google Fonts (DM Sans) |
| Estado | ChangeNotifier + ListenableBuilder |
| Persistencia local | SharedPreferences |
| Imágenes | image_picker |
| Backend (planificado) | Python FastAPI + PostgreSQL |
| IA (planificada) | Celery · GPT-4 Vision · SAM |
| Almacenamiento (planificado) | Supabase Storage / AWS S3 |

---

## Estructura del proyecto

```
lib/
├── main.dart                   # Punto de entrada, tema, tokens de diseño y navegación principal
├── screens/
│   ├── feed_screen.dart        # Feed social con posts y filtros
│   ├── wardrobe_screen.dart    # Armario virtual por categorías
│   ├── ai_outfits_screen.dart  # Generador de outfits con IA
│   ├── forum_screen.dart       # Foro por categorías
│   ├── profile_screen.dart     # Perfil del usuario con tabs
│   ├── edit_profile_screen.dart# Edición de datos de perfil
│   ├── settings_screen.dart    # Ajustes de la app (privacidad, notificaciones)
│   ├── create_post_screen.dart # Creación de publicaciones
│   └── post_detail_screen.dart # Detalle de una publicación
├── services/
│   ├── profile_service.dart    # Gestión y persistencia del perfil
│   ├── posts_service.dart      # CRUD de publicaciones
│   └── settings_service.dart   # Ajustes de privacidad y notificaciones
├── models/
│   ├── user_post.dart          # Modelo de publicación con comentarios
│   └── post_model.dart         # Modelo del feed
└── widgets/
    ├── fashion_icon.dart       # Iconos dibujados por categoría de ropa
    └── outfy_app_bar.dart      # AppBar personalizado
```

---

## Sistema de diseño

**Paleta de colores principal:**

| Token | Color | Uso |
|-------|-------|-----|
| `primary` | `#1B6B44` | Botones, tabs activos, acentos |
| `primaryMed` | `#3CB87A` | Gradientes, botón central nav |
| `primaryLight` | `#6DD4A0` | Gradientes, avatares |
| `accentBg` | `#E8F5EE` | Fondo de chips y badges |
| `bgPage` | `#F4F7F5` | Fondo de pantalla |
| `bgCard` | `#FFFFFF` | Tarjetas y modales |
| `textPrimary` | `#0D1B12` | Texto principal |
| `textSec` | `#5A7066` | Texto secundario |
| `textHint` | `#9BB5AA` | Placeholders y etiquetas |

**Tipografía:** DM Sans (Google Fonts) · Material 3

---

## Cómo ejecutar el proyecto

```bash
# Clonar el repositorio
git clone https://github.com/FluidOs-afk/TEFEGE.git
cd TEFEGE

# Instalar dependencias
flutter pub get

# Lanzar en dispositivo/emulador
flutter run
```

**Requisitos:** Flutter SDK 3.11+ · Dart 3.11+ · Android Studio o VS Code

---

## Estado del proyecto

| Módulo | Estado |
|--------|--------|
| Feed con posts y filtros | ✅ Completo |
| Armario virtual con categorías | ✅ Completo |
| Generador AI Outfits (UI) | ✅ Completo |
| Foro con hilos y respuestas | ✅ Completo |
| Perfil con tabs | ✅ Completo |
| Editar perfil (local) | ✅ Completo |
| Pantalla de ajustes (local) | ✅ Completo |
| Autenticación de usuarios | 🔜 Pendiente |
| Backend FastAPI + PostgreSQL | 🔜 Pendiente |
| IA de análisis de prendas | 🔜 Pendiente |
| Notificaciones push reales | 🔜 Pendiente |
| Mensajería directa | 🔜 Pendiente |

> Toda la persistencia actual es local (SharedPreferences). La integración con la base de datos se implementará en la siguiente fase.

---

## Arquitectura planificada (Backend)

El backend está diseñado siguiendo un modelo de pipeline de datos inspirado en arquitecturas BI:

```
App Flutter → FastAPI (Python) → PostgreSQL
                    ↓
              Celery Workers
                    ↓
        GPT-4 Vision + SAM (IA)
                    ↓
         Supabase Storage (fotos)
```

Para más detalles, consulta [`arquitectura/README.md`](arquitectura/README.md) y [`arquitectura/arquitectura_bi.md`](arquitectura/arquitectura_bi.md).

---

## Autor

**Aitor** · DAM 2025  
Proyecto TFG — Desarrollo de Aplicaciones Multiplataforma
