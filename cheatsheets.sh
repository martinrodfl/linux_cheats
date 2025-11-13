#!/usr/bin/env bash

# Command Cheatsheet Display - Tile Layout
# Muestra comandos útiles en formato de columnas
# Autor: Martin | Versión: 2.0 | Fecha: $(date +%Y-%m-%d)

set -euo pipefail  # Modo estricto

# Validaciones iniciales
if ! command -v tput >/dev/null 2>&1; then
    echo "⚠️  Warning: tput no disponible, usando valores por defecto"
    TERM_WIDTH=80
else
    TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
fi

# Validar ancho mínimo del terminal
if [ "$TERM_WIDTH" -lt 60 ]; then
    echo "❌ Error: Terminal demasiado pequeño (mín. 60 columnas, actual: $TERM_WIDTH)"
    echo "💡 Redimensiona tu terminal o usa 'tput cols' para verificar"
    exit 1
fi

# Colores
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'

# Configuración del layout
readonly MIN_TERM_WIDTH=60
readonly SEPARATOR_WIDTH=4
TILE_WIDTH=$(( (TERM_WIDTH - SEPARATOR_WIDTH) / 2 ))
CMD_WIDTH=$(( TILE_WIDTH / 2 - 3 ))
DESC_WIDTH=$(( TILE_WIDTH / 2 - 4 ))

# Configuración de comportamiento
SHOW_HELP=${SHOW_HELP:-false}
INTERACTIVE_MODE=${INTERACTIVE_MODE:-false}
COLOR_ENABLED=${COLOR_ENABLED:-true}

# Función para mostrar ayuda
show_help() {
    cat << EOF
${CYAN}${BOLD}📚 CHEATSHEET SCRIPT - Ayuda${RESET}

${YELLOW}Uso:${RESET} $0 [opciones]

${YELLOW}Opciones:${RESET}
  -h, --help          Mostrar esta ayuda
  -i, --interactive   Modo interactivo con navegación
  -n, --no-color      Desactivar colores
  -c, --category CAT  Mostrar solo una categoría específica
  
${YELLOW}Categorías disponibles:${RESET}
  dnf, git, docker, network, filesystem, system, permissions, all

${YELLOW}Ejemplos:${RESET}
  $0                    # Mostrar todos los comandos
  $0 -i                 # Modo interactivo
  $0 -c git             # Solo comandos Git
  $0 --no-color         # Sin colores

${YELLOW}Shortcuts:${RESET}
  q = quit, h = help, n = next, p = previous

EOF
}

# Función para imprimir el header
print_header() {
    local title="📚 COMMAND CHEATSHEET - Quick Reference"
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
        echo ""
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

# Función de búsqueda interactiva
search_commands() {
    echo -e "\n${YELLOW}🔍 Búsqueda de comandos${RESET}"
    echo -e "${DIM}Escribe una palabra clave (o 'q' para salir):${RESET}"
    read -p "> " search_term
    
    if [ "$search_term" = "q" ]; then
        return
    fi
    
    echo -e "\n${GREEN}Resultados para: '$search_term'${RESET}"
    echo -e "${DIM}$(printf '─%.0s' $(seq 1 40))${RESET}"
    
    # Buscar en todas las secciones (esto se puede expandir)
    grep -i "$search_term" "$0" | grep -E '\|' | head -10 | while IFS='|' read -r cmd desc; do
        cmd=$(echo "$cmd" | sed 's/.*"//' | sed 's/".*//')
        echo -e "${GREEN}$cmd${RESET} ${DIM}→${RESET} ${WHITE}$desc${RESET}"
    done
    
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
        echo -e "  ${GREEN}h${RESET}) Ayuda"
        echo -e "  ${GREEN}q${RESET}) Salir"
        
        echo -e "\n${DIM}Selecciona una opción:${RESET}"
        read -p "> " choice
        
        case "$choice" in
            1) show_all_categories; read -p "Presiona Enter..." ;;
            2) search_commands ;;
            3) select_category ;;
            4) show_system_info ;;
            h) show_help; read -p "Presiona Enter..." ;;
            q) echo "👋 ¡Hasta luego!"; exit 0 ;;
            *) echo "❌ Opción inválida"; sleep 1 ;;
        esac
    done
}

# Función para mostrar info del sistema
show_system_info() {
    clear
    echo -e "${CYAN}${BOLD}💻 INFORMACIÓN DEL SISTEMA${RESET}\n"
    echo -e "${GREEN}Terminal:${RESET} $TERM_WIDTH columnas"
    echo -e "${GREEN}Shell:${RESET} $SHELL"
    echo -e "${GREEN}Usuario:${RESET} $(whoami)"
    echo -e "${GREEN}SO:${RESET} $(uname -s)"
    echo -e "${GREEN}Kernel:${RESET} $(uname -r)"
    echo -e "${GREEN}Fecha:${RESET} $(date)"
    echo -e "\n${DIM}Presiona Enter para continuar...${RESET}"
    read -r
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
    
    # Padding para centrar títulos
    local pad1=$(( (TILE_WIDTH - ${#title1} - 2) / 2 ))
    local pad2=$(( (TILE_WIDTH - ${#title2} - 2) / 2 ))
    
    echo -ne "${bg1}${BOLD} ${title1} ${RESET}"
    printf ' %.0s' $(seq 1 $((TILE_WIDTH - ${#title1} - 2)))
    echo -ne "  ${bg2}${BOLD} ${title2} ${RESET}"
    printf ' %.0s' $(seq 1 $((TILE_WIDTH - ${#title2} - 2)))
    echo ""
    
    echo -ne "${color1}"
    printf '─%.0s' $(seq 1 $TILE_WIDTH)
    echo -ne "${RESET}  ${color2}"
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
            printf "%-${TILE_WIDTH}s" ""
        fi
        
        printf "  "
        
        # Tile 2
        if [ $i -lt ${#tile2_cmds[@]} ]; then
            IFS='|' read -r cmd2 desc2 <<< "${tile2_cmds[$i]}"
            cmd2=$(truncate_text "$cmd2" $CMD_WIDTH)
            desc2=$(truncate_text "$desc2" $DESC_WIDTH)
            printf "${GREEN}%-${CMD_WIDTH}s${RESET} ${DIM}│${RESET} ${WHITE}%-${DESC_WIDTH}s${RESET}" "$cmd2" "$desc2"
        else
            printf "%-${TILE_WIDTH}s" ""
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
    
    # Header
    echo -e "${bg}${BOLD} ${title} ${RESET}"
    printf "${color}"
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
            printf "%-${TILE_WIDTH}s" ""
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
            printf "%-${TILE_WIDTH}s" ""
        fi
        
        echo ""
    done
    echo ""
}

# Función para parsear argumentos
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE_MODE=true
                shift
                ;;
            -n|--no-color)
                COLOR_ENABLED=false
                # Resetear colores
                RESET=''
                BOLD=''
                DIM=''
                RED=''
                GREEN=''
                YELLOW=''
                BLUE=''
                MAGENTA=''
                CYAN=''
                WHITE=''
                BG_RED=''
                BG_GREEN=''
                BG_YELLOW=''
                BG_BLUE=''
                BG_MAGENTA=''
                BG_CYAN=''
                shift
                ;;
            -c|--category)
                if [ -n "${2:-}" ]; then
                    SELECTED_CATEGORY="$2"
                    shift 2
                else
                    echo "❌ Error: -c requiere especificar una categoría"
                    exit 1
                fi
                ;;
            *)
                echo "❌ Opción desconocida: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Función principal
main() {
    parse_arguments "$@"
    
    if [ "$INTERACTIVE_MODE" = "true" ]; then
        interactive_menu
        return
    fi
    
    clear
    print_header
    
    if [ -n "${SELECTED_CATEGORY:-}" ]; then
        show_category "$SELECTED_CATEGORY"
    else
        show_all_categories
    fi
}

# Función para mostrar todas las categorías
show_all_categories() {

# ============================================================================
# DNF y GIT
# ============================================================================
print_tiles_row "DNF - Package Manager" "$RED" "$BG_RED" \
    "dnf search <pkg>|Buscar paquetes" \
    "dnf install <pkg>|Instalar paquete" \
    "dnf update|Actualizar sistema" \
    "dnf remove <pkg>|Eliminar paquete" \
    "dnf list installed|Listar instalados" \
    "dnf info <pkg>|Info del paquete" \
    "dnf clean all|Limpiar caché" \
    "dnf history|Ver historial" \
    "dnf autoremove|Limpiar dependencias" \
    "TILE2:GIT - Version Control" "$YELLOW" "$BG_YELLOW" \
    "git clone <url>|Clonar repositorio" \
    "git status|Estado de archivos" \
    "git add .|Añadir cambios" \
    "git commit -m 'msg'|Crear commit" \
    "git push|Subir cambios" \
    "git pull|Traer cambios" \
    "git branch|Listar ramas" \
    "git checkout -b <br>|Nueva rama" \
    "git merge <branch>|Fusionar rama" \
    "git log --oneline|Ver historial" \
    "git stash|Guardar temporal" \
    "git reset --hard|Deshacer commit"

# ============================================================================
# DOCKER y NETWORK
# ============================================================================
print_tiles_row "DOCKER - Containers" "$BLUE" "$BG_BLUE" \
    "docker ps|Contenedores activos" \
    "docker ps -a|Todos contenedores" \
    "docker images|Listar imágenes" \
    "docker run -d <img>|Ejecutar container" \
    "docker exec -it <id> bash|Entrar a container" \
    "docker stop <id>|Detener container" \
    "docker rm <id>|Eliminar container" \
    "docker rmi <image>|Eliminar imagen" \
    "docker logs <id>|Ver logs" \
    "docker-compose up -d|Levantar servicios" \
    "docker system prune -a|Limpiar todo" \
    "TILE2:NETWORK - Networking" "$MAGENTA" "$BG_MAGENTA" \
    "ip addr show|Ver interfaces" \
    "ip route show|Tabla de rutas" \
    "ping <host>|Probar conectividad" \
    "curl <url>|Petición HTTP" \
    "wget <url>|Descargar archivo" \
    "netstat -tuln|Puertos abiertos" \
    "ss -tuln|Sockets (moderno)" \
    "nmap <host>|Escanear puertos" \
    "traceroute <host>|Rastrear ruta" \
    "dig <domain>|Consulta DNS" \
    "nc -zv <host> <port>|Test puerto"

# ============================================================================
# FILE SYSTEM y SYSTEM
# ============================================================================
print_tiles_row "FILE SYSTEM - Management" "$CYAN" "$BG_CYAN" \
    "ls -lah|Listar detallado" \
    "cd <path>|Cambiar directorio" \
    "pwd|Directorio actual" \
    "mkdir -p dir/sub|Crear directorios" \
    "cp -r src dest|Copiar recursivo" \
    "mv src dest|Mover/renombrar" \
    "rm -rf dir|Eliminar recursivo" \
    "find . -name '*.log'|Buscar archivos" \
    "grep -r 'text' .|Buscar en archivos" \
    "tar -czf file.tar.gz|Comprimir" \
    "tar -xzf file.tar.gz|Extraer" \
    "du -sh *|Tamaño archivos" \
    "df -h|Espacio en disco" \
    "TILE2:SYSTEM - System Info" "$GREEN" "$BG_GREEN" \
    "uname -a|Info del kernel" \
    "hostnamectl|Info del host" \
    "uptime|Tiempo encendido" \
    "free -h|Memoria disponible" \
    "top|Monitor procesos" \
    "htop|Monitor interactivo" \
    "ps aux|Listar procesos" \
    "systemctl status <svc>|Estado servicio" \
    "journalctl -xe|Logs del sistema" \
    "lsblk|Dispositivos bloque" \
    "dmesg|Logs del kernel"

# ============================================================================
# PERMISSIONS (full width)
# ============================================================================
print_full_tile "PERMISSIONS - Users & Access" "$YELLOW" "$BG_YELLOW" \
    "chmod 755 file|Cambiar permisos" \
    "chmod +x script.sh|Hacer ejecutable" \
    "chown user:group file|Cambiar propietario" \
    "sudo command|Ejecutar como root" \
    "su - username|Cambiar de usuario" \
    "whoami|Ver usuario actual" \
    "id|Ver ID y grupos" \
    "passwd|Cambiar contraseña"
}

# Función para mostrar el footer
print_footer() {
    if [ "$COLOR_ENABLED" = "true" ]; then
        echo -e "${CYAN}${BOLD}"
        printf '═%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "${RESET}"
        echo -e "${WHITE}💡 Tips: Usa 'man <comando>' | '$0 -h' para ayuda | '$0 -i' para modo interactivo${RESET}"
        echo -e "${CYAN}${BOLD}"
        printf '═%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "${RESET}\n"
    else
        printf '=%.0s' $(seq 1 $TERM_WIDTH)
        echo ""
        echo "Tips: Usa 'man <comando>' | '$0 -h' para ayuda | '$0 -i' para modo interactivo"
        printf '=%.0s' $(seq 1 $TERM_WIDTH)
        echo -e "\n"
    fi
}

# Funciones para categorías específicas
show_category() {
    local category="$1"
    case "$category" in
        dnf|git)
            print_tiles_row "DNF - Package Manager" "$RED" "$BG_RED" \
                "dnf search <pkg>|Buscar paquetes" \
                "dnf install <pkg>|Instalar paquete" \
                "dnf update|Actualizar sistema" \
                "dnf remove <pkg>|Eliminar paquete" \
                "TILE2:GIT - Version Control" "$YELLOW" "$BG_YELLOW" \
                "git clone <url>|Clonar repositorio" \
                "git status|Estado de archivos" \
                "git add .|Añadir cambios" \
                "git commit -m 'msg'|Crear commit"
            ;;
        docker|network)
            print_tiles_row "DOCKER - Containers" "$BLUE" "$BG_BLUE" \
                "docker ps|Contenedores activos" \
                "docker images|Listar imágenes" \
                "docker run -d <img>|Ejecutar container" \
                "TILE2:NETWORK - Networking" "$MAGENTA" "$BG_MAGENTA" \
                "ip addr show|Ver interfaces" \
                "ping <host>|Probar conectividad" \
                "curl <url>|Petición HTTP"
            ;;
        *)
            echo "❌ Categoría no encontrada: $category"
            echo "Categorías disponibles: dnf, git, docker, network, filesystem, system, permissions"
            ;;
    esac
}

# Función stub para selección de categoría interactiva
select_category() {
    echo -e "\n${YELLOW}Selecciona una categoría:${RESET}"
    echo "1) DNF + GIT"
    echo "2) Docker + Network"  
    echo "3) Todas"
    read -p "> " choice
    case "$choice" in
        1) show_category "dnf" ;;
        2) show_category "docker" ;;
        3) show_all_categories ;;
    esac
    echo -e "\n${DIM}Presiona Enter para continuar...${RESET}"
    read -r
}

# Ejecutar script
main "$@"

# Mostrar footer si no es modo interactivo
if [ "$INTERACTIVE_MODE" = "false" ]; then
    print_footer
fi