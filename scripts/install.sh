#!/bin/bash
# ============================================================
# BBS Comunicaciones — Instalador de MCPs para Claude/Cowork
# ============================================================
# Uso: curl -sSL https://raw.githubusercontent.com/bbscomunicaciones/bbs-mcp-installer/main/scripts/install.sh | bash
# ============================================================

set -e

# ── Colores para output ──────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Banner ───────────────────────────────────────────────────
echo ""
echo -e "${BLUE}${BOLD}"
echo "  ██████╗ ██████╗ ███████╗"
echo "  ██╔══██╗██╔══██╗██╔════╝"
echo "  ██████╔╝██████╔╝███████╗"
echo "  ██╔══██╗██╔══██╗╚════██║"
echo "  ██████╔╝██████╔╝███████║"
echo "  ╚═════╝ ╚═════╝ ╚══════╝"
echo ""
echo -e "${NC}${BOLD}  BBS Comunicaciones — Instalador de MCPs${NC}"
echo -e "  ${CYAN}Para Claude Desktop / Cowork / Claude Code${NC}"
echo ""

# ── Variables ────────────────────────────────────────────────
REPO_URL="https://github.com/bbscomunicaciones/bbs-mcp-installer"
RAW_URL="https://raw.githubusercontent.com/bbscomunicaciones/bbs-mcp-installer/main"
INSTALL_DIR="$HOME/.bbs-mcp-installer"
PLUGIN_DIR="$HOME/.claude/plugins/bbs-mcp-installer"

# Detectar OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

# Detectar ruta de config de Claude Desktop
case $OS in
    mac)     CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude" ;;
    linux)   CLAUDE_CONFIG_DIR="$HOME/.config/Claude" ;;
    windows) CLAUDE_CONFIG_DIR="$APPDATA/Claude" ;;
    *)       CLAUDE_CONFIG_DIR="$HOME/.claude" ;;
esac

CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"

# ── Funciones ────────────────────────────────────────────────
log_step() { echo -e "\n${BLUE}${BOLD}→ $1${NC}"; }
log_ok()   { echo -e "  ${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "  ${YELLOW}⚠️  $1${NC}"; }
log_err()  { echo -e "  ${RED}❌ $1${NC}"; }
log_info() { echo -e "  ${CYAN}ℹ️  $1${NC}"; }

check_command() {
    if command -v "$1" &> /dev/null; then
        log_ok "$1 $(${1} --version 2>&1 | head -1)"
        return 0
    else
        log_warn "$1 no encontrado"
        return 1
    fi
}

# ── PASO 1: Verificar requisitos ─────────────────────────────
log_step "Verificando requisitos del sistema"
echo -e "  OS detectado: ${CYAN}$OS${NC}"

MISSING_DEPS=0

# Node.js
if ! check_command node; then
    MISSING_DEPS=1
    echo ""
    echo -e "  ${YELLOW}Node.js es requerido. Instalando...${NC}"
    case $OS in
        mac)
            if command -v brew &> /dev/null; then
                brew install node
            else
                log_err "Homebrew no encontrado. Instala Node.js manualmente desde https://nodejs.org"
                exit 1
            fi
            ;;
        linux)
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null
            sudo apt-get install -y nodejs 2>/dev/null || {
                log_err "No se pudo instalar Node.js automáticamente"
                log_info "Visita: https://nodejs.org para instalarlo manualmente"
                exit 1
            }
            ;;
        *)
            log_err "Instala Node.js manualmente desde https://nodejs.org"
            exit 1
            ;;
    esac
fi

# npm
check_command npm || { log_err "npm no encontrado (debería venir con Node.js)"; exit 1; }

# git
check_command git || log_warn "git no encontrado — algunas funciones pueden no estar disponibles"

# Claude Code CLI (opcional)
check_command claude || log_warn "Claude Code CLI no instalado — se instalará si lo necesitas"

# jq (para manipular JSON)
if ! check_command jq; then
    log_info "Instalando jq para manipulación de JSON..."
    case $OS in
        mac)   brew install jq 2>/dev/null ;;
        linux) sudo apt-get install -y jq 2>/dev/null || sudo yum install -y jq 2>/dev/null ;;
    esac
fi

# ── PASO 2: Clonar/actualizar repositorio ───────────────────
log_step "Descargando BBS MCP Installer"

if [ -d "$INSTALL_DIR/.git" ]; then
    log_info "Directorio existente encontrado — actualizando..."
    cd "$INSTALL_DIR" && git pull origin main
    log_ok "Actualizado a la última versión"
else
    log_info "Clonando repositorio..."
    git clone "$REPO_URL.git" "$INSTALL_DIR" 2>/dev/null || {
        log_warn "git clone falló — descargando como ZIP..."
        mkdir -p "$INSTALL_DIR"
        curl -sSL "$REPO_URL/archive/main.zip" -o /tmp/bbs-mcp.zip
        unzip -q /tmp/bbs-mcp.zip -d /tmp/
        cp -r /tmp/bbs-mcp-installer-main/* "$INSTALL_DIR/"
        rm /tmp/bbs-mcp.zip
    }
    log_ok "Descargado en: $INSTALL_DIR"
fi

# ── PASO 3: Instalar como plugin de Claude ───────────────────
log_step "Instalando plugin en Claude/Cowork"

mkdir -p "$PLUGIN_DIR"
cp -r "$INSTALL_DIR/skills" "$PLUGIN_DIR/"
cp "$INSTALL_DIR/README.md" "$PLUGIN_DIR/" 2>/dev/null || true

# Crear plugin.json para Cowork
cat > "$PLUGIN_DIR/plugin.json" << EOF
{
  "name": "bbs-mcp-installer",
  "displayName": "BBS MCP Installer",
  "version": "1.0.0",
  "description": "Instalador y gestor de MCPs de BBS Comunicaciones. Configura clientes, servicios y credenciales de forma interactiva.",
  "author": "BBS Comunicaciones",
  "skills": [
    {
      "name": "setup-client",
      "path": "skills/setup-client/SKILL.md",
      "command": "setup-client"
    },
    {
      "name": "install-mcp",
      "path": "skills/install-mcp/SKILL.md",
      "command": "install-mcp"
    },
    {
      "name": "list-clients",
      "path": "skills/list-clients/SKILL.md",
      "command": "list-clients"
    },
    {
      "name": "update-client",
      "path": "skills/update-client/SKILL.md",
      "command": "update-client"
    }
  ]
}
EOF

log_ok "Plugin instalado en: $PLUGIN_DIR"

# ── PASO 4: Instalar Claude Code CLI si no existe ────────────
if ! command -v claude &> /dev/null; then
    echo ""
    read -p "  ¿Deseas instalar Claude Code CLI? (recomendado) [s/N]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        log_info "Instalando Claude Code CLI..."
        npm install -g @anthropic-ai/claude-code
        log_ok "Claude Code CLI instalado"
    fi
fi

# ── PASO 5: Agregar skills a Claude Code ─────────────────────
if command -v claude &> /dev/null; then
    log_step "Registrando skills en Claude Code"

    # Instalar plugin via Claude Code si está disponible
    claude plugins add "$PLUGIN_DIR" 2>/dev/null && log_ok "Plugin registrado en Claude Code" || log_warn "No se pudo registrar automáticamente — registro manual disponible"
fi

# ── PASO 6: Crear directorio de clientes ─────────────────────
log_step "Configurando directorio de trabajo"

# Usar el directorio de trabajo del usuario
CLIENTS_DIR="$HOME/bbs-clients"
mkdir -p "$CLIENTS_DIR"
echo "$CLIENTS_DIR" > "$INSTALL_DIR/.clients_dir"

# Crear .gitignore para proteger credenciales
cat > "$CLIENTS_DIR/.gitignore" << 'EOF'
# BBS Comunicaciones — Proteger credenciales
*/.env
*/.env.local
*/.env.production
*/credentials.json
*/service-account.json

# Backups
*.backup.json
*.bak

# OS files
.DS_Store
Thumbs.db
EOF

log_ok "Directorio de clientes: $CLIENTS_DIR"
log_ok ".gitignore de seguridad creado"

# ── PASO 7: Agregar al PATH ──────────────────────────────────
log_step "Configurando PATH"

BBS_BIN="$INSTALL_DIR/scripts/bbs-mcp"
chmod +x "$BBS_BIN" 2>/dev/null || true

# Agregar al shell profile
SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "bbs-mcp-installer" "$SHELL_PROFILE" 2>/dev/null; then
        echo "" >> "$SHELL_PROFILE"
        echo "# BBS MCP Installer" >> "$SHELL_PROFILE"
        echo "export PATH=\"\$PATH:$INSTALL_DIR/scripts\"" >> "$SHELL_PROFILE"
        echo "export BBS_CLIENTS_DIR=\"$CLIENTS_DIR\"" >> "$SHELL_PROFILE"
        log_ok "PATH actualizado en: $SHELL_PROFILE"
    fi
fi

# ── Resumen final ────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✅ BBS MCP Installer instalado exitosamente${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Plugin instalado en:${NC}    $PLUGIN_DIR"
echo -e "  ${BOLD}Directorio clientes:${NC}    $CLIENTS_DIR"
echo -e "  ${BOLD}Config Claude Desktop:${NC}  $CLAUDE_CONFIG_FILE"
echo ""
echo -e "  ${CYAN}${BOLD}¿Qué hacer ahora?${NC}"
echo ""
echo -e "  ${BOLD}1.${NC} Abre Claude Desktop o Cowork"
echo -e "  ${BOLD}2.${NC} Escribe:  ${CYAN}/setup-client${NC}  para configurar tu primer cliente"
echo -e "  ${BOLD}3.${NC} Escribe:  ${CYAN}/list-clients${NC}  para ver clientes existentes"
echo -e "  ${BOLD}4.${NC} Escribe:  ${CYAN}/install-mcp${NC}  para instalar MCPs de un cliente"
echo ""
echo -e "  ${YELLOW}📖 Documentación: $INSTALL_DIR/README.md${NC}"
echo -e "  ${YELLOW}🐙 GitHub: $REPO_URL${NC}"
echo ""
