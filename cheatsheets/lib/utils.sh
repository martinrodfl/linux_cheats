#!/usr/bin/env bash
# utils.sh - Funciones auxiliares y utilidades

# Cargar configuración si no está cargada
if [ -z "$BASE_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/config.sh"
fi

# Función para mostrar ayuda
show_help() {
    echo -e "${CYAN}${BOLD}📚 CHEATSHEET SCRIPT - Ayuda${RESET}\n"
    echo -e "${YELLOW}Uso:${RESET} $0 [opciones]\n"
    echo -e "${YELLOW}Opciones:${RESET}"
    echo -e "  -h, --help          Mostrar esta ayuda"
    echo -e "  -i, --interactive   Modo interactivo con navegación"
    echo -e "  -n, --no-color      Desactivar colores"
    echo -e "  -c, --category CAT  Mostrar solo una categoría específica"
    echo -e "  -l, --list          Listar categorías disponibles"
    echo -e "  -v, --version       Mostrar versión"
    echo -e "  -d, --debug         Mostrar información de debug\n"
    echo -e "${YELLOW}Categorías disponibles:${RESET}"
    echo -e "  $(list_categories | tr '\n' ', ' | sed 's/, $//')\n"
    echo -e "${YELLOW}Ejemplos:${RESET}"
    echo -e "  $0                    ${DIM}# Mostrar todos los comandos${RESET}"
    echo -e "  $0 -i                 ${DIM}# Modo interactivo${RESET}"
    echo -e "  $0 -c git             ${DIM}# Solo comandos Git${RESET}"
    echo -e "  $0 --no-color         ${DIM}# Sin colores${RESET}"
    echo -e "  $0 -l                 ${DIM}# Listar categorías${RESET}\n"
    echo -e "${YELLOW}Shortcuts en modo interactivo:${RESET}"
    echo -e "  ${GREEN}q${RESET} = quit  ${GREEN}h${RESET} = help  ${GREEN}s${RESET} = search  ${GREEN}c${RESET} = categories\n"
    echo -e "${YELLOW}Archivos de datos:${RESET}"
    echo -e "  Ubicación: ${DIM}$DATA_DIR/${RESET}"
    echo -e "  Formato: YAML con comandos organizados por categoría\n"
}

# Función para listar categorías disponibles
list_categories() {
    for category in "${!CATEGORY_FILES[@]}"; do
        echo "$category"
    done | sort
}

# Función para mostrar información de versión
show_version() {
    echo -e "${CYAN}${BOLD}Cheatsheet Script${RESET}"
    echo -e "Versión: ${GREEN}$VERSION${RESET}"
    echo -e "Autor: ${YELLOW}$AUTHOR${RESET}"
    echo -e "Ubicación: ${DIM}$BASE_DIR${RESET}"
}

# Función de búsqueda interactiva mejorada
search_commands() {
    echo -e "\n${YELLOW}🔍 Búsqueda de comandos${RESET}"
    echo -e "${DIM}Escribe una palabra clave (o 'q' para salir):${RESET}"
    read -p "> " search_term
    
    if [ "$search_term" = "q" ] || [ -z "$search_term" ]; then
        return
    fi
    
    echo -e "\n${GREEN}Resultados para: '${search_term}'${RESET}"
    echo -e "${DIM}$(printf '─%.0s' $(seq 1 50))${RESET}"
    
    local found=0
    for category_file in "${CATEGORY_FILES[@]}"; do
        if [ -f "$category_file" ]; then
            local category_name=$(basename "$category_file" _commands.yaml)
            
            # Buscar en comandos (soporta comillas simples y dobles)
            while IFS= read -r line; do
                if [[ $line =~ ^[[:space:]]*-[[:space:]]*[\'\"](.*)[\'\"][[:space:]]*$ ]]; then
                    local cmd_line="${BASH_REMATCH[1]}"
                    if [[ $cmd_line =~ $search_term ]]; then
                        IFS='|' read -r cmd desc <<< "$cmd_line"
                        echo -e "  ${GREEN}$cmd${RESET} ${DIM}→${RESET} ${WHITE}$desc${RESET} ${DIM}[$category_name]${RESET}"
                        ((found++))
                    fi
                fi
            done < "$category_file"
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo -e "  ${RED}No se encontraron resultados${RESET}"
        echo -e "  ${DIM}Intenta con otros términos como: git, docker, chmod, etc.${RESET}"
    else
        echo -e "\n${DIM}Encontrados: $found comandos${RESET}"
    fi
    
    echo -e "\n${DIM}Presiona Enter para continuar...${RESET}"
    read -r
}

# Función para modo interactivo
interactive_menu() {
    while true; do
        clear
        print_header
        echo -e "${YELLOW}🎯 MENÚ INTERACTIVO${RESET}\n"
        echo -e "  ${GREEN}1${RESET}) Ver todas las categorías"
        echo -e "  ${GREEN}2${RESET}) Buscar comandos" 
        echo -e "  ${GREEN}3${RESET}) Ver categoría específica"
        echo -e "  ${GREEN}4${RESET}) Información del sistema"
        echo -e "  ${GREEN}5${RESET}) Listar categorías disponibles"
        echo -e "  ${GREEN}d${RESET}) Debug - Mostrar configuración"
        echo -e "  ${GREEN}h${RESET}) Ayuda"
        echo -e "  ${GREEN}q${RESET}) Salir"
        
        echo -e "\n${DIM}Selecciona una opción:${RESET}"
        read -p "> " choice
        
        case "$choice" in
            1) show_all_categories; pause ;;
            2) search_commands ;;
            3) select_category ;;
            4) show_system_info ;;
            5) list_categories_interactive ;;
            d) show_config; pause ;;
            h) show_help; pause ;;
            q) echo -e "${GREEN}👋 ¡Hasta luego!${RESET}"; exit 0 ;;
            *) echo -e "${RED}❌ Opción inválida${RESET}"; sleep 1 ;;
        esac
    done
}

# Función para mostrar info del sistema
show_system_info() {
    clear
    echo -e "${CYAN}${BOLD}💻 INFORMACIÓN DEL SISTEMA${RESET}\n"
    echo -e "${GREEN}Terminal:${RESET} $TERM_WIDTH columnas x $(tput lines 2>/dev/null || echo "?") líneas"
    echo -e "${GREEN}Shell:${RESET} $SHELL"
    echo -e "${GREEN}Usuario:${RESET} $(whoami)@$(hostname)"
    echo -e "${GREEN}SO:${RESET} $(uname -s) $(uname -r)"
    echo -e "${GREEN}Fecha:${RESET} $(date)"
    echo -e "${GREEN}Uptime:${RESET} $(uptime | cut -d',' -f1 | cut -d' ' -f4-)"
    echo -e "${GREEN}Carga:${RESET} $(uptime | grep -ohe 'load average[s:][: ].*' | sed 's/load average[s:][: ]//')"
    
    if command -v free >/dev/null 2>&1; then
        local mem_info=$(free -h | grep '^Mem:')
        local mem_used=$(echo $mem_info | awk '{print $3}')
        local mem_total=$(echo $mem_info | awk '{print $2}')
        echo -e "${GREEN}Memoria:${RESET} $mem_used / $mem_total"
    fi
    
    echo -e "\n${GREEN}Archivos de cheatsheet:${RESET}"
    for category in $(list_categories); do
        local file="${CATEGORY_FILES[$category]}"
        if [ -f "$file" ]; then
            local count=$(grep -E "^[[:space:]]*-[[:space:]]*['\"]" "$file" | wc -l)
            printf "  ${WHITE}%-15s${RESET}: ${DIM}%d comandos${RESET}\n" "$category" "$count"
        fi
    done
    
    pause
}

# Función para listar categorías de forma interactiva
list_categories_interactive() {
    clear
    echo -e "${CYAN}${BOLD}📂 CATEGORÍAS DISPONIBLES${RESET}\n"
    
    local i=1
    for category in $(list_categories); do
        local file="${CATEGORY_FILES[$category]}"
        local count=0
        if [ -f "$file" ]; then
            # Contar comandos con soporte para comillas simples y dobles
            count=$(grep -E "^[[:space:]]*-[[:space:]]*['\"]" "$file" | wc -l)
        fi
        printf "  ${GREEN}%2d${RESET}) ${WHITE}%-15s${RESET} ${DIM}(%d comandos)${RESET}\n" "$i" "$category" "$count"
        ((i++))
    done
    
    pause
}

# Función para seleccionar categoría
select_category() {
    clear
    echo -e "${YELLOW}📂 Selecciona una categoría:${RESET}\n"
    
    local categories=($(list_categories))
    local i=1
    for category in "${categories[@]}"; do
        echo -e "  ${GREEN}$i${RESET}) $category"
        ((i++))
    done
    echo -e "  ${GREEN}0${RESET}) Todas las categorías"
    
    echo -e "\n${DIM}Ingresa el número:${RESET}"
    read -p "> " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [ "$choice" -eq 0 ]; then
            show_all_categories
        elif [ "$choice" -le "${#categories[@]}" ] && [ "$choice" -gt 0 ]; then
            local selected_category="${categories[$((choice-1))]}"
            show_category "$selected_category"
        else
            echo -e "${RED}❌ Número inválido${RESET}"
            sleep 1
            return
        fi
    else
        echo -e "${RED}❌ Ingresa un número válido${RESET}"
        sleep 1
        return
    fi
    
    pause
}

# Función para pausa
pause() {
    echo -e "\n${DIM}Presiona Enter para continuar...${RESET}"
    read -r
}

# Función para log de debug
debug_log() {
    if [ "${DEBUG:-false}" = "true" ]; then
        echo -e "${DIM}[DEBUG] $*${RESET}" >&2
    fi
}

# Función para validar categoría
validate_category() {
    local category="$1"
    for valid_category in "${!CATEGORY_FILES[@]}"; do
        if [ "$category" = "$valid_category" ]; then
            return 0
        fi
    done
    return 1
}

# Función para cargar comandos de archivo YAML
load_commands_from_yaml() {
    local file_path="$1"
    local -n commands_array=$2
    
    if [ ! -f "$file_path" ]; then
        debug_log "Archivo no encontrado: $file_path"
        return 1
    fi
    
    commands_array=()
    while IFS= read -r line; do
        # Detectar líneas con comandos (soporta comillas simples y dobles)
        if [[ $line =~ ^[[:space:]]*-[[:space:]]*[\'\"](.*)[\'\"][[:space:]]*$ ]]; then
            commands_array+=("${BASH_REMATCH[1]}")
        fi
    done < "$file_path"
    
    debug_log "Cargados ${#commands_array[@]} comandos de $file_path"
    return 0
}