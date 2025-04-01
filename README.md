# 📋 App Fútbol Cuestionario

Aplicación Flutter para la gestión diaria de cuestionarios de jugadores, entrenadores y fisioterapeutas. Utiliza Supabase como backend y permite acceso según roles mediante PIN.

---

## 🚀 Funcionalidades principales

- Inicio de sesión con PIN y control de acceso por rol
- Cuestionarios diarios PRE y POST para jugadores
- Panel de administración para entrenadores y administradores
- Integración con Supabase (base de datos y autenticación)
- Almacenamiento local de respuestas para control diario

---

## 🧩 Estructura del proyecto

```
lib/
├── core/
│   ├── config/              # Configuración de Supabase
│   └── services/            # Lógica de sesión y datos
├── modules/
│   ├── admin/               # Pantallas de administración
│   ├── auth/                # Login por PIN
│   ├── post/                # Cuestionario POST
│   ├── pre/                 # Cuestionario PRE
│   └── shared/              # Pantallas compartidas
```

---

## 🔐 Configuración de claves Supabase

**Este archivo no se incluye por seguridad:**
```
lib/core/config/supabase_config.dart
```

1. Copia la plantilla:
```bash
cp lib/core/config/supabase_config.template.dart lib/core/config/supabase_config.dart
```
2. Rellena con tus claves reales:
```dart
class SupabaseConfig {
  static const supabaseUrl = 'https://TUSUPABASE.supabase.co';
  static const supabaseAnonKey = 'TU_ANON_KEY';
}
```

---

## ▶️ Cómo ejecutar el proyecto

```bash
flutter pub get
flutter run
```

---

## 🛡️ Control de acceso por roles

| Rol       | Accede a Formularios | Accede a Panel Admin |
|-----------|----------------------|-----------------------|
| admin     | ✅                   | ✅                    |
| coach     | ✅                   | ✅ *(temporal)*       |
| jugador   | ✅                   | ❌                    |
| fisio     | ✅                   | ❌                    |

> ⚠️ El rol se obtiene desde Supabase a partir del PIN introducido.

---

## 🛠️ Pendiente / Mejora futura

- Uso de variables de entorno con `flutter_dotenv`
- Exportación de respuestas como informe
- Estadísticas y visualización de datos
- Cierre de sesión desde la interfaz

---

## 📄 Licencia

Este proyecto está en desarrollo privado.
