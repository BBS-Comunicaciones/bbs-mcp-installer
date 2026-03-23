# BBS MCP Installer

**Instalador y gestor de MCPs de BBS Comunicaciones para Claude Desktop, Cowork y Claude Code.**

Configura todos los servicios de un cliente nuevo en minutos con un wizard interactivo que pregunta exactamente lo que necesita saber.

---

## ¿Qué hace?

Con un simple comando `/setup-client` en Claude, puedes:

- Seleccionar qué servicios necesita el cliente (WHM, WHMCS, Cloudflare, Meta, TikTok, etc.)
- Ingresar las credenciales de cada servicio de forma guiada
- Definir niveles de privilegio por servicio (admin, soporte, lectura)
- Generar automáticamente los archivos de configuración listos para instalar
- Instalar todo con `/install-mcp`

---

## Instalación rápida

### Mac / Linux

```bash
curl -sSL https://raw.githubusercontent.com/bbscomunicaciones/bbs-mcp-installer/main/scripts/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/bbscomunicaciones/bbs-mcp-installer/main/scripts/install.ps1 | iex
```

### Manual (clonar repositorio)

```bash
git clone https://github.com/bbscomunicaciones/bbs-mcp-installer.git ~/.bbs-mcp-installer
```

---

## Comandos disponibles en Claude

Una vez instalado, abre Claude Desktop o Cowork y usa:

| Comando | Descripción |
|---------|-------------|
| `/setup-client` | Wizard para configurar un cliente nuevo |
| `/install-mcp [cliente]` | Instala los MCPs de un cliente en Claude |
| `/list-clients` | Lista todos los clientes configurados |
| `/update-client [cliente]` | Actualiza credenciales, agrega o quita servicios |

---

## Servicios soportados

### Infraestructura & Hosting
| Servicio | MCP | Descripción |
|----------|-----|-------------|
| WHM/cPanel | `@bbs/whm-mcp` | Servidor web, cuentas, DNS, SSL |
| WHMCS | `@bbs/whmcs-mcp` | Facturación, dominios, órdenes |
| SSH | `@bbs/ssh-mcp` | Acceso directo al servidor |

### CRM & Proyectos
| Servicio | MCP | Descripción |
|----------|-----|-------------|
| Perfex CRM | `@bbs/perfex-mcp` | Clientes, proyectos, facturas, tickets |

### DNS & Seguridad
| Servicio | MCP | Descripción |
|----------|-----|-------------|
| Cloudflare | `@bbs/cloudflare-mcp` | DNS, CDN, firewall, workers |
| Cloudflare Dev | `@cloudflare/mcp-server-cloudflare` | Workers, R2, D1, KV |
| Quick Cache | `@bbs/qc-mcp` | Optimización caché WordPress |

### Marketing & Redes Sociales
| Servicio | MCP | Descripción |
|----------|-----|-------------|
| Meta | `@bbs/meta-mcp` | Facebook, Instagram, Meta Ads |
| TikTok | `@bbs/tiktok-mcp` | Videos, anuncios, estadísticas |
| Google Cloud | `@bbs/google-cloud-mcp` | Maps, Vision, Translate, YouTube |

### Productividad
| Servicio | MCP | Descripción |
|----------|-----|-------------|
| Gmail | `@bbs/gmail-mcp` | Correo electrónico |
| Google Drive | `@bbs/gdrive-mcp` | Documentos y archivos |
| Google Calendar | `@bbs/gcal-mcp` | Calendario y reuniones |

### Creatividad & Medios
| Servicio | MCP | Descripción |
|----------|-----|-------------|
| Canva | `@bbs/canva-mcp` | Diseño gráfico |
| ElevenLabs | `@bbs/elevenlabs-mcp` | Text-to-Speech IA |
| Flux AI | `@bbs/flux-mcp` | Generación de imágenes |
| Freepik | `@bbs/freepik-mcp` | Banco de imágenes e íconos |

### Dominio & Registro
| Servicio | MCP | Descripción |
|----------|-----|-------------|
| Hostinger | `@bbs/hostinger-mcp` | Dominios, hosting, VPS |

---

## Estructura del proyecto

```
bbs-mcp-installer/
├── README.md
├── CONNECTORS.md
├── skills/
│   ├── setup-client/       # Wizard de configuración de cliente
│   │   └── SKILL.md
│   ├── install-mcp/        # Instalador de MCPs
│   │   └── SKILL.md
│   ├── list-clients/       # Listado de clientes
│   │   └── SKILL.md
│   └── update-client/      # Actualizador de configuraciones
│       └── SKILL.md
├── templates/
│   ├── mcp-config-template.json    # Template maestro de configuración
│   ├── env-template.txt            # Template de variables de entorno
│   └── profile-template.json      # Template de perfil de cliente
├── scripts/
│   ├── install.sh                  # Instalador Mac/Linux
│   └── install.ps1                 # Instalador Windows
└── clients/                        # ← Creado automáticamente
    ├── .gitignore                  # Protege credenciales
    ├── farmacia-lopez/
    │   ├── profile.json
    │   ├── .env                    # ⚠️ PRIVADO
    │   ├── claude_desktop_config.json
    │   └── INSTALACION.md
    └── otro-cliente/
        └── ...
```

---

## Flujo típico de uso

```
1. Cliente nuevo llega a BBS Comunicaciones
        ↓
2. En Claude: /setup-client "Nombre del Cliente"
        ↓
3. Wizard pregunta: ¿Qué servicios necesita?
   ☑ WHM/cPanel  ☑ WHMCS  ☑ Cloudflare  ☑ Meta
        ↓
4. Para cada servicio: ingresa URL, API key, privilegios
        ↓
5. Se generan automáticamente:
   • profile.json (sin credenciales)
   • .env (credenciales privadas)
   • claude_desktop_config.json (configuración MCP)
   • INSTALACION.md (guía paso a paso)
        ↓
6. /install-mcp nombre-cliente
        ↓
7. MCPs instalados y activos en Claude ✅
```

---

## Seguridad

- Las credenciales se guardan en archivos `.env` **nunca en JSON rastreado por git**
- El `.gitignore` automático excluye todos los `.env` del control de versiones
- Los perfiles (`profile.json`) solo contienen metadatos, no credenciales
- Se recomienda usar **tokens con permisos mínimos** para cada servicio

---

## Requisitos

- Node.js v18 o superior
- npm v8 o superior
- Claude Desktop, Cowork o Claude Code CLI
- git (recomendado, no obligatorio)

---

## Desarrollado por

**BBS Comunicaciones**
it@bbscomunicaciones.com
https://bbscomunicaciones.com

---

## Licencia

Uso interno BBS Comunicaciones. Todos los derechos reservados.
