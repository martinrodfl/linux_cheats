#!/usr/bin/env bash
# display.sh - Funciones de renderizado y display

# Cargar configuración si no está cargada
if [ -z "$BASE_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/config.sh"
fi

# Función para imprimir el header
print_header() {
    local title="📚 COMMAND CHEATSHEET - Quick Reference v${VERSION}"
    if [ "$COLOR_ENABLED" = "true" ]; then
        echo -e "${CYAN}${BOLD}"
        printf '═%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "\n  $title"
        printf '═%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "${RESET}\n"
    else
        printf '=%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "\n  $title"
        printf '=%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "\n"
    fi
}

# Función para mostrar el footer
print_footer() {
    if [ "$COLOR_ENABLED" = "true" ]; then
        echo -e "${CYAN}${BOLD}"
        printf '═%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "${RESET}"
        echo -e "${WHITE}💡 Tips: 'man <comando>' | '$0 -h' ayuda | '$0 -i' interactivo | '$0 -c <cat>' categoría${RESET}"
        echo -e "${CYAN}${BOLD}"
        printf '═%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "${RESET}\n"
    else
        printf '=%.0s' $(seq 1 $TERM_WIDTH)
        echo ""
        echo "Tips: 'man <comando>' | '$0 -h' ayuda | '$0 -i' interactivo | '$0 -c <cat>' categoría"
        printf '=%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "\n"
    fi
}

# Función para truncar texto
truncate_text() {
    local text="$1"
    local max_len=$2
    if [ ${#text} -gt $max_len ]; then
        echo "${text:0:$((max_len-2))}.."
    else
        echo "$text"
    fi
}

# Función para imprimir dos tiles lado a lado
print_tiles_row() {
    local title1="$1"
    local color1="$2"
    local bg1="$3"
    shift 3
    
    # Buscar donde empieza el tile 2
    local tile1_cmds=()
    local tile2_cmds=()
    local title2=""
    local color2=""
    local bg2=""
    local in_tile2=false
    
    while [ $# -gt 0 ]; do
        if [[ "$1" == "TILE2:"* ]]; then
            in_tile2=true
            title2="${1#TILE2:}"
            color2="$2"
            bg2="$3"
            shift 3
            continue
        fi
        
        if [ "$in_tile2" = false ]; then
            tile1_cmds+=("$1")
        else
            tile2_cmds+=("$1")
        fi
        shift
    done
    
    # Determinar el máximo número de líneas
    local max_lines=${#tile1_cmds[@]}
    [ ${#tile2_cmds[@]} -gt $max_lines ] && max_lines=${#tile2_cmds[@]}
    
    # Headers
    local header1=$(truncate_text "$title1" $((TILE_WIDTH - 2)))
    local header2=$(truncate_text "$title2" $((TILE_WIDTH - 2)))
    
    # Obtener colores reales
    local real_color1=$(get_color "$color1")
    local real_bg1=$(get_color "$bg1")
    local real_color2=$(get_color "$color2")
    local real_bg2=$(get_color "$bg2")
    
    echo -ne "${real_bg1}${BOLD} ${title1} ${RESET}"
    printf ' %.0s' $(seq 1 $((TILE_WIDTH - ${#title1} - 2)))
    echo -ne "  ${real_bg2}${BOLD} ${title2} ${RESET}"
    printf ' %.0s' $(seq 1 $((TILE_WIDTH - ${#title2} - 2)))
    echo ""
    
    echo -ne "${real_color1}"
    printf '─%.0s' $(seq 1 $TILE_WIDTH)
    echo -ne "${RESET}  ${real_color2}"
    printf '─%.0s' $(seq 1 $TILE_WIDTH)
    echo -e "${RESET}"
    
    # Imprimir líneas
    for ((i=0; i<max_lines; i++)); do
        # Tile 1
        if [ $i -lt ${#tile1_cmds[@]} ]; then
            IFS='|' read -r cmd1 desc1 <<< "${tile1_cmds[$i]}"
            cmd1=$(truncate_text "$cmd1" $CMD_WIDTH)
            desc1=$(truncate_text "$desc1" $DESC_WIDTH)
            printf "${GREEN}%-${CMD_WIDTH}s${RESET} ${DIM}│${RESET} ${WHITE}%-${DESC_WIDTH}s${RESET}" "$cmd1" "$desc1"
        else
            # Espacio vacío para tile 1
            local empty_space=$((CMD_WIDTH + DESC_WIDTH + 3))
            printf "%-${empty_space}s" ""
        fi
        
        printf "  "
        
        # Tile 2
        if [ $i -lt ${#tile2_cmds[@]} ]; then
            IFS='|' read -r cmd2 desc2 <<< "${tile2_cmds[$i]}"
            cmd2=$(truncate_text "$cmd2" $CMD_WIDTH)
            desc2=$(truncate_text "$desc2" $DESC_WIDTH)
            printf "${GREEN}%-${CMD_WIDTH}s${RESET} ${DIM}│${RESET} ${WHITE}%-${DESC_WIDTH}s${RESET}" "$cmd2" "$desc2"
        else
            # Espacio vacío para tile 2
            local empty_space=$((CMD_WIDTH + DESC_WIDTH + 3))
            printf "%-${empty_space}s" ""
        fi
        
        echo ""
    done
    echo ""
}

# Función para tile simple (ancho completo)
print_full_tile() {
    local title="$1"
    local color="$2"
    local bg="$3"
    shift 3
    local commands=("$@")
    
    # Obtener colores reales
    local real_color=$(get_color "$color")
    local real_bg=$(get_color "$bg")
    
    # Header
    echo -e "${real_bg}${BOLD} ${title} ${RESET}"
    printf "${real_color}"
    printf '─%.0s' $(seq 1 $TERM_WIDTH)
    echo -e "${RESET}"
    
    # Comandos en 2 columnas
    local half=$(( (${#commands[@]} + 1) / 2 ))
    
    for ((i=0; i<half; i++)); do
        # Columna 1
        if [ $i -lt ${#commands[@]} ]; then
            IFS='|' read -r cmd1 desc1 <<< "${commands[$i]}"
            cmd1=$(truncate_text "$cmd1" $CMD_WIDTH)
            desc1=$(truncate_text "$desc1" $DESC_WIDTH)
            printf "${GREEN}%-${CMD_WIDTH}s${RESET} ${DIM}│${RESET} ${WHITE}%-${DESC_WIDTH}s${RESET}" "$cmd1" "$desc1"
        else
            local empty_space=$((CMD_WIDTH + DESC_WIDTH + 3))
            printf "%-${empty_space}s" ""
        fi
        
        printf "  "
        
        # Columna 2
        local j=$((i + half))
        if [ $j -lt ${#commands[@]} ]; then
            IFS='|' read -r cmd2 desc2 <<< "${commands[$j]}"
            cmd2=$(truncate_text "$cmd2" $CMD_WIDTH)
            desc2=$(truncate_text "$desc2" $DESC_WIDTH)
            printf "${GREEN}%-${CMD_WIDTH}s${RESET} ${DIM}│${RESET} ${WHITE}%-${DESC_WIDTH}s${RESET}" "$cmd2" "$desc2"
        else
            local empty_space=$((CMD_WIDTH + DESC_WIDTH + 3))
            printf "%-${empty_space}s" ""
        fi
        
        echo ""
    done
    echo ""
}

# Función para mostrar categoría desde archivo YAML
print_category_from_file() {
    local file_path="$1"
    local layout="${2:-full}"  # full o tile
    
    if [ ! -f "$file_path" ]; then
        echo "❌ Error: Archivo no encontrado: $file_path" >&2
        return 1
    fi
    
    # Extraer información del archivo YAML (soporta comillas simples y dobles)
    local name=$(grep "^name:" "$file_path" | head -1 | sed "s/^name: *['\"]//; s/['\"]$//")
    local color=$(grep "^color:" "$file_path" | head -1 | sed "s/^color: *['\"]//; s/['\"]$//")
    local background=$(grep "^background:" "$file_path" | head -1 | sed "s/^background: *['\"]//; s/['\"]$//")
    
    # Extraer comandos (soporta comillas simples y dobles)
    local commands=()
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*-[[:space:]]*[\'\"](.*)[\'\"][[:space:]]*$ ]]; then
            commands+=("${BASH_REMATCH[1]}")
        fi
    done < "$file_path"
    
    if [ "$layout" = "full" ]; then
        print_full_tile "$name" "$color" "$background" "${commands[@]}"
    fi
}

# Función para mostrar progreso
show_progress() {
    local current=$1
    local total=$2
    local message="$3"
    
    if [ "$COLOR_ENABLED" = "true" ]; then
        local percent=$((current * 100 / total))
        local filled=$((percent / 5))
        local empty=$((20 - filled))
        
        printf "\r${CYAN}[${GREEN}"
        printf '█%.0s' $(seq 1 $filled)
        printf "${DIM}"
        printf '░%.0s' $(seq 1 $empty)
        printf "${CYAN}] ${percent}%% ${WHITE}${message}${RESET}"
    else
        echo "[$current/$total] $message"
    fi
}