#!/usr/bin/env bash

# install.sh - Script de instalación y configuración del sistema de cheatsheets

set -euo pipefail

# Colores para el instalador
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'

# Variables de instalación
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/cheatsheets"
BACKUP_DIR="$HOME/.config/cheatsheets/backup"

# Función para mostrar banner
show_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🚀 CHEATSHEETS INSTALLER                  ║"
    echo "║                        Versión 2.0                          ║"  
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}\n"
}

# Función para mostrar progreso
show_progress() {
    local step=$1
    local total=$2
    local message="$3"
    
    local percent=$((step * 100 / total))
    local filled=$((percent / 5))
    local empty=$((20 - filled))
    
    printf "${BLUE}[${GREEN}"
    printf '█%.0s' $(seq 1 $filled)
    printf "${DIM}"
    printf '░%.0s' $(seq 1 $empty)
    printf "${BLUE}] ${WHITE}${percent}%% ${message}${RESET}\n"
}

# Función para crear directorios
create_directories() {
    show_progress 1 6 "Creando directorios..."
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$CONFIG_DIR/data"
    mkdir -p "$CONFIG_DIR/lib"
    
    echo -e "  ${GREEN}✓${RESET} Directorios creados en ${DIM}$CONFIG_DIR${RESET}"
}

# Función para copiar archivos
copy_files() {
    show_progress 2 6 "Copiando archivos del sistema..."
    
    # Copiar archivos de datos
    if [ -d "$SCRIPT_DIR/cheatsheets/data" ]; then
        cp -r "$SCRIPT_DIR/cheatsheets/data/"* "$CONFIG_DIR/data/"
        echo -e "  ${GREEN}✓${RESET} Archivos de datos copiados"
    fi
    
    # Copiar librerías
    if [ -d "$SCRIPT_DIR/cheatsheets/lib" ]; then
        cp -r "$SCRIPT_DIR/cheatsheets/lib/"* "$CONFIG_DIR/lib/"
        echo -e "  ${GREEN}✓${RESET} Librerías copiadas"
    fi
    
    # Copiar script principal
    if [ -f "$SCRIPT_DIR/cheat" ]; then
        cp "$SCRIPT_DIR/cheat" "$INSTALL_DIR/cheatsheet"
        chmod +x "$INSTALL_DIR/cheatsheet"
        echo -e "  ${GREEN}✓${RESET} Script principal instalado como ${WHITE}cheatsheet${RESET}"
    elif [ -f "$SCRIPT_DIR/cheatsheets_new.sh" ]; then
        cp "$SCRIPT_DIR/cheatsheets_new.sh" "$INSTALL_DIR/cheatsheet"
        chmod +x "$INSTALL_DIR/cheatsheet"
        echo -e "  ${GREEN}✓${RESET} Script principal instalado como ${WHITE}cheatsheet${RESET}"
    else
        echo -e "  ${RED}✗${RESET} No se encontró el script principal (cheat o cheatsheets_new.sh)"
    fi
}

# Función para crear configuración personalizada
create_config() {
    show_progress 3 6 "Creando configuración..."
    
    cat > "$CONFIG_DIR/user_config.sh" << 'EOF'
#!/usr/bin/env bash
# user_config.sh - Configuración personalizada del usuario

# Configuración de colores (true/false)
USER_COLOR_ENABLED=true

# Configuración de comportamiento
USER_INTERACTIVE_MODE=false
USER_AUTO_UPDATE=true

# Categorías favoritas (separadas por espacios)
USER_FAVORITE_CATEGORIES="git docker"

# Comandos personalizados (agregar aquí comandos adicionales)
USER_CUSTOM_COMMANDS=(
    "htop|Monitor de procesos interactivo"
    "ncdu|Analizador de espacio en disco"
    "bat <file>|Ver archivo con sintaxis coloreada"
)

# Terminal por defecto para comandos
USER_DEFAULT_TERMINAL="gnome-terminal"

EOF

    echo -e "  ${GREEN}✓${RESET} Configuración de usuario creada"
}

# Función para configurar PATH
setup_path() {
    show_progress 4 6 "Configurando PATH..."
    
    # Verificar si ya está en PATH
    if echo "$PATH" | grep -q "$INSTALL_DIR"; then
        echo -e "  ${YELLOW}⚠${RESET} $INSTALL_DIR ya está en PATH"
        return
    fi
    
    # Añadir a diferentes shells
    local shells=(".bashrc" ".zshrc" ".profile")
    for shell_file in "${shells[@]}"; do
        local shell_path="$HOME/$shell_file"
        if [ -f "$shell_path" ]; then
            if ! grep -q "# Cheatsheets PATH" "$shell_path"; then
                echo "" >> "$shell_path"
                echo "# Cheatsheets PATH" >> "$shell_path"
                echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$shell_path"
                echo -e "  ${GREEN}✓${RESET} PATH añadido a $shell_file"
            fi
        fi
    done
}

# Función para crear enlaces simbólicos
create_symlinks() {
    show_progress 5 6 "Creando enlaces de acceso..."
    
    # Enlace en el directorio actual del script
    if [ ! -L "$SCRIPT_DIR/cheatsheet" ]; then
        ln -sf "$INSTALL_DIR/cheatsheet" "$SCRIPT_DIR/cheatsheet"
        echo -e "  ${GREEN}✓${RESET} Enlace creado en directorio actual"
    fi
    
    # Actualizar configuración para usar archivos del home
    local config_file="$CONFIG_DIR/lib/config.sh"
    if [ -f "$config_file" ]; then
        sed -i "s|BASE_DIR=.*|BASE_DIR=\"$CONFIG_DIR\"|" "$config_file"
        echo -e "  ${GREEN}✓${RESET} Configuración actualizada para usar $CONFIG_DIR"
    fi
}

# Función para verificar instalación
verify_installation() {
    show_progress 6 6 "Verificando instalación..."
    
    local errors=0
    
    # Verificar archivos principales
    local required_files=(
        "$INSTALL_DIR/cheatsheet"
        "$CONFIG_DIR/lib/config.sh"
        "$CONFIG_DIR/lib/display.sh"
        "$CONFIG_DIR/lib/utils.sh"
        "$CONFIG_DIR/data/git_commands.yaml"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo -e "  ${RED}✗${RESET} Archivo faltante: $file"
            ((errors++))
        fi
    done
    
    # Verificar que el comando funcione
    if command -v cheatsheet >/dev/null 2>&1 || [ -x "$INSTALL_DIR/cheatsheet" ]; then
        echo -e "  ${GREEN}✓${RESET} Comando 'cheatsheet' disponible"
    else
        echo -e "  ${YELLOW}⚠${RESET} Comando 'cheatsheet' no está en PATH (reinicia la terminal)"
    fi
    
    if [ $errors -eq 0 ]; then
        echo -e "  ${GREEN}✓${RESET} Instalación verificada correctamente"
    else
        echo -e "  ${RED}✗${RESET} Instalación incompleta ($errors errores)"
        return 1
    fi
}

# Función para mostrar información post-instalación
show_post_install() {
    echo -e "\n${CYAN}${BOLD}🎉 ¡INSTALACIÓN COMPLETADA!${RESET}\n"
    
    echo -e "${YELLOW}Cómo usar:${RESET}"
    echo -e "  ${WHITE}cheatsheet${RESET}           # Ver todos los comandos"
    echo -e "  ${WHITE}cheatsheet -i${RESET}        # Modo interactivo"
    echo -e "  ${WHITE}cheatsheet -c git${RESET}    # Solo comandos Git"
    echo -e "  ${WHITE}cheatsheet -h${RESET}        # Ayuda completa"
    
    echo -e "\n${YELLOW}Archivos instalados:${RESET}"
    echo -e "  Script: ${DIM}$INSTALL_DIR/cheatsheet${RESET}"
    echo -e "  Datos:  ${DIM}$CONFIG_DIR/data/${RESET}"
    echo -e "  Config: ${DIM}$CONFIG_DIR/user_config.sh${RESET}"
    
    echo -e "\n${YELLOW}Para personalizar:${RESET}"
    echo -e "  ${WHITE}nano $CONFIG_DIR/user_config.sh${RESET}"
    echo -e "  ${WHITE}ls $CONFIG_DIR/data/${RESET}        # Ver archivos de comandos"
    
    if ! command -v cheatsheet >/dev/null 2>&1; then
        echo -e "\n${YELLOW}⚠ IMPORTANTE:${RESET} Reinicia tu terminal o ejecuta:"
        echo -e "  ${WHITE}source ~/.bashrc${RESET}   # o ~/.zshrc según tu shell"
        echo -e "  ${WHITE}export PATH=\"$INSTALL_DIR:\$PATH\"${RESET}"
    fi
    
    echo -e "\n${GREEN}${BOLD}¡Disfruta de tus cheatsheets!${RESET} 🚀"
}

# Función principal de instalación
main() {
    show_banner
    
    echo -e "${WHITE}Este script instalará el sistema de cheatsheets modular.${RESET}"
    echo -e "${DIM}Ubicaciones:${RESET}"
    echo -e "  Script: ${DIM}$INSTALL_DIR/cheatsheet${RESET}"
    echo -e "  Config: ${DIM}$CONFIG_DIR/${RESET}"
    echo -e ""
    
    read -p "¿Continuar con la instalación? [Y/n] " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Instalación cancelada.${RESET}"
        exit 0
    fi
    
    echo ""
    
    # Ejecutar pasos de instalación
    create_directories
    copy_files
    create_config
    setup_path
    create_symlinks
    
    if verify_installation; then
        show_post_install
    else
        echo -e "\n${RED}❌ La instalación falló. Revisa los errores anteriores.${RESET}"
        exit 1
    fi
}

# Ejecutar instalación
main "$@"