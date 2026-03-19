# Diseño: Personalización Nexor Agro App

**Fecha:** 2026-03-17
**Estado:** Aprobado
**Alcance:** Branding, colores, traducción, package ID, assets

---

## Contexto

La app es un fork de [flutter_thingsboard_app](https://github.com/thingsboard/flutter_thingsboard_app) personalizada para Nexor Agro, empresa de gestión agrícola. Actualmente muestra la identidad de ThingsBoard en todo: nombre, colores azules, logos y textos. El objetivo es reemplazar toda referencia visible al usuario por la marca Nexor Agro, agregar soporte en español como idioma principal, e integrar los assets gráficos provistos por el usuario.

**Enfoque:** Branding en capas — cambiar strings, colores y assets sin renombrar clases ni archivos internos de Dart. Esto preserva la compatibilidad con futuras actualizaciones de ThingsBoard.

---

## Alcance de cambios

### 1. Nombre y textos visibles al usuario

| Archivo | Cambio |
|---------|--------|
| `lib/l10n/intl_en.arb` | `appTitle: "Nexor Agro"` + revisar todos los strings con "ThingsBoard" |
| `lib/l10n/intl_es.arb` | **Crear nuevo** — ~401 strings traducidos al español |
| `android/app/build.gradle` | Fallback label: `'Thingsboard app'` → `'Nexor Agro'` |
| `pubspec.yaml` | `description: "Nexor Agro — Gestión agrícola inteligente"` |

**Strings a reemplazar en intl_en.arb:**
- `"appTitle": "ThingsBoard"` → `"Nexor Agro"`
- `"logoDefaultValue": "ThingsBoard Logo"` → `"Nexor Agro Logo"`
- Cualquier ocurrencia literal de "ThingsBoard" en mensajes de usuario

### 2. Idioma / Localización

- **Español** como idioma por defecto del sistema, **inglés** como fallback
- Crear `lib/l10n/intl_es.arb` con todos los ~401 keys del inglés traducidos
- Correr `fvm flutter pub run intl_utils:generate` — detecta automáticamente el nuevo ARB y genera `lib/generated/intl/messages_es.dart` y actualiza `lib/generated/l10n.dart`
- **No editar `lib/generated/l10n.dart` manualmente** — es un archivo generado

### 3. Package ID y configuración Android

| Archivo | Antes | Después |
|---------|-------|---------|
| `android/app/build.gradle` línea 44 | `namespace "org.thingsboard.app"` | `namespace "com.nexoragro.app"` |
| `android/app/build.gradle` línea 52 | fallback `"org.thingsboard.app"` | fallback `"com.nexoragro.app"` |
| `android/app/src/main/AndroidManifest.xml` | `authScheme: thingsboard` | `authScheme: nexoragro` |
| `build_apk.bat` (Temp) | sin `androidApplicationId` | agregar `--dart-define=androidApplicationId=com.nexoragro.app` |
| `build_apk.bat` (Temp) | sin `androidApplicationName` | agregar `--dart-define=androidApplicationName=Nexor Agro` |

### 4. Colores del tema

**Archivo:** `lib/config/themes/app_colors.dart`

| Variable | Antes | Después |
|----------|-------|---------|
| `primaryBlue` | `#305680` | `#03363D` |
| `secondaryBlue` | `#527dad` | `#75925c` |
| `darkPrimaryBlue` | `#9fa8da` | `#055060` |

> Solo se cambian los valores hex. Los nombres de variables se mantienen para evitar cascada de cambios en los archivos de theme.

### 5. Spinner de carga (`TbProgressIndicator`)

**Archivo:** `lib/widgets/tb_progress_indicator.dart`

Reemplazar la implementación actual (AnimationController + dos SVGs giratorios) por un `CircularProgressIndicator` estándar de Flutter que respeta el color del tema:

```dart
// Reemplazar toda la lógica de AnimationController y SVGs por:
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(color),
  strokeWidth: 3.0,
)
```

La clase `TbProgressIndicator` se mantiene como wrapper para no romper los 17+ usos en el resto del código.

### 6. Assets gráficos

#### Carpeta de assets del usuario

El usuario coloca sus archivos en `assets_nexor/` (en la raíz del repo, fuera del código). El modelo ejecutor copia cada archivo al destino correcto.

```
App/assets_nexor/               ← el usuario pone sus archivos acá
  icon_filled.png                ← isotipo cuadrado, PNG 1024×1024, fondo blanco
  icon_foreground.png            ← mismo isotipo pero con margen interno (para adaptive icon Android), PNG 1024×1024, fondo transparente
  logo_color.svg                 ← logo completo con texto "Nexor Agro", SVG, en color sobre fondo transparente
  logo_white.svg                 ← mismo logo completo pero en blanco, SVG, sobre fondo transparente
  splash.png                     ← isotipo o logo para pantalla de carga, PNG 512×512, sobre fondo blanco
```

> **Nota `icon_foreground.png`:** Para el adaptive icon de Android, la imagen necesita un margen interno de al menos 25% (el sistema Android recorta bordes). El mismo isotipo que `icon_filled.png` funciona, idealmente con un poco más de padding.

#### Destinos de copia

| Archivo fuente (`assets_nexor/`) | Destino en el repo |
|----------------------------------|--------------------|
| `icon_filled.png` | `assets/branding/icon_filled.png` (reemplaza) |
| `icon_foreground.png` | `assets/branding/icon_foreground.png` (reemplaza) |
| `logo_color.svg` | `assets/images/nexor_logo.svg` (nuevo) |
| `logo_white.svg` | `assets/images/nexor_logo_white.svg` (nuevo) |
| `splash.png` | `assets/branding/splash.png` + `assets/branding/splash_android_12.png` (reemplaza ambos) |

#### Cambios de código para assets

- `lib/constants/assets_path.dart`: Agregar a la clase `ThingsboardImage` las constantes:
  ```dart
  static const nexorLogo = 'assets/images/nexor_logo.svg';
  static const nexorLogoWhite = 'assets/images/nexor_logo_white.svg';
  ```
- `pubspec.yaml` sección `assets`: verificar que `assets/images/` esté incluido (ya lo está)
- Reemplazar usos de `ThingsboardImage.thingsboard*` en pantallas de login y carga por las nuevas constantes Nexor

#### Regenerar íconos Android (después de copiar los PNGs)

```cmd
cd flutter_thingsboard_app
fvm flutter pub run flutter_launcher_icons
```
Genera automáticamente todas las densidades en `android/app/src/main/res/mipmap-*/`.

#### Regenerar splash screen (después de copiar los PNGs)

```cmd
cd flutter_thingsboard_app
fvm flutter pub run flutter_native_splash:create
```

---

## Archivos a modificar

```
lib/l10n/intl_en.arb                          ← strings EN, reemplazar "ThingsBoard"
lib/l10n/intl_es.arb                          ← NUEVO: traducción completa ES
lib/config/themes/app_colors.dart             ← colores primarios (solo valores hex)
lib/constants/assets_path.dart                ← agregar constantes nexorLogo, nexorLogoWhite
lib/widgets/tb_progress_indicator.dart        ← reemplazar por CircularProgressIndicator
android/app/build.gradle                      ← namespace + applicationId fallback
android/app/src/main/AndroidManifest.xml      ← authScheme
pubspec.yaml                                  ← description
assets/branding/                              ← PNGs (copiados desde assets_nexor/)
assets/images/                                ← SVGs (copiados desde assets_nexor/)

Generados automáticamente (no editar):
lib/generated/l10n.dart
lib/generated/intl/messages_es.dart
android/app/src/main/res/mipmap-*/            ← íconos Android (por flutter_launcher_icons)
```

---

## Orden de ejecución

1. **Textos y strings** — `intl_en.arb`, `pubspec.yaml`, `build.gradle` fallback
2. **Colores** — `app_colors.dart`
3. **Package ID** — `build.gradle`, `AndroidManifest.xml`, bat de build
4. **Traducción ES** — crear `intl_es.arb`, correr `intl_utils:generate`
5. **Spinner** — simplificar `tb_progress_indicator.dart`
6. **Assets gráficos** — copiar desde `assets_nexor/`, actualizar `assets_path.dart`, correr `flutter_launcher_icons` y `flutter_native_splash:create`

---

## Verificación

Build debug después de cada grupo de tareas:

```cmd
cmd //c "C:\Users\Tristan\AppData\Local\Temp\build_apk.bat"
```

| Tareas | Qué verificar |
|--------|---------------|
| 1–3 | App muestra "Nexor Agro", package ID es `com.nexoragro.app` |
| 4 | App en español al configurar dispositivo en `es-*` |
| 5 | Spinner usa `CircularProgressIndicator` (sin SVGs TB) |
| 6 | Ícono launcher y splash muestran logo Nexor |
