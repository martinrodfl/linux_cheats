#!/usr/bin/env bash
# config.sh - Configuración global del sistema de cheatsheets

# Validaciones iniciales
if ! command -v tput >/dev/null 2>&1; then
    echo "⚠️  Warning: tput no disponible, usando valores por defecto" >&2
    TERM_WIDTH=80
else
    TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
fi

# Constantes globales
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BASE_DIR="$(dirname "$SCRIPT_DIR")"
readonly DATA_DIR="$BASE_DIR/data"
readonly LIB_DIR="$BASE_DIR/lib"
readonly CONFIG_DIR="$BASE_DIR/config"
readonly MIN_TERM_WIDTH=60
readonly SEPARATOR_WIDTH=4
readonly VERSION="2.0"
readonly AUTHOR="Martin"

# Validar ancho mínimo del terminal
validate_terminal_width() {
    if [ "$TERM_WIDTH" -lt "$MIN_TERM_WIDTH" ]; then
        echo "❌ Error: Terminal demasiado pequeño (mín. $MIN_TERM_WIDTH columnas, actual: $TERM_WIDTH)" >&2
        echo "💡 Redimensiona tu terminal o usa 'tput cols' para verificar" >&2
        exit 1
    fi
}

# Configuración del layout
TILE_WIDTH=$(( (TERM_WIDTH - SEPARATOR_WIDTH) / 2 ))
CMD_WIDTH=$(( TILE_WIDTH / 2 - 3 ))
DESC_WIDTH=$(( TILE_WIDTH / 2 - 4 ))

# Variables de comportamiento (pueden ser sobreescritas)
SHOW_HELP=${SHOW_HELP:-false}
INTERACTIVE_MODE=${INTERACTIVE_MODE:-false}
COLOR_ENABLED=${COLOR_ENABLED:-true}
SELECTED_CATEGORY=${SELECTED_CATEGORY:-""}

# Colores ANSI
init_colors() {
    if [ "$COLOR_ENABLED" = "true" ]; then
        readonly RESET='\033[0m'
        readonly BOLD='\033[1m'
        readonly DIM='\033[2m'
        readonly RED='\033[0;31m'
        readonly GREEN='\033[0;32m'
        readonly YELLOW='\033[0;33m'
        readonly BLUE='\033[0;34m'
        readonly MAGENTA='\033[0;35m'
        readonly CYAN='\033[0;36m'
        readonly WHITE='\033[0;37m'
        readonly BG_RED='\033[41m'
        readonly BG_GREEN='\033[42m'
        readonly BG_YELLOW='\033[43m'
        readonly BG_BLUE='\033[44m'
        readonly BG_MAGENTA='\033[45m'
        readonly BG_CYAN='\033[46m'
    else
        readonly RESET=''
        readonly BOLD=''
        readonly DIM=''
        readonly RED=''
        readonly GREEN=''
        readonly YELLOW=''
        readonly BLUE=''
        readonly MAGENTA=''
        readonly CYAN=''
        readonly WHITE=''
        readonly BG_RED=''
        readonly BG_GREEN=''
        readonly BG_YELLOW=''
        readonly BG_BLUE=''
        readonly BG_MAGENTA=''
        readonly BG_CYAN=''
    fi
}

# Función para obtener valor de color por nombre
get_color() {
    local color_name="$1"
    case "$color_name" in
        "RED") echo "$RED" ;;
        "GREEN") echo "$GREEN" ;;
        "YELLOW") echo "$YELLOW" ;;
        "BLUE") echo "$BLUE" ;;
        "MAGENTA") echo "$MAGENTA" ;;
        "CYAN") echo "$CYAN" ;;
        "WHITE") echo "$WHITE" ;;
        "BG_RED") echo "$BG_RED" ;;
        "BG_GREEN") echo "$BG_GREEN" ;;
        "BG_YELLOW") echo "$BG_YELLOW" ;;
        "BG_BLUE") echo "$BG_BLUE" ;;
        "BG_MAGENTA") echo "$BG_MAGENTA" ;;
        "BG_CYAN") echo "$BG_CYAN" ;;
        *) echo "" ;;
    esac
}

# Configuración de archivos de datos
declare -A CATEGORY_FILES=(
    ["dnf"]="$DATA_DIR/dnf_commands.yaml"
    ["git"]="$DATA_DIR/git_commands.yaml"
    ["docker"]="$DATA_DIR/docker_commands.yaml"
    ["network"]="$DATA_DIR/network_commands.yaml"
    ["filesystem"]="$DATA_DIR/filesystem_commands.yaml"
    ["system"]="$DATA_DIR/system_commands.yaml"
    ["permissions"]="$DATA_DIR/permissions_commands.yaml"
    ["laravel"]="$DATA_DIR/laravel_commands.yaml"
    ["react"]="$DATA_DIR/react_commands.yaml"
    ["javascript"]="$DATA_DIR/javascript_commands.yaml"
    ["css"]="$DATA_DIR/css_commands.yaml"
    ["html"]="$DATA_DIR/html_commands.yaml"
    ["terminal"]="$DATA_DIR/terminal_apps.yaml"
)

# Función para verificar archivos de datos
validate_data_files() {
    local missing_files=()
    for category in "${!CATEGORY_FILES[@]}"; do
        if [ ! -f "${CATEGORY_FILES[$category]}" ]; then
            missing_files+=("${CATEGORY_FILES[$category]}")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "❌ Error: Archivos de datos faltantes:" >&2
        printf '  - %s\n' "${missing_files[@]}" >&2
        echo "💡 Ejecuta el script de instalación para crear los archivos necesarios" >&2
        exit 1
    fi
}

# Inicializar configuración
init_config() {
    validate_terminal_width
    init_colors
    validate_data_files
}

# Función para mostrar configuración (debug)
show_config() {
    echo "📋 CONFIGURACIÓN ACTUAL"
    echo "Base Dir: $BASE_DIR"
    echo "Data Dir: $DATA_DIR"  
    echo "Terminal Width: $TERM_WIDTH"
    echo "Tile Width: $TILE_WIDTH"
    echo "Colors Enabled: $COLOR_ENABLED"
    echo "Interactive Mode: $INTERACTIVE_MODE"
}