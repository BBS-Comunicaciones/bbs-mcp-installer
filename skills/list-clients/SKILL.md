---
name: list-clients
description: Lista todos los clientes configurados con sus MCPs, credenciales y estado. Permite ver un resumen rápido o detalle completo de cualquier cliente de BBS Comunicaciones.
argument-hint: "[nombre del cliente para ver detalles, o vacío para listar todos]"
---

# /list-clients

Gestión y visualización de clientes configurados en BBS Comunicaciones.

## Propósito

Muestra todos los clientes que tienen configuración MCP guardada, con opción de ver detalles, verificar conexiones y acceder rápidamente a cualquier cliente.

---

## FLUJO DE EJECUCIÓN

### Sin argumentos — Listar todos los clientes

Lee todos los archivos `clients/*/profile.json` y muestra:

```
📋 CLIENTES CONFIGURADOS — BBS COMUNICACIONES
═══════════════════════════════════════════════

  #  CLIENTE                  SLUG               MCPs    CREADO
  ─────────────────────────────────────────────────────────────
  1  Farmacia López           farmacia-lopez      5 MCPs  2026-01-15
  2  TechMex SA               techmex             8 MCPs  2026-02-03
  3  Hotel Paraíso            hotel-paraiso       3 MCPs  2026-03-01
  4  Restaurante El Buen Gusto restaurante-bg     4 MCPs  2026-03-20

Total: 4 clientes configurados

💡 Para ver detalles: /list-clients farmacia-lopez
💡 Para actualizar:   /update-client farmacia-lopez
💡 Para instalar:     /install-mcp farmacia-lopez
```

---

### Con argumento — Ver detalles de un cliente

Si se proporciona nombre o slug (`/list-clients farmacia-lopez`):

```
📋 CLIENTE: Farmacia López
════════════════════════════════════════════

  Slug:          farmacia-lopez
  Creado:        2026-01-15
  Contacto:      Dr. Juan López (juan@farmacia.com)
  Notas:         Solo ambiente de producción. Mantenimiento sábados.

SERVICIOS CONFIGURADOS (5 MCPs):
  ✅ WHM/cPanel       → whm-farmacia-lopez     (admin)
  ✅ WHMCS            → whmcs-farmacia-lopez    (soporte)
  ✅ Perfex CRM       → perfex-farmacia-lopez   (admin)
  ✅ Cloudflare       → cloudflare-farmacia-lopez (DNS + firewall)
  ❌ Meta             → No configurado
  ❌ TikTok           → No configurado
  ✅ Gmail            → gmail-farmacia-lopez    (lectura + envío)

CREDENCIALES (resumen, sin valores):
  WHM URL:      https://srv01.bbscomunicaciones.com:2087 ✅
  WHMCS URL:    https://billing.farmacialopez.com ✅
  Perfex URL:   https://crm.bbscomunicaciones.com ✅
  Cloudflare:   farmacialopez.com, farmlopez.mx ✅

ARCHIVOS:
  📄 clients/farmacia-lopez/profile.json
  🔐 clients/farmacia-lopez/.env
  ⚙️  clients/farmacia-lopez/claude_desktop_config.json
  📖 clients/farmacia-lopez/INSTALACION.md

ACCIONES:
  /install-mcp farmacia-lopez    → Instalar/reinstalar MCPs
  /update-client farmacia-lopez  → Actualizar credenciales o servicios
```

---

### Modo búsqueda

Si el argumento no coincide exactamente, busca por coincidencia parcial:

```
/list-clients farm
→ Encontrado: farmacia-lopez (Farmacia López) ✅
```

---

## OPCIONES ADICIONALES

Cuando lista todos los clientes, ofrece acciones rápidas:

```
¿Qué deseas hacer?
  [1] Ver detalles de un cliente específico
  [2] Instalar MCPs para un cliente
  [3] Actualizar un cliente existente
  [4] Configurar un cliente nuevo (/setup-client)
  [5] Exportar lista de clientes a CSV
```

---

## EXPORTAR A CSV

Si el usuario elige exportar:

```csv
Nombre,Slug,MCPs,Creado,Servicios,Contacto
Farmacia López,farmacia-lopez,5,2026-01-15,"WHM;WHMCS;Perfex;Cloudflare;Gmail",juan@farmacia.com
TechMex SA,techmex,8,2026-02-03,"WHM;WHMCS;SSH;Perfex;Cloudflare;Meta;TikTok;Google Cloud",tech@techmex.com
```

Guarda en `clients/export-FECHA.csv`.
