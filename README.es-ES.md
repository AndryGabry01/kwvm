

# kwvm

**kwvm** es un script de Bash diseñado para gestionar monitores virtuales en sistemas Linux, específicamente adaptado para entornos KDE que utilizan herramientas como [krfb-virtualmonitor](https://invent.kde.org/network/krfb). Este script permite a los usuarios crear, modificar, eliminar y gestionar monitores virtuales de manera eficiente.

**Nota**: Este script es compatible **solo con KDE ejecutándose en Wayland**.

## Tabla de Contenidos

- [Características](#features)
- [Instalación](#installation)
- [Configuración](#setup)
- [Uso](#usage)
- [Comandos](#commands)
- [Ejemplos](#examples)
- [Licencia](#license)
- [Contribuciones](#contributing)

## Características

- **Crear monitores virtuales**: Crea nuevos monitores virtuales fácilmente con configuraciones personalizables.
- **Modificar monitores existentes**: Actualiza la configuración de los monitores virtuales existentes.
- **Eliminar monitores**: Elimina los monitores virtuales que ya no se necesiten.
- **Iniciar y detener monitores**: Controla el estado de los monitores virtuales.
- **Listar todos los monitores**: Muestra una lista de todos los monitores creados junto con sus detalles.
- **Comprobación de compatibilidad**: Verifica el entorno operativo y la presencia de las herramientas necesarias.

## Instalación

Para instalar **kwvm**, sigue estos pasos:

1. **Clonar el repositorio**:  
   git clone https://github.com/yourusername/kwvm.git  
   cd kwvm

2. **Hacer el script ejecutable**:  
   chmod +x kwvm.sh

Puedes colocar el script en cualquier directorio que prefieras. Por ejemplo, si colocas el script en una carpeta llamada `kwvm` en tu directorio principal (`$HOME/kwvm`), durante la primera ejecución, el script creará los directorios necesarios para los archivos de configuración y monitores dentro de esta carpeta, como `$HOME/kwvm/config` y `$HOME/kwvm/vmonitors`.

## Configuración

La primera vez que ejecutes el script, este realizará automáticamente un proceso de configuración:

./kwvm.sh

Esta configuración realizará:
- Creará los directorios necesarios (`vmonitors` y `config`).
- Generará un archivo de configuración predeterminado.
- Verificará el entorno del sistema (p. ej., Wayland, KDE, `krfb-virtualmonitor`).

## Uso

Para usar **kwvm**, ejecuta el script con uno de los comandos disponibles:

./kwvm.sh <command> [options]

## Comandos

- **create, c**: Crea un nuevo monitor virtual.
- **edit, e**: Modifica un monitor virtual existente por ID o nombre.
- **delete, d**: Elimina un monitor virtual por ID o nombre.
- **list, l**: Lista todos los monitores virtuales.
- **start, s**: Inicia un monitor virtual por ID o nombre.
- **stop, x**: Detiene un monitor virtual por ID o nombre.
- **killall, k**: Termina todos los monitores virtuales. Usa `-f` para forzar la terminación de todos los procesos de `krfb-virtualmonitor`.
- **alias, a**: Establece o elimina el alias para este script.
- **help, h**: Muestra información de ayuda.

## Ejemplos

- **Crear un nuevo monitor virtual**:  
  ./kwvm.sh create

- **Modificar un monitor por nombre**:  
  ./kwvm.sh edit monitor1

- **Eliminar un monitor por ID**:  
  ./kwvm.sh delete 2

- **Listar todos los monitores**:  
  ./kwvm.sh list

- **Iniciar un monitor por nombre**:  
  ./kwvm.sh start monitor1

- **Detener un monitor por ID**:  
  ./kwvm.sh stop 2

- **Terminar todos los monitores**:  
  ./kwvm.sh killall

- **Terminar por la fuerza todos los procesos de `krfb-virtualmonitor`**:  
  ./kwvm.sh killall -f

## Licencia

Este proyecto está licenciado bajo la Licencia Pública General de GNU v3 (GPLv3) con términos adicionales. Consulta el archivo [LICENSE](LICENSE) para más detalles.

## Contribuciones

¡Aceptamos contribuciones! Por favor, haz un fork del repositorio y envía un pull request con tus cambios. Asegúrate de seguir el estilo de código existente e incluir cualquier prueba necesaria con tu contribución.

Para obtener más información sobre `krfb-virtualmonitor`, visita el [repositorio de GitLab de KDE](https://invent.kde.org/network/krfb).

---

Para la versión en italiano de este README, consulta el [README en italiano](README_IT.md).
