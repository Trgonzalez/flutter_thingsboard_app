# Nexor Agro App — Personalización Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar toda referencia visible a ThingsBoard por la marca Nexor Agro, aplicar la paleta de colores Nexor, agregar traducción al español, cambiar el package ID, simplificar el spinner y preparar la integración de assets gráficos.

**Architecture:** Branding en capas sobre flutter_thingsboard_app — solo se cambian strings, colores, config y assets. Las clases y archivos internos de Dart mantienen sus nombres para facilitar futuros merges con el upstream de ThingsBoard.

**Tech Stack:** Flutter 3.29.0 (FVM), Dart, `intl_utils` para codegen de localización, `flutter_launcher_icons` y `flutter_native_splash` para assets Android.

**Spec:** `docs/superpowers/specs/2026-03-17-nexor-app-customization-design.md`

---

## Prerequisito: verificar que el build funciona

Antes de cualquier tarea, confirmar que el build parte de un estado limpio.

- [ ] Verificar que el bat de build existe:
  ```cmd
  ls "C:/Users/Tristan/AppData/Local/Temp/build_apk.bat"
  ```
  Si no existe, crearlo con este contenido exacto:
  ```bat
  @echo off
  set ANDROID_HOME=C:\Users\Tristan\AppData\Local\Android\Sdk
  set ANDROID_SDK_ROOT=C:\Users\Tristan\AppData\Local\Android\Sdk
  set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
  set PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%JAVA_HOME%\bin
  cd /d C:\Users\Tristan\Desktop\Nexor\App\flutter_thingsboard_app
  C:\Users\Tristan\AppData\Local\Pub\Cache\bin\fvm.bat flutter build apk --debug ^
    --dart-define=thingsboardApiEndpoint=https://app.nexoragro.com ^
    --dart-define=thingsboardAppSecret=dTJXazFDbkN2eGJudVNSa3hrME1TbkRKQ3NGdklKRmJUd2tTSDN4c0ZZSXZjdGs4a2RMVjRHVUFTSVFSUDkybQ==
  ```

- [ ] Correr el build base:
  ```cmd
  cmd //c "C:\Users\Tristan\AppData\Local\Temp\build_apk.bat"
  ```
  Esperado: BUILD SUCCESSFUL, APK en `build/app/outputs/flutter-apk/app-debug.apk`

---

## Task 1: Strings visibles EN + metadatos del proyecto

**Files:**
- Modify: `lib/l10n/intl_en.arb`
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle`

### Contexto

`intl_en.arb` es un archivo JSON con ~401 keys de strings en inglés. Los keys que contienen "ThingsBoard" visible al usuario deben cambiarse. **Solo cambiar strings que un usuario ve en pantalla**, no keys internos de error técnico irrelevantes.

Keys a cambiar en `intl_en.arb`:
- `"appTitle"`: `"ThingsBoard"` → `"Nexor Agro"`
- `"logoDefaultValue"`: `"ThingsBoard Logo"` → `"Nexor Agro Logo"`
- Buscar todas las ocurrencias de `"ThingsBoard"` (case-insensitive) en los valores (no en los keys) y evaluar si son visibles al usuario; cambiarlas por `"Nexor Agro"`

- [ ] Abrir `lib/l10n/intl_en.arb` y hacer grep de `ThingsBoard` en valores:
  ```bash
  grep -n "ThingsBoard\|Thingsboard\|thingsboard" lib/l10n/intl_en.arb
  ```

- [ ] Cambiar en `lib/l10n/intl_en.arb`:
  ```json
  "appTitle": "Nexor Agro",
  ```
  ```json
  "logoDefaultValue": "Nexor Agro Logo",
  ```
  Y cualquier otro valor visible con "ThingsBoard".

- [ ] Cambiar en `pubspec.yaml` (línea `description:`):
  ```yaml
  description: "Nexor Agro — Gestión agrícola inteligente"
  ```

- [ ] Cambiar en `android/app/build.gradle` el fallback de label (buscar `'Thingsboard app'`):
  ```groovy
  def customLabel = getDartDefineValue('androidApplicationName') ?: 'Nexor Agro'
  ```

- [ ] Build de verificación:
  ```cmd
  cmd //c "C:\Users\Tristan\AppData\Local\Temp\build_apk.bat"
  ```
  Esperado: BUILD SUCCESSFUL

- [ ] Commit:
  ```bash
  git -C flutter_thingsboard_app add lib/l10n/intl_en.arb pubspec.yaml android/app/build.gradle
  git -C flutter_thingsboard_app commit -m "branding: rename ThingsBoard → Nexor Agro in user-visible strings"
  ```

---

## Task 2: Colores del tema

**Files:**
- Modify: `lib/config/themes/app_colors.dart`

### Contexto

`app_colors.dart` define constantes de color estáticas usadas en todos los themes. Solo se cambian los valores hex; los nombres de las variables se mantienen igual para no tocar `tb_theme.dart`, `dark_theme.dart` ni `tb_ce_theme.dart`.

Colores a cambiar:
| Variable | Valor actual | Nuevo valor |
|----------|-------------|-------------|
| `primaryBlue` | `#305680` | `#03363D` |
| `secondaryBlue` | `#527dad` | `#75925c` |
| `darkPrimaryBlue` | `#9fa8da` | `#055060` |

- [ ] Leer `lib/config/themes/app_colors.dart` para confirmar los valores actuales y la estructura del archivo.

- [ ] Cambiar los tres valores hex en `lib/config/themes/app_colors.dart`:
  ```dart
  static const primaryBlue = Color(0xFF03363D);
  static const secondaryBlue = Color(0xFF75925C);
  static const darkPrimaryBlue = Color(0xFF055060);
  ```
  > Nota: los colores en Flutter se expresan como `0xFF` + hex en mayúsculas sin `#`. Ejemplo: `#03363D` → `0xFF03363D`.

- [ ] Build de verificación:
  ```cmd
  cmd //c "C:\Users\Tristan\AppData\Local\Temp\build_apk.bat"
  ```
  Esperado: BUILD SUCCESSFUL

- [ ] Commit:
  ```bash
  git -C flutter_thingsboard_app add lib/config/themes/app_colors.dart
  git -C flutter_thingsboard_app commit -m "branding: update color palette to Nexor Agro (#03363D, #75925c)"
  ```

---

## Task 3: Package ID y configuración Android

**Files:**
- Modify: `android/app/build.gradle`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify/Create: `C:/Users/Tristan/AppData/Local/Temp/build_apk.bat`

### Contexto

El package ID identifica la app en Android. Cambiarlo de `org.thingsboard.app` a `com.nexoragro.app` afecta el `namespace` de Gradle (para el código generado de R), el `applicationId` por defecto (fallback cuando no se pasa por dart-define), y el `authScheme` en el manifest (usado para deep-links y OAuth callbacks).

- [ ] En `android/app/build.gradle`, cambiar línea de `namespace`:
  ```groovy
  namespace "com.nexoragro.app"
  ```

- [ ] En la misma sección `defaultConfig` de `android/app/build.gradle`, cambiar el fallback de `applicationId`:
  ```groovy
  applicationId getDartDefineValue('androidApplicationId') ?: "com.nexoragro.app"
  ```

- [ ] Buscar dónde está declarado el `authScheme`:
  ```bash
  grep -n "authScheme\|thingsboard" android/app/build.gradle android/app/src/main/AndroidManifest.xml
  ```
  - Si está en `build.gradle` (sintaxis Groovy): `manifestPlaceholders["authScheme"] = "thingsboard"` → cambiar `"thingsboard"` por `"nexoragro"`
  - Si está en `AndroidManifest.xml` (sintaxis XML): `android:scheme="thingsboard"` → cambiar por `android:scheme="nexoragro"`
  Actualizar solo el archivo donde se encontró.

- [ ] Actualizar el bat de build en `C:/Users/Tristan/AppData/Local/Temp/build_apk.bat`. Agregar las dos líneas con `^` al final de los dart-defines existentes:
  ```bat
  C:\Users\Tristan\AppData\Local\Pub\Cache\bin\fvm.bat flutter build apk --debug ^
    --dart-define=thingsboardApiEndpoint=https://app.nexoragro.com ^
    --dart-define=thingsboardAppSecret=dTJXazFDbkN2eGJudVNSa3hrME1TbkRKQ3NGdklKRmJUd2tTSDN4c0ZZSXZjdGs4a2RMVjRHVUFTSVFSUDkybQ== ^
    --dart-define=androidApplicationId=com.nexoragro.app ^
    --dart-define=androidApplicationName=Nexor Agro
  ```

- [ ] Build de verificación:
  ```cmd
  cmd //c "C:\Users\Tristan\AppData\Local\Temp\build_apk.bat"
  ```
  Esperado: BUILD SUCCESSFUL

- [ ] Commit:
  ```bash
  git -C flutter_thingsboard_app add android/app/build.gradle android/app/src/main/AndroidManifest.xml
  git -C flutter_thingsboard_app commit -m "branding: change package ID to com.nexoragro.app"
  ```

---

## Task 4: Traducción al español (intl_es.arb)

**Files:**
- Create: `lib/l10n/intl_es.arb`
- Auto-generated: `lib/generated/intl/messages_es.dart`, `lib/generated/l10n.dart`

### Contexto

El sistema de localización usa `intl_utils`. Los archivos `.arb` en `lib/l10n/` son la fuente de verdad. Al crear `intl_es.arb` y correr `intl_utils:generate`, el generador crea automáticamente `lib/generated/intl/messages_es.dart` y actualiza `lib/generated/l10n.dart` para incluir el locale `es`.

**IMPORTANTE:** `lib/generated/l10n.dart` es un archivo generado. NO editarlo manualmente; el generador lo sobreescribe.

El archivo `intl_es.arb` debe tener exactamente los mismos keys que `intl_en.arb`, con los valores traducidos al español. Puede tener una entrada `@@locale` al principio:

```json
{
  "@@locale": "es",
  "appTitle": "Nexor Agro",
  "devices": "{count, plural, =1{Dispositivo} other{Dispositivos}}",
  ...
}
```

- [ ] Leer completo `lib/l10n/intl_en.arb` para obtener todos los keys y valores a traducir.

- [ ] Crear `lib/l10n/intl_es.arb` con todos los ~401 keys traducidos al español.

  Guía de traducción:
  - Mantener el key exactamente igual (lado izquierdo del JSON)
  - Mantener los placeholders intactos: `{count}`, `{time}`, `{appTitle}`, etc.
  - Mantener la sintaxis de plurales ICU: `{count, plural, =1{...} other{...}}`
  - `appTitle` → `"Nexor Agro"` (no traducir nombres propios)
  - No traducir strings de errores técnicos HTTP/API que van a logs (los que son puramente técnicos)

  Ejemplos de traducciones clave:
  ```json
  {
    "@@locale": "es",
    "appTitle": "Nexor Agro",
    "login": "Iniciar sesión",
    "logout": "Cerrar sesión",
    "email": "Correo electrónico",
    "password": "Contraseña",
    "devices": "{count, plural, =1{Dispositivo} other{Dispositivos}}",
    "dashboard": "Panel",
    "dashboards": "Paneles",
    "alarms": "Alarmas",
    "profile": "Perfil",
    "settings": "Configuración",
    "save": "Guardar",
    "cancel": "Cancelar",
    "delete": "Eliminar",
    "loading": "Cargando...",
    "noData": "Sin datos"
  }
  ```

- [ ] Verificar que el archivo es JSON válido:
  ```bash
  python3 -c "import json; json.load(open('lib/l10n/intl_es.arb'))" 2>&1 || echo "JSON inválido"
  ```

- [ ] Correr el generador de localización:
  ```cmd
  cd C:\Users\Tristan\Desktop\Nexor\App\flutter_thingsboard_app
  C:\Users\Tristan\AppData\Local\Pub\Cache\bin\fvm.bat flutter pub run intl_utils:generate
  ```
  Esperado: se crea `lib/generated/intl/messages_es.dart`

- [ ] Verificar que el archivo fue generado:
  ```bash
  ls lib/generated/intl/messages_es.dart
  ```

- [ ] Build de verificación:
  ```cmd
  cmd //c "C:\Users\Tristan\AppData\Local\Temp\build_apk.bat"
  ```
  Esperado: BUILD SUCCESSFUL

- [ ] Verificar manualmente en dispositivo/emulador: configurar idioma del sistema en español → la app debe mostrarse en español.

- [ ] Commit:
  ```bash
  git -C flutter_thingsboard_app add lib/l10n/intl_es.arb lib/generated/
  git -C flutter_thingsboard_app commit -m "i18n: add Spanish translation (intl_es.arb)"
  ```

---

## Task 5: Simplificar spinner de carga

**Files:**
- Modify: `lib/widgets/tb_progress_indicator.dart`

### Contexto

`TbProgressIndicator` extiende `ProgressIndicator` y actualmente usa un `AnimationController` + dos SVGs de ThingsBoard superpuestos. Se reemplaza por un `CircularProgressIndicator` estándar de Flutter, manteniendo la clase pública y sus parámetros (`size`, `valueColor`) intactos para no romper los ~17 callers.

La lógica de color actual es:
```dart
Color _getValueColor(BuildContext context) =>
    valueColor?.value ?? Theme.of(context).primaryColor;
```
Esta misma lógica se usa en el nuevo `build`.

El `_TbProgressIndicatorState` actualmente usa `TickerProviderStateMixin` para el `AnimationController`. Con el reemplazo, ya no se necesita nada de eso.

- [ ] Reemplazar el contenido completo de `lib/widgets/tb_progress_indicator.dart` con:

  ```dart
  import 'package:flutter/material.dart';

  class TbProgressIndicator extends ProgressIndicator {

    const TbProgressIndicator({
      super.key,
      this.size = 36.0,
      super.valueColor,
      super.semanticsLabel,
      super.semanticsValue,
    }) : super(
            value: null,
          );
    final double size;

    @override
    State<StatefulWidget> createState() => _TbProgressIndicatorState();

    Color _getValueColor(BuildContext context) =>
        valueColor?.value ?? Theme.of(context).primaryColor;
  }

  class _TbProgressIndicatorState extends State<TbProgressIndicator> {
    @override
    Widget build(BuildContext context) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            widget._getValueColor(context),
          ),
          strokeWidth: 3.0,
        ),
      );
    }
  }
  ```

  > Nota: se elimina `dart:math`, `flutter_svg`, `assets_path.dart`, `TickerProviderStateMixin`, `AnimationController` y `CurvedAnimation` — ya no se necesitan.

- [ ] Build de verificación:
  ```cmd
  cmd //c "C:\Users\Tristan\AppData\Local\Temp\build_apk.bat"
  ```
  Esperado: BUILD SUCCESSFUL (sin warnings de imports no usados)

- [ ] Commit:
  ```bash
  git -C flutter_thingsboard_app add lib/widgets/tb_progress_indicator.dart
  git -C flutter_thingsboard_app commit -m "branding: replace TB spinner with standard CircularProgressIndicator"
  ```

---

## Task 6: Assets gráficos

**Files:**
- Modify: `assets/branding/icon_filled.png` (reemplazar)
- Modify: `assets/branding/icon_foreground.png` (reemplazar)
- Modify: `assets/branding/splash.png` (reemplazar)
- Modify: `assets/branding/splash_android_12.png` (reemplazar)
- Create: `assets/images/nexor_logo.svg`
- Create: `assets/images/nexor_logo_white.svg`
- Modify: `lib/constants/assets_path.dart`

### Prerequisito

El usuario debe haber colocado sus archivos en la carpeta `assets_nexor/` (en `App/`, no dentro de `flutter_thingsboard_app/`):

```
App/assets_nexor/
  icon_filled.png         ← isotipo cuadrado PNG 1024×1024, fondo blanco
  icon_foreground.png     ← mismo isotipo PNG 1024×1024, fondo transparente, con margen 25%
  logo_color.svg          ← logo completo con texto, SVG, en color, fondo transparente
  logo_white.svg          ← logo completo en blanco, SVG, fondo transparente
  splash.png              ← isotipo o logo PNG 512×512, fondo blanco
```

- [ ] Verificar que los archivos existen:
  ```bash
  ls "../assets_nexor/"
  ```
  Si faltan archivos, **detener y avisar al usuario** qué archivos faltan antes de continuar.

- [ ] Copiar los archivos a sus destinos:
  ```bash
  cp ../assets_nexor/icon_filled.png assets/branding/icon_filled.png
  cp ../assets_nexor/icon_foreground.png assets/branding/icon_foreground.png
  cp ../assets_nexor/splash.png assets/branding/splash.png
  cp ../assets_nexor/splash.png assets/branding/splash_android_12.png
  cp ../assets_nexor/logo_color.svg assets/images/nexor_logo.svg
  cp ../assets_nexor/logo_white.svg assets/images/nexor_logo_white.svg
  ```
  > Los comandos asumen que el working directory es `flutter_thingsboard_app/`.

- [ ] Verificar que `assets/images/` está declarado en `pubspec.yaml`:
  ```bash
  grep "assets/images" pubspec.yaml
  ```
  Si no aparece, agregar en la sección `flutter: > assets:`:
  ```yaml
  - assets/images/
  ```
  (ya debería estar, pero si falta los SVGs nuevos darán error en runtime)

- [ ] Agregar las constantes Nexor en `lib/constants/assets_path.dart`, dentro de la clase `ThingsboardImage`, después de las constantes existentes:
  ```dart
  static const nexorLogo = 'assets/images/nexor_logo.svg';
  static const nexorLogoWhite = 'assets/images/nexor_logo_white.svg';
  ```

- [ ] Buscar los usos del logo de ThingsBoard en pantallas de login y about para reemplazarlos:
  ```bash
  grep -rn "ThingsboardImage.thingsboard\b\|ThingsboardImage.thingsBoardWithTitle\|ThingsboardImage.thingsboardBigLogo" lib/
  ```
  Para cada resultado, evaluar si es un logo principal visible en una pantalla de usuario y reemplazar por `ThingsboardImage.nexorLogo` o `ThingsboardImage.nexorLogoWhite` según el contexto (oscuro = white, claro = color).

- [ ] Regenerar íconos Android:
  ```cmd
  cd C:\Users\Tristan\Desktop\Nexor\App\flutter_thingsboard_app
  C:\Users\Tristan\AppData\Local\Pub\Cache\bin\fvm.bat flutter pub run flutter_launcher_icons
  ```
  Esperado: se actualizan `android/app/src/main/res/mipmap-*/launcher_icon.png` en todas las densidades.

- [ ] Regenerar splash screen:
  ```cmd
  C:\Users\Tristan\AppData\Local\Pub\Cache\bin\fvm.bat flutter pub run flutter_native_splash:create
  ```
  Esperado: se actualizan los drawables de splash en `android/app/src/main/res/drawable-*/`.

- [ ] Build de verificación:
  ```cmd
  cmd //c "C:\Users\Tristan\AppData\Local\Temp\build_apk.bat"
  ```
  Esperado: BUILD SUCCESSFUL

- [ ] Instalar en dispositivo/emulador y verificar visualmente:
  - Ícono del launcher muestra el isotipo de Nexor
  - Splash screen muestra el logo de Nexor sobre fondo blanco
  - Pantalla de login muestra el logo de Nexor
  - Spinner de carga es un `CircularProgressIndicator` en verde `#03363D`

- [ ] Commit:
  ```bash
  git -C flutter_thingsboard_app add assets/branding/ assets/images/nexor_logo.svg assets/images/nexor_logo_white.svg lib/constants/assets_path.dart android/app/src/main/res/
  git -C flutter_thingsboard_app commit -m "branding: add Nexor Agro assets (icons, logos, splash)"
  ```

---

## Notas de mantenimiento

**Cuando ThingsBoard lance una nueva versión:**
1. Pull del upstream en tu fork
2. Resolver conflictos en los archivos modificados (son pocos y bien delimitados)
3. En `intl_en.arb`: los nuevos strings que agregue TB necesitan ser traducidos también a `intl_es.arb`
4. Correr `intl_utils:generate` después de actualizar los ARBs
5. Build de verificación

Los archivos de `assets/branding/` y `assets/images/nexor_*` son propios de Nexor y no tienen conflicto con TB.
