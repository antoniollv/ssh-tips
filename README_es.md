# SSH Tips & Tricks

## 📋 Información General

Charla sobre algunos casos prácticos del protocolo de acceso remoto SSH, más allá de su uso habitual.

**Duración:** 40 minutos  
**Formato:** Presentación remota vía Teams  
**Audiencia:** Profesionales IT con conocimientos de SSH  
**Objetivo:** Mostrar capacidades de SSH mediante demostraciones prácticas

## 🎯 Estructura de la Ponencia

### [01. Introducción](01-introduction/) (2 minutos)

Breve presentación de SSH y *overview* de los casos prácticos que se demostrarán.

**Temas a cubrir:**

- ¿Qué es SSH más allá del acceso remoto?
- Capacidades avanzadas: tunneling, forwarding, X11
- Introducción a los 3 casos prácticos

📁 **Recursos:** [Presentación inicial](01-introduction/README_introduction_es.md)

---

### [02. Caso 1: El Servidor que No Existe](02-reverse-tunnel/) (12 minutos)

#### Túnel SSH Inverso con Crazy-Bat + Systemd

**Concepto:** Servidor web accesible desde internet que físicamente está en tu equipo local, sin IP pública.

**Técnicas demostradas:**

- Remote Port Forwarding (`ssh -R`)
- Servidor web con netcat (crazy-bat)

**Arquitectura:**

```text
Internet → AWS EC2 (IP pública) ← SSH Tunnel ← Equipo Local (crazy-bat)
          puerto 8080              reverse      puerto 8085
      (puerto público EC2)                  (puerto servicio local)
```

**Prueba empírica:** Detener el servicio local y ver cómo el sitio web público se cae.

📁 **Recursos:** [Documentación completa del Caso 1](02-reverse-tunnel/)

---

### [03. Caso 2: Saltos por distintos *hosts* para acceder a servicio privado](03-proxyjump-forwarding/) (12 minutos)

#### ProxyJump + Port Forwarding Integrados

**Concepto:** Acceder a un servicio en servidor privado (sin IP pública).

**Técnicas demostradas:**

- ProxyJump (`ssh -J`)
- Local Port Forwarding (`ssh -L`)

**Arquitectura:**

```text
Equipo local → Bastion (IP pública) → Servidor BBDD Privado
         ssh -J                  solo IP privada
         ssh -L 8080:localhost:80
```

**Resultado:** Acceder a una base de datos remota en locallhost.

📁 **Recursos:** [Documentación completa del Caso 2](03-proxyjump-forwarding/)

---

### [04. Caso 3: La Ventana Mágica](04-x11-forwarding/) (10 minutos)

#### X11 Forwarding con Monitor CPU Remoto

**Concepto:** Ejecutar aplicación gráfica en AWS pero verla en pantalla local. Demostrar en tiempo real cómo la CPU del servidor remoto se dispara.

**Técnicas demostradas:**

- X11 Forwarding (`ssh -X`)
- Ejecución de aplicaciones gráficas remotas
- Monitorización visual en tiempo real

**Arquitectura:**

```text
Equipo local (X11 client) ← SSH + X11 ← AWS EC2 (X11 server + app gráfica)
ventana local                     htop/xeyes/stress-ng
```

**Prueba empírica:** Lanzar stress test en AWS y ver en tu pantalla local cómo la CPU salta de 5% a 100%.

📁 **Recursos:** [Documentación completa del Caso 3](04-x11-forwarding/)

---

### [05. Cierre y Casos Adicionales](05-closing/) (3 minutos)

**Mención rápida de otros casos útiles:**

- **Usuarios SSH enjaulados** (chroot + SFTP only)
- **Algoritmos SSH legacy** para conectar a sistemas antiguos
- **SOCKS Proxy dinámico** (`ssh -D`)
- **Gestión de túneles con systemd**
- **Autossh**
- **Otras capacidades:** SCP, SFTP, rsync sobre SSH

📁 **Recursos:** [Documentación adicional](99-docs/)

---

### 06. Q&A (1 minuto)

Preguntas de la audiencia.

---

## 🛠️ Requisitos Técnicos

### Infraestructura AWS

Todos los recursos se despliegan automáticamente con Terraform:

- **Caso 1:** 1x EC2 t2.micro + Security Group + Elastic IP
- **Caso 2:** 2x EC2 t2.micro + VPC + 2 Subnets + Security Groups + Elastic IP
- **Caso 3:** 1x EC2 t2.small + Security Group + Elastic IP

### Local

- Docker (para crazy-bat)
- Cliente SSH con soporte X11
- X11 server (Linux nativo, WSL2 + VcXsrv, o XQuartz en Mac)
- Terraform
- AWS CLI configurado

### GitHub Actions

Workflows para deploy/destroy automático de infraestructura AWS.

---

## 📚 Recursos Compartidos

Al finalizar la ponencia, se comparte este repositorio completo con:

- ✅ Código Terraform para cada caso
- ✅ Scripts de configuración
- ✅ Grabaciones [asciinema](https://asciinema.org)
- ✅ Documentación detallada en inglés y español
- ✅ Casos adicionales no demostrados en vivo

---

## 📝 Notas para el Presentador

### Plan B

Cada caso tiene grabaciones *asciinema* como respaldo en caso de fallos técnicos.

### Timing

- Mantener ritmo: máximo 12 min por caso
- Reservar tiempo para imprevistos
- Las preguntas al final, no durante las demos

### Mensajes clave

1. **SSH es mucho más que acceso remoto:** tunneling, forwarding, X11
2. **Casos prácticos reales:** no son trucos exóticos, son herramientas útiles
3. **Automatización:** systemd, Terraform, IaC
4. **Documentación disponible:** todo en este repositorio para profundizar

---

## 🔗 Enlaces Útiles

- [OpenSSH Official Documentation](https://www.openssh.com/)
- [Crazy-Bat Project](https://github.com/antoniollv/crazy-bat)
- [Asciinema](https://asciinema.org/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## 📄 Licencia

Este proyecto está bajo licencia CC0 1.0 Universal - ver archivo [LICENSE](LICENSE) para detalles.
