# ============================================================
# BBS Comunicaciones — Instalador de MCPs para Windows
# ============================================================
# Uso: iwr -useb https://raw.githubusercontent.com/bbscomunicaciones/bbs-mcp-installer/main/scripts/install.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

# ── Banner ───────────────────────────────────────────────────
Write-Host ""
Write-Host "  ██████╗ ██████╗ ███████╗" -ForegroundColor Blue
Write-Host "  ██╔══██╗██╔══██╗██╔════╝" -ForegroundColor Blue
Write-Host "  ██████╔╝██████╔╝███████╗" -ForegroundColor Blue
Write-Host "  ██╔══██╗██╔══██╗╚════██║" -ForegroundColor Blue
Write-Host "  ██████╔╝██████╔╝███████║" -ForegroundColor Blue
Write-Host "  ╚═════╝ ╚═════╝ ╚══════╝" -ForegroundColor Blue
Write-Host ""
Write-Host "  BBS Comunicaciones — Instalador de MCPs" -ForegroundColor White
Write-Host "  Para Claude Desktop / Cowork / Claude Code" -ForegroundColor Cyan
Write-Host ""

# ── Variables ────────────────────────────────────────────────
$REPO_URL     = "https://github.com/bbscomunicaciones/bbs-mcp-installer"
$INSTALL_DIR  = "$env:USERPROFILE\.bbs-mcp-installer"
$PLUGIN_DIR   = "$env:USERPROFILE\.claude\plugins\bbs-mcp-installer"
$CLIENTS_DIR  = "$env:USERPROFILE\bbs-clients"
$CLAUDE_DIR   = "$env:APPDATA\Claude"
$CLAUDE_CONFIG = "$CLAUDE_DIR\claude_desktop_config.json"

function Log-Step  { param($msg) Write-Host "`n→ $msg" -ForegroundColor Blue }
function Log-Ok    { param($msg) Write-Host "  ✅ $msg" -ForegroundColor Green }
function Log-Warn  { param($msg) Write-Host "  ⚠️  $msg" -ForegroundColor Yellow }
function Log-Error { param($msg) Write-Host "  ❌ $msg" -ForegroundColor Red }
function Log-Info  { param($msg) Write-Host "  ℹ️  $msg" -ForegroundColor Cyan }

# ── PASO 1: Verificar Node.js ────────────────────────────────
Log-Step "Verificando requisitos"

try {
    $nodeVersion = node --version 2>&1
    Log-Ok "Node.js: $nodeVersion"
} catch {
    Log-Warn "Node.js no encontrado. Instalando..."
    try {
        winget install OpenJS.NodeJS --silent
        Log-Ok "Node.js instalado"
    } catch {
        Log-Error "Instala Node.js manualmente desde https://nodejs.org"
        exit 1
    }
}

try {
    $npmVersion = npm --version 2>&1
    Log-Ok "npm: $npmVersion"
} catch {
    Log-Error "npm no encontrado"
    exit 1
}

# ── PASO 2: Clonar repositorio ───────────────────────────────
Log-Step "Descargando BBS MCP Installer"

if (Test-Path "$INSTALL_DIR\.git") {
    Log-Info "Actualizando versión existente..."
    Set-Location $INSTALL_DIR
    git pull origin main
} else {
    Log-Info "Clonando repositorio..."
    try {
        git clone "$REPO_URL.git" $INSTALL_DIR
    } catch {
        Log-Warn "git no disponible — descargando ZIP..."
        $zipUrl = "$REPO_URL/archive/main.zip"
        $zipPath = "$env:TEMP\bbs-mcp.zip"
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\bbs-mcp-extract" -Force
        Copy-Item -Recurse -Force "$env:TEMP\bbs-mcp-extract\bbs-mcp-installer-main\*" $INSTALL_DIR
        Remove-Item $zipPath -Force
    }
}
Log-Ok "Instalado en: $INSTALL_DIR"

# ── PASO 3: Instalar plugin ──────────────────────────────────
Log-Step "Instalando plugin"

New-Item -ItemType Directory -Path $PLUGIN_DIR -Force | Out-Null
Copy-Item -Recurse -Force "$INSTALL_DIR\skills" $PLUGIN_DIR
Copy-Item -Force "$INSTALL_DIR\README.md" $PLUGIN_DIR -ErrorAction SilentlyContinue

# Crear plugin.json
@"
{
  "name": "bbs-mcp-installer",
  "displayName": "BBS MCP Installer",
  "version": "1.0.0",
  "description": "Instalador y gestor de MCPs de BBS Comunicaciones.",
  "author": "BBS Comunicaciones",
  "skills": [
    { "name": "setup-client",  "path": "skills/setup-client/SKILL.md",  "command": "setup-client" },
    { "name": "install-mcp",   "path": "skills/install-mcp/SKILL.md",   "command": "install-mcp" },
    { "name": "list-clients",  "path": "skills/list-clients/SKILL.md",  "command": "list-clients" },
    { "name": "update-client", "path": "skills/update-client/SKILL.md", "command": "update-client" }
  ]
}
"@ | Out-File -FilePath "$PLUGIN_DIR\plugin.json" -Encoding UTF8

Log-Ok "Plugin en: $PLUGIN_DIR"

# ── PASO 4: Crear directorio de clientes ─────────────────────
Log-Step "Configurando directorio de clientes"

New-Item -ItemType Directory -Path $CLIENTS_DIR -Force | Out-Null

@"
# BBS Comunicaciones — Proteger credenciales
*/.env
*/.env.local
*/credentials.json
*.backup.json
"@ | Out-File -FilePath "$CLIENTS_DIR\.gitignore" -Encoding UTF8

Log-Ok "Directorio de clientes: $CLIENTS_DIR"

# ── PASO 5: Variables de entorno ─────────────────────────────
Log-Step "Configurando variables de entorno"
[System.Environment]::SetEnvironmentVariable("BBS_CLIENTS_DIR", $CLIENTS_DIR, "User")
Log-Ok "BBS_CLIENTS_DIR = $CLIENTS_DIR"

# ── Resumen ──────────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ BBS MCP Installer instalado exitosamente" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "  Plugin:           $PLUGIN_DIR" -ForegroundColor White
Write-Host "  Clientes:         $CLIENTS_DIR" -ForegroundColor White
Write-Host "  Config Claude:    $CLAUDE_CONFIG" -ForegroundColor White
Write-Host ""
Write-Host "  ¿Qué hacer ahora?" -ForegroundColor Cyan
Write-Host "  1. Abre Claude Desktop o Cowork"
Write-Host "  2. Escribe: /setup-client  para configurar tu primer cliente"
Write-Host "  3. Escribe: /list-clients  para ver clientes existentes"
Write-Host "  4. Escribe: /install-mcp   para instalar MCPs de un cliente"
Write-Host ""
Write-Host "  Documentación: $INSTALL_DIR\README.md" -ForegroundColor Yellow
Write-Host ""
