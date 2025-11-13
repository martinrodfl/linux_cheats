# 📚 Cheatsheets Modular System

Sistema de cheatsheets refactorizado y modular para comandos de Linux, con soporte para múltiples categorías, búsqueda interactiva y personalización.

## 🌟 Características

- ✅ **Modular**: Datos separados de lógica
- ✅ **Extensible**: Fácil agregar nuevas categorías
- ✅ **Configurable**: Personalizable por usuario
- ✅ **Interactivo**: Navegación y búsqueda
- ✅ **Responsive**: Se adapta al ancho del terminal
- ✅ **Colorizado**: Soporte para colores opcional

## 📁 Estructura del Proyecto

```
mis_scripts/
├── cheatsheets.sh              # Script original (legacy)
├── cheatsheets_new.sh          # Script principal refactorizado
├── install_cheatsheets.sh      # Instalador automático
├── README.md                   # Esta documentación
└── cheatsheets/                # Directorio modular
    ├── data/                   # Archivos de datos YAML
    │   ├── dnf_commands.yaml
    │   ├── git_commands.yaml
    │   ├── docker_commands.yaml
    │   ├── network_commands.yaml
    │   ├── filesystem_commands.yaml
    │   ├── system_commands.yaml
    │   └── permissions_commands.yaml
    ├── lib/                    # Módulos de funciones
    │   ├── config.sh           # Configuración global
    │   ├── display.sh          # Funciones de renderizado
    │   └── utils.sh            # Utilidades y helpers
    └── config/                 # Configuraciones personalizadas
```

## 🚀 Instalación Rápida

```bash
# Clonar o descargar el proyecto
cd mis_scripts/

# Ejecutar instalador automático
./install_cheatsheets.sh
```

El instalador:

- Crea la estructura en `~/.config/cheatsheets/`
- Instala el comando `cheatsheet` en `~/.local/bin/`
- Configura el PATH automáticamente
- Crea configuración personalizable

## 📖 Uso

### Uso Básico

```bash
cheatsheet                    # Mostrar todas las categorías
cheatsheet -c git            # Solo comandos Git
cheatsheet -i                # Modo interactivo
cheatsheet -h                # Ayuda completa
```

### Opciones Disponibles

```bash
-h, --help          Mostrar ayuda
-i, --interactive   Modo interactivo
-n, --no-color     Desactivar colores
-c, --category     Mostrar categoría específica
-l, --list         Listar categorías disponibles
-v, --version      Mostrar versión
-d, --debug        Información de debug
```

### Categorías Incluidas

- **dnf**: Gestión de paquetes
- **git**: Control de versiones
- **docker**: Contenedores
- **network**: Redes y conectividad
- **filesystem**: Sistema de archivos
- **system**: Información del sistema
- **permissions**: Permisos y usuarios

## ⚙️ Personalización

### Agregar Nueva Categoría

1. **Crear archivo de datos** en `~/.config/cheatsheets/data/`:

```yaml
# nueva_categoria_commands.yaml
name: 'NUEVA CATEGORIA - Descripción'
color: 'BLUE'
background: 'BG_BLUE'
category: 'nueva-categoria'
commands:
  - 'comando1|Descripción del comando'
  - 'comando2|Otra descripción'
```

2. **Registrar en configuración** (`~/.config/cheatsheets/lib/config.sh`):

```bash
declare -A CATEGORY_FILES=(
    # ... categorías existentes ...
    ["nueva"]="$DATA_DIR/nueva_categoria_commands.yaml"
)
```

### Modificar Comandos Existentes

Edita directamente los archivos YAML en `~/.config/cheatsheets/data/`:

```bash
nano ~/.config/cheatsheets/data/git_commands.yaml
```

### Configuración de Usuario

Archivo: `~/.config/cheatsheets/user_config.sh`

```bash
# Habilitar/deshabilitar colores
USER_COLOR_ENABLED=true

# Categorías favoritas
USER_FAVORITE_CATEGORIES="git docker"

# Comandos personalizados
USER_CUSTOM_COMMANDS=(
    "htop|Monitor interactivo"
    "ncdu|Analizador de espacio"
)
```

## 🔧 Desarrollo

### Estructura de Módulos

#### `lib/config.sh`

- Configuración global y constantes
- Manejo de colores
- Validaciones del sistema
- Mapeo de archivos de categorías

#### `lib/display.sh`

- Funciones de renderizado
- Layouts de tiles y columnas
- Headers y footers
- Parsing de archivos YAML

#### `lib/utils.sh`

- Utilidades auxiliares
- Búsqueda interactiva
- Menús y navegación
- Funciones de sistema

### Formato de Datos YAML

```yaml
name: 'CATEGORIA - Descripción'
color: 'COLOR_NAME' # RED, GREEN, BLUE, etc.
background: 'BG_COLOR_NAME' # BG_RED, BG_GREEN, etc.
category: 'categoria-slug'
commands:
  - 'comando arg|Descripción clara y concisa'
  - 'otro comando|Otra descripción útil'
```

## 🐛 Troubleshooting

### Comando no encontrado

```bash
# Verificar PATH
echo $PATH | grep ~/.local/bin

# Añadir manualmente
export PATH="$HOME/.local/bin:$PATH"

# Ejecutar directamente
~/.local/bin/cheatsheet
```

### Archivos faltantes

```bash
# Re-ejecutar instalador
./install_cheatsheets.sh

# Verificar estructura
ls ~/.config/cheatsheets/
```

### Colores no funcionan

```bash
# Verificar soporte de terminal
echo $TERM

# Forzar desactivar colores
cheatsheet --no-color
```

## 📈 Ventajas vs Versión Original

| Aspecto             | Original | Modular          |
| ------------------- | -------- | ---------------- |
| **Mantenibilidad**  | ⭐⭐     | ⭐⭐⭐⭐⭐       |
| **Extensibilidad**  | ⭐⭐     | ⭐⭐⭐⭐⭐       |
| **Organización**    | ⭐⭐⭐   | ⭐⭐⭐⭐⭐       |
| **Personalización** | ⭐       | ⭐⭐⭐⭐⭐       |
| **Instalación**     | ⭐⭐⭐   | ⭐⭐⭐⭐⭐       |
| **Líneas código**   | ~550     | ~300 (principal) |
| **Archivos**        | 1        | 10+ modulares    |

## 🔄 Migración

Para migrar de la versión original:

1. Ejecuta `./install_cheatsheets.sh`
2. Tus datos existentes se preservan
3. El comando nuevo coexiste con el original
4. Gradualmente reemplaza el uso

## 🤝 Contribuir

1. Agrega nuevas categorías en `data/`
2. Mejora las funciones en `lib/`
3. Extiende la documentación
4. Reporta bugs y sugerencias

## 📄 Licencia

MIT License - Libre para usar, modificar y distribuir.

---

**Autor**: Martin  
**Versión**: 2.0  
**Fecha**: Noviembre 2025
