---
name: install-mcp
description: Instala y configura los servidores MCP de BBS Comunicaciones en una cuenta nueva de Claude/Cowork. Detecta el sistema operativo, instala dependencias, copia la configuración generada por setup-client y verifica que todo funcione correctamente.
argument-hint: "[nombre del cliente o 'nuevo']"
---

# /install-mcp

Instalador automático de servidores MCP de BBS Comunicaciones.

## Propósito

Toma la configuración generada por `/setup-client` y la instala correctamente en Claude Desktop o Cowork, detectando el entorno del usuario automáticamente.

---

## FLUJO DE EJECUCIÓN

### PASO 1 — Detectar entorno

Identifica el sistema operativo y entorno:

```bash
# Detectar OS
uname -s  # Linux/Mac
echo $OS  # Windows

# Detectar si Claude Desktop está instalado
# Mac:    ~/Library/Application Support/Claude/
# Windows: %APPDATA%\Claude\
# Linux:  ~/.config/Claude/

# Detectar Node.js
node --version
npm --version

# Detectar si Claude Code (CLI) está instalado
claude --version
```

Informa al usuario qué encontró:
```
🔍 Entorno detectado:
  • OS: macOS 14.2 / Windows 11 / Ubuntu 22.04
  • Node.js: v20.x ✅ / ❌ No instalado
  • Claude Desktop: ✅ Instalado / ❌ No encontrado
  • Claude Code CLI: ✅ v1.x / ❌ No instalado
```

---

### PASO 2 — Instalar requisitos previos

Si Node.js no está instalado:

```bash
# Mac (con Homebrew)
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Windows (con winget)
winget install OpenJS.NodeJS
```

Si Claude Code CLI no está instalado:
```bash
npm install -g @anthropic-ai/claude-code
```

---

### PASO 3 — Identificar cliente

Pregunta:
> ¿Para cuál cliente deseas instalar los MCPs?

Si se proporcionó como argumento (`/install-mcp farmacia-lopez`), úsalo directamente.

Si no, lista los clientes disponibles en `clients/`:
```
Clientes configurados:
  1. farmacia-lopez      (Farmacia López)     — 5 MCPs
  2. techmex             (TechMex SA)          — 8 MCPs
  3. hotel-paraiso       (Hotel Paraíso)       — 3 MCPs

¿Cuál instalar? (número o nombre)
```

---

### PASO 4 — Cargar configuración del cliente

Lee `clients/{client_slug}/claude_desktop_config.json` y verifica que exista.

Si no existe, sugiere ejecutar primero `/setup-client NOMBRE`.

---

### PASO 5 — Instalar paquetes NPM necesarios

Según los MCPs del cliente, instala los paquetes necesarios:

```bash
# Mapeo de servicios a paquetes npm
WHM/cPanel:     npm install -g @bbs/whm-mcp
WHMCS:          npm install -g @bbs/whmcs-mcp
SSH:            npm install -g @bbs/ssh-mcp
Perfex:         npm install -g @bbs/perfex-mcp
Cloudflare:     npm install -g @bbs/cloudflare-mcp
Meta:           npm install -g @bbs/meta-mcp
TikTok:         npm install -g @bbs/tiktok-mcp
Google Cloud:   npm install -g @bbs/google-cloud-mcp
Gmail:          npm install -g @modelcontextprotocol/server-gmail
Google Drive:   npm install -g @bbs/gdrive-mcp
Google Cal:     npm install -g @bbs/gcal-mcp
Canva:          npm install -g @bbs/canva-mcp
ElevenLabs:     npm install -g @bbs/elevenlabs-mcp
Flux:           npm install -g @bbs/flux-mcp
Freepik:        npm install -g @bbs/freepik-mcp
Hostinger:      npm install -g @bbs/hostinger-mcp
Cloudflare Dev: npm install -g @cloudflare/mcp-server-cloudflare
QC:             npm install -g @bbs/qc-mcp
```

Muestra progreso:
```
📦 Instalando paquetes MCP...
  ✅ @bbs/whm-mcp@2.1.0
  ✅ @bbs/whmcs-mcp@1.8.3
  ⏳ @bbs/meta-mcp... instalando
  ✅ @bbs/meta-mcp@3.0.1
```

---

### PASO 6 — Actualizar claude_desktop_config.json

Localiza el archivo de configuración de Claude según el OS:

```
Mac:     ~/Library/Application Support/Claude/claude_desktop_config.json
Windows: C:\Users\{USER}\AppData\Roaming\Claude\claude_desktop_config.json
Linux:   ~/.config/Claude/claude_desktop_config.json
```

**Si el archivo no existe**, créalo:
```json
{
  "mcpServers": {}
}
```

**Si el archivo existe**, fusiona los nuevos servidores MCP sin eliminar los existentes:

```bash
# Ejemplo de fusión segura con jq
jq -s '.[0].mcpServers * .[1].mcpServers | {mcpServers: .}' \
  existing_config.json \
  clients/client_slug/claude_desktop_config.json \
  > merged_config.json
```

> ⚠️ **Siempre hace backup** antes de modificar:
> `cp claude_desktop_config.json claude_desktop_config.backup.json`

---

### PASO 7 — Instalar como plugin de Cowork (opcional)

Si el usuario tiene Cowork instalado, ofrece instalar también como plugin:

```bash
# Copiar skills del cliente al directorio de plugins
cp -r skills/ ~/.claude/plugins/bbs-{client_slug}/

# O via Claude Code CLI
claude plugins add ./bbs-mcp-installer
```

---

### PASO 8 — Verificación

Verifica que la instalación fue exitosa:

```bash
# Verificar que los binarios existen
which bbs-whm-mcp
which bbs-whmcs-mcp

# Test básico de conectividad (si el MCP tiene ping)
bbs-whm-mcp ping
bbs-whmcs-mcp ping
```

Muestra resultado:
```
✅ Instalación completada para: CLIENTE_NAME

Servidores MCP instalados y verificados:
  ✅ whm-client_slug       → Conectado (servidor: url)
  ✅ whmcs-client_slug     → Conectado
  ⚠️  meta-client_slug     → Instalado (verificar token manualmente)
  ✅ cloudflare-client_slug → Conectado

📋 Próximos pasos:
  1. Reinicia Claude Desktop o Cowork
  2. Abre Claude y escribe: "¿qué herramientas MCP tienes disponibles?"
  3. Deberías ver las nuevas herramientas listadas

📁 Backup guardado en: claude_desktop_config.backup.json
```

---

### PASO 9 — Agregar a Claude Code (CLI) también (opcional)

Si el usuario usa Claude Code CLI además de Cowork:

```bash
# Agregar servidores MCP al Claude Code config
claude mcp add whm-CLIENT_SLUG npx @bbs/whm-mcp \
  -e WHM_URL=https://servidor.com:2087 \
  -e WHM_USER=root \
  -e WHM_TOKEN=TOKEN

claude mcp add whmcs-CLIENT_SLUG npx @bbs/whmcs-mcp \
  -e WHMCS_URL=https://billing.com \
  -e WHMCS_API_ID=ID \
  -e WHMCS_API_SECRET=SECRET
```

---

## COMANDOS DE UTILIDAD

```bash
# Ver todos los MCPs instalados
claude mcp list

# Ver MCPs de un cliente específico
claude mcp list | grep client_slug

# Probar un MCP específico
claude mcp test whm-client_slug

# Remover un MCP
claude mcp remove whm-client_slug
```

---

## SOLUCIÓN DE PROBLEMAS COMUNES

| Error | Solución |
|-------|----------|
| `command not found: node` | Instalar Node.js v18 o superior |
| `EACCES: permission denied` | Usar `sudo npm install -g` o configurar npm sin sudo |
| `Connection refused` | Verificar URL y que el servidor esté accesible |
| `401 Unauthorized` | Verificar API token/credenciales en el .env |
| `Module not found` | Ejecutar `npm install` nuevamente |
| Claude no ve los MCPs | Reiniciar Claude Desktop después de modificar el config |
