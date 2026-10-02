# dotfiles_omarchy

Dotfiles personales compatibles con Omarchy Quattro y con una ruta explícita
de retorno a Omarchy 3.

## Estado actual

La configuración principal es Omarchy 4 (Quattro), que usa Hyprland en Lua y
Omarchy Shell sobre Quickshell:

```text
hypr/*.lua             configuración activa de Hyprland 0.55+
omarchy/shell.json     barra, plugins y tiempos de bloqueo de Omarchy Shell
omarchy/plugins/       widgets personales clonados de Omarchy Shell
```

La configuración histórica de Omarchy 3 se conserva en el mismo repositorio:

```text
hypr/*.conf            configuración Hyprland anterior a Quattro
waybar/config.jsonc    barra Waybar de Omarchy 3
waybar/style.css       estilo Waybar de Omarchy 3
```

Los archivos comunes a ambas versiones son:

```text
starship/starship.toml
mimeapps/mimeapps.list
scripts/set-background.sh
scripts/set-icon-theme.sh
```

## Instalar

El instalador detecta la versión instalada y crea un respaldo fechado de cada
archivo antes de reemplazarlo:

```bash
./scripts/install.sh
```

También se puede indicar el destino explícitamente:

```bash
./scripts/install.sh --omarchy-4
./scripts/install.sh --omarchy-3
```

La opción para Omarchy 3 restaura los `.conf` y Waybar, pero no rebaja paquetes.
Debe ejecutarse después de reinstalar o volver efectivamente a Omarchy 3.

Estos dotfiles contienen preferencias de esta estación: el fondo requiere la
imagen configurada en `scripts/set-background.sh`, y el inicio de sesión usa
CERNBox y un montaje SSHFS de `esmeralda`. El repositorio no instala esas
aplicaciones, la imagen ni las credenciales SSH.

## Sincronizar desde el sistema

```bash
./scripts/sync-from-system.sh
```

El script sincroniza únicamente los archivos administrados por este repositorio.
No usa `rsync --delete`, no copia respaldos y no elimina configuraciones ajenas.
Después de sincronizar siempre debe revisarse `git diff`. En Quattro se copia
`shell.json` completo, pero sólo se administra el plugin personal
`pxpalacios.workspaces`. Si la barra activa utiliza otros plugins locales,
hay que añadir también sus archivos y su instalación/sincronización para que
el repositorio siga siendo autocontenido respecto de esos plugins.

## Monitores

En Omarchy Quattro, la pantalla interna conserva su configuración y el monitor
HDMI usa la resolución y frecuencia preferidas que anuncia el dispositivo conectado:

```text
eDP-1     1920x1080 @ 60.015 Hz   posición 0x0       escala 1
HDMI-A-1  preferred              posición 1920x0    escala 1
```

Esto permite alternar entre monitores sin fijar la resolución de un modelo al
puerto HDMI. `preferred` no garantiza la frecuencia máxima: un monitor que
admite 75 Hz puede anunciar 60 Hz como modo preferido.

Existe además una regla genérica `preferred/auto` para las demás salidas. La
posición del HDMI se mantiene a la derecha de la pantalla interna. La selección
automática depende de que Hyprland detecte correctamente el monitor conectado.

La configuración histórica de Omarchy 3 (`hypr/monitors.conf`) conserva los
modos fijos originales para el retorno a esa versión.

## Escritorios

Se muestran siempre seis escritorios virtuales, incluso cuando están vacíos.
Omarchy 3 lo implementa mediante `persistent-workspaces` en Waybar. Quattro usa
el clon personal `pxpalacios.workspaces`, porque el widget incorporado de
Omarchy muestra solamente cinco escritorios persistentes.

La barra guardada corresponde a la migración de agosto. Las personalizaciones
posteriores de la barra activa no se importan automáticamente al repositorio;
instalar estos archivos restaura la barra guardada, previo respaldo.

## Historia y rollback

La explicación completa de la migración, las decisiones tomadas y el proceso
de retorno está en [MIGRACION_OMARCHY_3_A_QUATTRO.md](MIGRACION_OMARCHY_3_A_QUATTRO.md).
