# Migración de los dotfiles de Omarchy 3 a Omarchy Quattro

## Propósito

Este documento registra los cambios preparados el 21 de agosto de 2026 para
Omarchy Quattro y revisados el 2 de octubre de 2026 antes de incorporarlos a Git.
Explica las diferencias respecto de Omarchy 3, la traducción de las
personalizaciones y el procedimiento de recuperación de la configuración anterior.

El repositorio conserva deliberadamente ambos formatos. Los archivos `.lua`
son la configuración actual de Quattro; los `.conf` y `waybar/` son la ruta de
retorno a Omarchy 3.

## Historia del repositorio y de la actualización

1. El 8 de mayo de 2026 se creó el repositorio con configuración Hyprland
   tradicional en archivos `.conf`. Esa versión quedó registrada inicialmente
   en el commit `6fd807b`.
2. El mismo día se añadieron los scripts de instalación y sincronización. Estos
   copiaban directorios completos mediante `rsync`.
3. El 17 de julio de 2026 se incorporó la selección del tema de iconos. El
   último commit anterior a esta migración fue `02d8a24`.
4. El 21 de agosto de 2026 el sistema se actualizó a Omarchy `4.0.0-1`, llamado
   Quattro, junto con Hyprland `0.56.2-1`.
5. La actualización creó `~/.config/hypr/hyprland.lua` y módulos Lua. Los
   archivos `.conf` permanecieron en disco, pero dejaron de controlar la sesión.
6. El antiguo instalador se ejecutó después de la actualización y volvió a
   copiar los `.conf` y Waybar. Esto no restableció los monitores porque Quattro
   continuó leyendo `hyprland.lua`.

Los respaldos automáticos observados durante la revisión fueron:

```text
~/.config/waybar.omarchy-upgrade-to-quattro.20260821195741.bak/
~/.config/hypr.backup.20260821_202320/
~/.config/hypr/hyprsunset.conf.omarchy-upgrade-to-quattro.20260821195741.bak
```

Estos respaldos son una segunda línea de recuperación local. El repositorio es
la copia mantenible de las personalizaciones de esta estación de trabajo.

## Diagnóstico de monitores durante la migración de agosto

En Omarchy 3, `hyprland.conf` incluía explícitamente `monitors.conf`. Allí se
definían escala, resolución y posición:

```text
eDP-1     1920x1080@60.015   0x0      escala 1
HDMI-A-1  1600x900@60        1920x0   escala 1
```

Quattro carga `hyprland.lua` y posteriormente `monitors.lua`. El archivo Lua
creado por la actualización sólo contenía una regla genérica con resolución
preferida, posición automática y escala automática. Por tanto, las reglas
explícitas de `monitors.conf` quedaron inertes.

Durante el diagnóstico Hyprland detectaba ambos monitores y, por coincidencia,
la selección automática producía la misma resolución y posición. Las posiciones
y los modos históricos ya no estaban fijados explícitamente.
Esto no demostraba un fallo de la selección automática: las reglas antiguas
simplemente habían dejado de cargarse. No existían errores de sintaxis en la
configuración.

El log mostró dos fallos transitorios de `atomic drm request` durante un cambio
de modo. Los modos se aplicaron inmediatamente después y no se encontró un
fallo persistente del controlador. La corrección principal era hacer explícita
la topología en Lua.

El panel interno también anuncia `1920x1080@144.03`, pero se mantuvieron los
60.015 Hz definidos históricamente. Cambiar a 144 Hz es una optimización posible,
no parte de esta migración conservadora.

## Ajuste de monitores en octubre

Al conectar un Samsung LS27C36x, la regla heredada del BenQ seguía imponiendo
`1600x900@60` al puerto HDMI. En Quattro se sustituyó ese modo fijo por
`preferred`: Hyprland elige la resolución y frecuencia preferidas anunciadas
por el monitor conectado. Se mantienen la posición `1920x0` y la escala 1.
El panel interno sigue en `1920x1080@60.015`, posición `0x0`, escala 1.

El modo preferido no equivale necesariamente a la frecuencia máxima admitida.
Tampoco conviene elegir siempre la mayor resolución aceptada: el BenQ admite
una señal 1080p aunque anuncia 1600x900 como su modo preferido. Las excepciones
futuras pueden asociarse a la descripción del monitor, en lugar de fijar la
resolución de un modelo a todo el puerto HDMI.

Durante esta revisión, Linux identificó el Samsung mediante sus datos EDID,
pero Hyprland conservaba la descripción del BenQ. Después de aplicar la regla,
Hyprland seguía reportando 1920x1080 a unos 60 Hz y no había errores de
configuración. Esto verifica la aplicación de la configuración, pero la
detección tras desconectar y reconectar físicamente otro monitor queda pendiente.
Los `.conf` históricos de Omarchy 3 conservan sus modos originales.

## Traducción de configuración

| Función | Omarchy 3 | Omarchy Quattro | Decisión |
|---|---|---|---|
| Entrada principal | `hyprland.conf` | `hyprland.lua` | Cargar defaults empaquetados y luego overrides personales. |
| Monitores | `monitor = ...` | `hl.monitor({...})` | Mantener el panel interno, posiciones y escala; elegir el modo preferido del HDMI. |
| Teclado y touchpad | bloque `input {}` | `hl.config({ input = ... })` | Mantener layout US, Compose en Caps Lock, repetición y scroll. |
| Reglas por aplicación | `windowrule` | `o.window(...)` | Mantener factores de scroll para terminales. |
| Apariencia | bloques `general` y `decoration` | `hl.config(...)` | Mantener gaps de 3 px y rounding de 8 px. |
| Atajos | `bindd` | `o.bind(...)` | Confiar en defaults de Quattro y conservar sólo Typora. |
| Autostart | `exec-once` | eventos Lua | Mantener SSHFS y CERNBox con guardas más seguras. |
| Barra | Waybar | Omarchy Shell | Guardar `shell.json`, incluido el widget Dropbox. |
| Escritorios persistentes | `persistent-workspaces` 1–6 | plugin personal `pxpalacios.workspaces` | Conservar seis escritorios visibles; el widget de Quattro trae cinco. |
| Fondo | enlace en `.config/omarchy/current` y `swaybg` | `omarchy theme bg set` | Usar el comando público de Quattro. |

### Atajo reemplazado

En Quattro, `SUPER+SHIFT+W` estaba asignado por defecto a Omawrite. La
configuración histórica lo usa para Typora. Por eso `bindings.lua` primero
ejecuta `hl.unbind("SUPER + SHIFT + W")` y después registra Typora. El resto de
los atajos antiguos ya existe en los defaults de Quattro y no se duplica.

### NVIDIA

El antiguo `hyprland.conf` definía manualmente `NVD_BACKEND`,
`LIBVA_DRIVER_NAME` y `__GLX_VENDOR_LIBRARY_NAME`. Quattro detecta NVIDIA desde
su módulo empaquetado y selecciona valores distintos según la disponibilidad de
GSP. Repetirlos en el archivo personal impediría que Omarchy corrigiera esa
selección en futuras actualizaciones; por eso no fueron trasladados a Lua.

### SSHFS

El montaje de `esmeralda:/mnt` se conserva, pero ahora comprueba primero
`mountpoint -q /mnt/esmeralda-mnt`. Así, reiniciar Hyprland no intenta montar
por segunda vez un filesystem que ya está activo.

### Seis escritorios persistentes

Waybar ya enumeraba explícitamente los escritorios `1` a `6`. El widget
`omarchy.workspaces` incorporado en Quattro define sólo `[1, 2, 3, 4, 5]`. Como
los plugins bajo `/usr/share/omarchy` pertenecen al paquete, no se modificó el
original. Se clonó mediante `omarchy plugin clone omarchy.workspaces`, se cambió
la lista a `[1, 2, 3, 4, 5, 6]` y el resultado se guarda en
`omarchy/plugins/pxpalacios.workspaces/`.

## Cambios en los scripts

El instalador anterior copiaba toda `~/.config/hypr`, reiniciaba Waybar incluso
en Quattro y ocultaba fallos de `hyprctl` mediante `|| true`. La sincronización
usaba `rsync --delete`, por lo que podía incorporar respaldos generados por
Omarchy o borrar archivos del repositorio accidentalmente.

Los scripts actuales:

- detectan Omarchy 3 u Omarchy 4, con selección explícita opcional;
- copian sólo archivos administrados;
- crean un respaldo fechado por archivo antes de instalar;
- instalan Lua y Omarchy Shell únicamente para Quattro;
- instalan `.conf` y Waybar únicamente para Omarchy 3;
- recargan Hyprland en ambas versiones cuando hay una sesión disponible y,
  en Quattro, consideran cualquier `configerrors` un fallo real;
- usan `omarchy theme bg set` en Quattro y conservan el mecanismo antiguo sólo
  para Omarchy 3.

## Procedimiento para volver a Omarchy 3

El repositorio restaura configuración, no paquetes. Primero debe completarse el
downgrade o la reinstalación real de Omarchy 3 mediante el procedimiento que sea
vigente en ese momento. Después:

1. Confirmar que la sesión utiliza el árbol histórico de Omarchy 3 bajo
   `~/.local/share/omarchy/` y que Waybar está instalado.
2. Desde este repositorio ejecutar:

   ```bash
   ./scripts/install.sh --omarchy-3
   ```

3. Cerrar y volver a iniciar la sesión si Hyprland o Waybar no pueden recargarse
   dentro de la sesión usada para hacer el downgrade.
4. Verificar:

   ```bash
   hyprctl monitors all
   hyprctl configerrors
   ```

5. Confirmar que existen las rutas siguientes:

   ```text
   ~/.config/hypr/hyprland.conf
   ~/.config/hypr/monitors.conf
   ~/.config/waybar/config.jsonc
   ~/.config/waybar/style.css
   ~/.config/omarchy/current/background
   ```

La opción `--omarchy-3` debe usarse sólo cuando el software Omarchy 3 ya esté
instalado. Ejecutarla bajo Quattro copiaría archivos históricos que Quattro no
lee y podría iniciar Waybar junto con Omarchy Shell si Waybar aún estuviera
instalado.

## Procedimiento para regresar nuevamente a Quattro

Después de reinstalar Omarchy 4:

```bash
./scripts/install.sh --omarchy-4
```

El instalador restaurará los módulos Lua, `shell.json`, el fondo mediante la API
de Omarchy y validará la configuración activa.

## Recuperación manual y trazabilidad Git

El commit `02d8a24` contiene el estado del repositorio antes de esta migración.
Puede inspeccionarse sin modificar el árbol de trabajo:

```bash
git show 02d8a24:hypr/monitors.conf
git show 02d8a24:scripts/install.sh
```

La configuración histórica mantenida actualmente es preferible para un
rollback porque incorpora cambios que existían justo antes de Quattro —CERNBox,
Foot, Music TUI y el módulo meteorológico de Waybar— y que el repositorio de mayo
todavía no contenía.

Nunca se deben modificar archivos dentro de `/usr/share/omarchy/`. Ese árbol
pertenece al paquete y cualquier cambio se perdería con la siguiente
actualización. El instalador copia los archivos administrados bajo
`${XDG_CONFIG_HOME:-$HOME/.config}`; además aplica el fondo y el tema de iconos
mediante los mecanismos de la versión seleccionada.

## Alcance de la configuración de barra

El repositorio conserva la barra preparada en agosto, con el plugin personal
`pxpalacios.workspaces` y widgets incorporados de Omarchy. La barra activa de
esta estación recibió después otros plugins personales y de terceros. Esas
adiciones no forman parte de esta migración. Instalar este snapshot restaura
la barra aquí descrita y respalda antes el archivo reemplazado.

El sincronizador copia `shell.json` completo, pero sólo incluye el plugin
personal de escritorios. Si se sincroniza una barra con otros plugins locales,
deben incorporarse también sus archivos y sus rutas de instalación y
sincronización antes de publicar el resultado. De otro modo, `shell.json`
contendría referencias a plugins ausentes en una instalación nueva.
