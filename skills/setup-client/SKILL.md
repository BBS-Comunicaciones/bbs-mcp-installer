---
name: setup-client
description: Wizard interactivo para configurar todos los MCPs de BBS Comunicaciones para un cliente nuevo. Pregunta por nombre del cliente, servicios requeridos, credenciales API, privilegios y genera automáticamente el archivo de configuración completo listo para instalar. Úsalo cuando agregues un cliente nuevo o necesites regenerar su configuración MCP.
argument-hint: "[nombre del cliente]"
---

# /setup-client

Asistente de configuración de MCPs de BBS Comunicaciones para un cliente nuevo.

## Propósito

Este wizard guía paso a paso la configuración completa de todos los servidores MCP necesarios para un cliente, generando automáticamente los archivos de configuración listos para Claude Code / Cowork.

---

## FLUJO DE EJECUCIÓN

### PASO 1 — Identificar el cliente

Pregunta al usuario:

> **¿Cómo se llama el cliente o empresa que vamos a configurar?**
> (Ejemplo: "Farmacia López", "TechMex SA", "Hotel Paraíso")

Guarda el nombre como `CLIENT_NAME` y crea un slug limpio: `client_slug` (minúsculas, sin espacios, sin caracteres especiales). Ejemplo: "Farmacia López" → `farmacia-lopez`.

---

### PASO 2 — Selección de servicios

Pregunta al usuario cuáles de los siguientes servicios necesita el cliente (puede ser uno o varios):

```
INFRAESTRUCTURA & HOSTING
  [ ] WHM / cPanel      → Gestión de servidor, cuentas, DNS, SSL
  [ ] WHMCS             → Facturación, dominios, órdenes de servicios
  [ ] Servidor SSH      → Acceso directo al servidor vía SSH

GESTIÓN DE CLIENTES & PROYECTOS
  [ ] Perfex CRM        → CRM, proyectos, facturas, tickets de soporte

DNS & SEGURIDAD
  [ ] Cloudflare BBS    → DNS, CDN, firewall, workers, zonas
  [ ] QC (Quick Cache)  → Optimización de caché WordPress

MARKETING & REDES SOCIALES
  [ ] Meta (Facebook/Instagram) → Páginas, posts, anuncios, comentarios
  [ ] TikTok            → Videos, comentarios, anuncios, estadísticas
  [ ] Google Cloud / Maps → Traducción, Vision AI, YouTube, Maps

PRODUCTIVIDAD
  [ ] Gmail             → Correo electrónico
  [ ] Google Drive      → Documentos y archivos
  [ ] Google Calendar   → Calendario y reuniones

MEDIOS & CREATIVIDAD
  [ ] Canva             → Diseño gráfico
  [ ] ElevenLabs        → Text-to-Speech (voz IA)
  [ ] Flux / Stable Diffusion → Generación de imágenes IA
  [ ] Freepik           → Banco de imágenes e íconos

DOMINIO & REGISTRO
  [ ] Hostinger         → Dominios, hosting, VPS, DNS

ALMACENAMIENTO CLOUD
  [ ] Cloudflare R2/D1/KV → Workers, bases de datos, almacenamiento
```

---

### PASO 3 — Recolección de credenciales por servicio

Para cada servicio seleccionado, solicita las credenciales específicas en el siguiente formato:

---

#### 🖥️ WHM / cPanel

```
Servidor WHM del cliente:
  • URL del servidor WHM: [ej: https://servidor.bbscomunicaciones.com:2087]
  • Usuario WHM (root o reseller): [ej: root]
  • API Token WHM: [ej: ABCD1234...]
  • ¿Tiene acceso SSH también? (sí/no)
```

Privilegios disponibles:
- `admin` → Acceso completo (crear/borrar cuentas, configurar DNS, ver todo)
- `reseller` → Gestión de cuentas bajo su reseller únicamente
- `soporte` → Solo lectura + reiniciar servicios, sin crear/borrar cuentas

---

#### 💳 WHMCS

```
Configuración WHMCS del cliente:
  • URL de WHMCS: [ej: https://billing.cliente.com]
  • API Identifier: [ej: xxxxxxxxxxxxxxxx]
  • API Secret: [ej: xxxxxxxxxxxxxxxx]
  • ¿Puede crear/cancelar órdenes? (sí/no)
  • ¿Puede ver información financiera? (sí/no)
```

Privilegios:
- `admin` → Acceso total (crear clientes, procesar pagos, cancelar servicios)
- `soporte` → Ver tickets, responder, ver clientes (sin datos financieros)
- `lectura` → Solo consulta, sin modificaciones

---

#### 🔧 Servidor SSH

```
Acceso SSH:
  • Host/IP del servidor: [ej: 192.168.1.1]
  • Puerto SSH: [ej: 22]
  • Usuario SSH: [ej: deploy]
  • Método de autenticación: [password / key]
  • Si es key: ruta a la llave privada
  • Directorio de trabajo principal: [ej: /home/cliente/public_html]
```

---

#### 📊 Perfex CRM

```
Perfex CRM:
  • URL de Perfex: [ej: https://crm.bbscomunicaciones.com]
  • API Token: [ej: xxxxxxxxxxxxxxxx]
  • ¿Puede crear/eliminar clientes? (sí/no)
  • ¿Puede ver/crear facturas? (sí/no)
  • ¿Puede gestionar proyectos? (sí/no)
```

---

#### ☁️ Cloudflare

```
Cloudflare:
  • API Token (preferido) o Global API Key: [ej: xxxx...]
  • Account ID: [ej: xxxxxxxxxxxxxxxx]
  • Zonas/dominios a gestionar (separados por coma): [ej: ejemplo.com, otro.com]
  • ¿Puede modificar DNS? (sí/no)
  • ¿Puede modificar reglas de firewall? (sí/no)
  • ¿Puede desplegar Workers? (sí/no)
```

---

#### 🔵 Meta (Facebook / Instagram)

```
Meta Business:
  • App ID: [ej: 123456789]
  • App Secret: [ej: xxxxxxxxxxxxxxxx]
  • Access Token de Página/Usuario: [ej: EAAxxxxxxxx...]
  • ID de Página de Facebook: [ej: 123456789]
  • ID de Cuenta Instagram Business: [ej: 123456789]
  • ID de Cuenta de Anuncios (Ad Account): [ej: act_123456789]
  • ¿Puede publicar contenido? (sí/no)
  • ¿Puede gestionar anuncios y presupuesto? (sí/no)
```

---

#### 🎵 TikTok

```
TikTok:
  • App ID / Client Key: [ej: xxxxxxxxxxxxxxxx]
  • Client Secret: [ej: xxxxxxxxxxxxxxxx]
  • Access Token: [ej: xxxxxxxxxxxxxxxx]
  • Open ID del usuario/negocio: [ej: xxxxxxxxxxxxxxxx]
  • ¿Puede publicar videos? (sí/no)
  • ¿Puede gestionar anuncios? (sí/no)
```

---

#### 🌐 Google Cloud / Maps

```
Google Cloud:
  • API Key de Google Cloud: [ej: AIzaxxxxxxxx]
  • Project ID de GCP: [ej: mi-proyecto-12345]
  • Servicios habilitados: [Maps / Vision / Translate / YouTube / TTS / BigQuery]
  • Service Account JSON (ruta o pegar contenido): [opcional]
```

---

#### 📧 Gmail

```
Gmail:
  • Cuenta de correo: [ej: soporte@cliente.com]
  • Client ID OAuth2: [ej: xxxxxxxx.apps.googleusercontent.com]
  • Client Secret: [ej: xxxxxxxx]
  • Refresh Token: [ej: 1//xxxxxxxx]
```

---

#### 📁 Google Drive

```
Google Drive:
  • Client ID OAuth2: [ej: xxxxxxxx.apps.googleusercontent.com]
  • Client Secret: [ej: xxxxxxxx]
  • Refresh Token: [ej: 1//xxxxxxxx]
  • Carpeta raíz de trabajo (ID o nombre): [opcional]
```

---

#### 📅 Google Calendar

```
Google Calendar:
  • Client ID OAuth2: [ej: xxxxxxxx.apps.googleusercontent.com]
  • Client Secret: [ej: xxxxxxxx]
  • Refresh Token: [ej: 1//xxxxxxxx]
  • Calendar ID principal: [ej: primary o xxxxxxxx@group.calendar.google.com]
```

---

#### 🎨 Canva

```
Canva:
  • Client ID: [ej: OAuthxxxxxxxxxx]
  • Client Secret: [ej: xxxxxxxxxxxxxxxx]
  • Access Token: [ej: xxxxxxxxxxxxxxxx]
```

---

#### 🎙️ ElevenLabs

```
ElevenLabs TTS:
  • API Key: [ej: xxxxxxxxxxxxxxxx]
  • Voz por defecto (ID o nombre): [ej: Rachel / xxxxxxxx]
```

---

#### 🖼️ Flux / Stable Diffusion

```
Generación de imágenes IA:
  • Proveedor: [Flux / Stable Diffusion / Ambos]
  • Flux API Key: [ej: xxxxxxxxxxxxxxxx]
  • SD API Key o URL local: [ej: http://localhost:7860]
```

---

#### 🖼️ Freepik

```
Freepik:
  • API Key: [ej: xxxxxxxxxxxxxxxx]
```

---

#### 🌐 Hostinger

```
Hostinger:
  • API Token: [ej: xxxxxxxxxxxxxxxx]
  • Plan de hosting: [shared / VPS / cloud]
```

---

#### 🟠 Cloudflare Workers / R2 / D1 / KV

```
Cloudflare Developer Platform:
  • API Token: [ej: xxxxxxxxxxxxxxxx]
  • Account ID: [ej: xxxxxxxxxxxxxxxx]
  • (Usa las mismas credenciales que Cloudflare BBS si ya fue configurado)
```

---

#### ⚡ QC (Quick Cache WordPress)

```
Quick Cache / WP Optimization:
  • URL del sitio WordPress: [ej: https://cliente.com]
  • WHM Username de la cuenta: [ej: clienteuser]
  • (Requiere que WHM esté configurado)
```

---

### PASO 4 — Privilegios globales y notas

Pregunta final:

```
¿Alguna restricción o nota especial para este cliente?
  • ¿Horario de mantenimiento permitido? [ej: solo fines de semana]
  • ¿Ambientes (producción, staging, desarrollo)?
  • ¿Persona de contacto técnico?
  • ¿Notas adicionales?
```

---

### PASO 5 — Generación de archivos

Con todos los datos recolectados, genera los siguientes archivos:

#### A) Archivo de perfil del cliente

Guarda en `clients/{client_slug}/profile.json`:

```json
{
  "client": {
    "name": "CLIENT_NAME",
    "slug": "client_slug",
    "created_at": "FECHA_HOY",
    "contact": "CONTACTO",
    "notes": "NOTAS"
  },
  "services": ["lista de servicios seleccionados"],
  "privileges": {
    "whm": "nivel",
    "whmcs": "nivel",
    ...
  },
  "credentials": {
    "whm": { "url": "...", "user": "...", "token": "***REDACTED***" },
    ...
  }
}
```

> ⚠️ **Importante**: El archivo de perfil NO incluye credenciales en texto plano. Las credenciales van en el archivo `.env` separado.

#### B) Archivo de credenciales (privado)

Guarda en `clients/{client_slug}/.env`:

```bash
# BBS Comunicaciones - Credenciales MCP
# Cliente: CLIENT_NAME
# Generado: FECHA_HOY
# ⚠️ NO COMPARTIR - NO SUBIR A GIT

# WHM
WHM_URL=https://servidor.com:2087
WHM_USER=root
WHM_TOKEN=xxxxxxxx

# WHMCS
WHMCS_URL=https://billing.com
WHMCS_API_ID=xxxxxxxx
WHMCS_API_SECRET=xxxxxxxx

# ... resto de servicios
```

#### C) Configuración Claude Desktop / Cowork

Genera `clients/{client_slug}/claude_desktop_config.json` — fragmento listo para agregar al `claude_desktop_config.json` del usuario:

```json
{
  "mcpServers": {
    "whm-CLIENT_SLUG": {
      "command": "npx",
      "args": ["-y", "@bbs/whm-mcp"],
      "env": {
        "WHM_URL": "https://servidor.com:2087",
        "WHM_USER": "root",
        "WHM_TOKEN": "TOKEN_AQUI"
      }
    },
    "whmcs-CLIENT_SLUG": {
      "command": "npx",
      "args": ["-y", "@bbs/whmcs-mcp"],
      "env": {
        "WHMCS_URL": "https://billing.com",
        "WHMCS_API_ID": "ID_AQUI",
        "WHMCS_API_SECRET": "SECRET_AQUI"
      }
    }
    // ... más servidores según servicios seleccionados
  }
}
```

#### D) Instrucciones de instalación

Genera `clients/{client_slug}/INSTALACION.md` con pasos claros:

```markdown
# Instalación MCPs — CLIENT_NAME

## Servicios configurados
- ✅ WHM/cPanel
- ✅ WHMCS
...

## Pasos de instalación

### 1. Instalar dependencias
npm install -g @bbs/whm-mcp @bbs/whmcs-mcp ...

### 2. Agregar a Claude Desktop
Copia el contenido de `claude_desktop_config.json` y agrégalo a:
- Mac: ~/Library/Application Support/Claude/claude_desktop_config.json
- Windows: %APPDATA%\Claude\claude_desktop_config.json

### 3. Reiniciar Claude
Cierra y vuelve a abrir Claude Desktop o Cowork.

### 4. Verificar
Abre Claude y escribe: "¿qué MCPs de WHM tienes disponibles?"
```

---

### PASO 6 — Resumen final

Al terminar, muestra un resumen:

```
✅ Cliente configurado: CLIENT_NAME
📁 Archivos generados en: clients/client_slug/

  📄 profile.json         → Perfil del cliente (sin credenciales)
  🔐 .env                 → Credenciales (PRIVADO)
  ⚙️  claude_desktop_config.json → Configuración MCP lista
  📖 INSTALACION.md       → Guía de instalación paso a paso

🔌 MCPs configurados (N servicios):
  • WHM/cPanel    → whm-client_slug
  • WHMCS         → whmcs-client_slug
  • ...

⚠️  RECUERDA:
  - Guarda el archivo .env en un lugar seguro
  - NO subas las credenciales a GitHub
  - Agrega clients/*/. env al .gitignore
```

---

## REGLAS IMPORTANTES

1. **Nunca inventes credenciales** — Si el usuario no proporciona un dato, deja el placeholder `CONFIGURAR_AQUI`
2. **Valida URLs** — Asegúrate de que las URLs tengan formato correcto (https://)
3. **Sugiere buenas prácticas** — Recomienda usar tokens con permisos mínimos necesarios
4. **Guarda el perfil** — Siempre crea el archivo `profile.json` para poder referenciar el cliente después con `/list-clients` o `/update-client`
5. **Sé conversacional** — Puedes pedir todos los datos de un servicio juntos, pero si el usuario parece confundido, ve uno por uno
