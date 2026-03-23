---
name: update-client
description: Actualiza la configuración MCP de un cliente existente. Permite agregar nuevos servicios, modificar credenciales, cambiar privilegios o revocar accesos sin tener que reconfigurar todo desde cero.
argument-hint: "[nombre del cliente]"
---

# /update-client

Actualiza la configuración MCP de un cliente de BBS Comunicaciones.

## Propósito

Modifica de forma quirúrgica la configuración de un cliente existente: agregar servicios, rotar credenciales, cambiar permisos, o eliminar accesos, sin necesidad de reconfigurar todo.

---

## FLUJO DE EJECUCIÓN

### PASO 1 — Identificar cliente

Si se proporcionó como argumento, úsalo. Si no, muestra la lista y pregunta.

Carga el `profile.json` del cliente y muestra su estado actual:

```
📋 Actualizando: Farmacia López (farmacia-lopez)

Estado actual:
  ✅ WHM/cPanel    (admin)
  ✅ WHMCS         (soporte)
  ✅ Perfex CRM    (admin)
  ✅ Cloudflare    (DNS)
  ❌ Meta          (no configurado)
  ❌ TikTok        (no configurado)
```

---

### PASO 2 — Tipo de actualización

Pregunta qué desea modificar:

```
¿Qué deseas actualizar?

  [1] 🔑 Rotar/actualizar credenciales de un servicio existente
  [2] ➕ Agregar un servicio nuevo
  [3] ➖ Eliminar/revocar un servicio
  [4] 👤 Cambiar privilegios de un servicio
  [5] 📝 Actualizar notas o información del cliente
  [6] 🔄 Regenerar todos los archivos de configuración
```

---

### OPCIÓN 1 — Rotar credenciales

Pregunta cuál servicio:
```
¿Qué credencial deseas actualizar?
  [1] WHM Token
  [2] WHMCS API Secret
  [3] Perfex API Token
  [4] Cloudflare API Token
  ...
```

Solicita el nuevo valor, actualiza el `.env` y regenera el `claude_desktop_config.json`.

Confirma:
```
✅ Credencial actualizada: WHM Token para Farmacia López
📄 .env actualizado
⚙️  claude_desktop_config.json regenerado
⚠️  Recuerda reinstalar con /install-mcp farmacia-lopez para aplicar cambios
```

---

### OPCIÓN 2 — Agregar servicio nuevo

Muestra solo los servicios que NO están configurados:
```
Servicios disponibles (no configurados):
  [ ] Meta (Facebook/Instagram)
  [ ] TikTok
  [ ] Google Cloud
  [ ] ElevenLabs
  ...
```

Para el servicio seleccionado, ejecuta el mismo flujo de recolección de credenciales que `/setup-client`.

Agrega al perfil y regenera los archivos.

---

### OPCIÓN 3 — Eliminar servicio

```
⚠️  ¿Estás seguro que deseas eliminar el acceso a WHMCS para Farmacia López?
Esta acción:
  • Elimina las credenciales del .env
  • Elimina el servidor MCP del claude_desktop_config.json
  • Actualiza el profile.json

¿Confirmar? (sí/no)
```

---

### OPCIÓN 4 — Cambiar privilegios

```
Privilegios actuales de WHM: admin
Nuevo nivel de privilegio:
  [1] admin   → Acceso completo
  [2] soporte → Ver + reiniciar servicios (sin crear/borrar)
  [3] lectura → Solo consulta
```

Actualiza el `profile.json` y agrega nota de auditoría:
```json
{
  "audit_log": [
    {
      "date": "2026-03-20",
      "action": "privilege_change",
      "service": "whm",
      "from": "admin",
      "to": "soporte",
      "note": "Reducción de privilegios por solicitud del cliente"
    }
  ]
}
```

---

### OPCIÓN 6 — Regenerar todos los archivos

Útil cuando se actualiza el template del installer o se cambia el formato:

```
🔄 Regenerando configuración completa para: Farmacia López

  ✅ .env regenerado
  ✅ claude_desktop_config.json regenerado
  ✅ INSTALACION.md actualizado
  ✅ profile.json actualizado

Recuerda ejecutar /install-mcp farmacia-lopez para aplicar los cambios.
```

---

## HISTORIAL DE CAMBIOS

Cada actualización queda registrada en `clients/{slug}/changelog.json`:

```json
[
  {
    "date": "2026-01-15",
    "action": "created",
    "services": ["whm", "whmcs", "perfex"]
  },
  {
    "date": "2026-02-10",
    "action": "credential_rotated",
    "service": "cloudflare",
    "note": "Token rotado por política de seguridad trimestral"
  },
  {
    "date": "2026-03-20",
    "action": "service_added",
    "service": "meta",
    "privileges": "admin"
  }
]
```
