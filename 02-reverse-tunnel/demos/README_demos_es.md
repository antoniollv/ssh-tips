# Demostraciones Asciinema - Túnel SSH Inverso

Este directorio contiene grabaciones asciinema de la demostración del túnel SSH inverso.

## 📹 Grabaciones Disponibles

### Demostración Completa

- **Archivo:** `case01-complete-demo.cast`
- **Duración:** ~5-7 minutos
- **Contenido:** Demostración completa desde la configuración hasta la verificación
- **Caso de uso:** Respaldo para la presentación en vivo o visualización independiente

### Demostraciones Paso a Paso

Grabaciones individuales para cada fase:

1. **setup-crazy-bat.cast** - Iniciando el servidor web
2. **setup-tunnel.cast** - Estableciendo el túnel SSH
3. **verify-demo.cast** - Verificación y pruebas

## 🎬 Comandos de Grabación

### Grabar Demostración Completa

```bash
cd /home/tonete/DevOps/ssh-tips/02-reverse-tunnel

# Iniciar grabación
asciinema rec -t "SSH Tips - Caso 1: Túnel Inverso (Completo)" \
              --idle-time-limit 3 \
              demos/case01-complete-demo.cast

# Ejecutar pasos de la demostración
./setup-crazy-bat.sh
# Esperar a que el contenedor inicie...

# Abrir nueva pestaña/ventana de terminal para el túnel
./setup-tunnel.sh <EC2_PUBLIC_IP>
# El túnel está ejecutándose en primer plano...

# Abrir otra terminal para verificación
./verify-demo.sh <EC2_PUBLIC_IP>

# Mostrar URL pública en navegador o con curl
curl http://<EC2_PUBLIC_IP>:8080

# Presionar Ctrl+D para detener la grabación
```

### Grabar Pasos Individuales

#### Paso 1: Configurar crazy-bat

```bash
asciinema rec -t "Paso 1: Configurar crazy-bat" \
              --idle-time-limit 2 \
              demos/setup-crazy-bat.cast

./setup-crazy-bat.sh

# Ctrl+D para finalizar
```

#### Paso 2: Túnel SSH

```bash
asciinema rec -t "Paso 2: Túnel SSH Inverso" \
              --idle-time-limit 2 \
              demos/setup-tunnel.cast

./setup-tunnel.sh <EC2_PUBLIC_IP>

# Presionar Ctrl+C para detener el túnel, luego Ctrl+D para detener la grabación
```

#### Paso 3: Verificación

```bash
asciinema rec -t "Paso 3: Verificación" \
              --idle-time-limit 2 \
              demos/verify-demo.cast

./verify-demo.sh <EC2_PUBLIC_IP>

# Ctrl+D para finalizar
```

## ▶️ Reproducción

### Reproducción Local

```bash
# Reproducir a velocidad normal
asciinema play demos/case01-complete-demo.cast

# Reproducir a 2x velocidad
asciinema play -s 2 demos/case01-complete-demo.cast

# Reproducir a 0.5x velocidad (más lento, para enseñanza)
asciinema play -s 0.5 demos/case01-complete-demo.cast
```

### Controles Interactivos Durante la Reproducción

- **Espacio** - Pausar/Reanudar
- **`.`** - Avanzar paso a paso (cuando está pausado)
- **Ctrl+C** - Salir de la reproducción

### Durante la Presentación

Si la demostración en vivo falla, cambia rápidamente a la versión grabada:

```bash
# Tener esto listo en una terminal
cd /home/tonete/DevOps/ssh-tips/02-reverse-tunnel
asciinema play demos/case01-complete-demo.cast
```

## 🌐 Subir a asciinema.org (Opcional)

Compartir grabaciones en línea:

```bash
# Subir una grabación individual
asciinema upload demos/case01-complete-demo.cast

# Obtendrás una URL como: https://asciinema.org/a/xxxxx
```

Beneficios:

- Enlace compartible para los asistentes
- Reproductor embebido en páginas web
- No se necesita archivo local

## 📝 Incrustar en Documentación

### Markdown (GitHub, GitLab)

Si se subió a asciinema.org:

```markdown
[![asciicast](https://asciinema.org/a/xxxxx.svg)](https://asciinema.org/a/xxxxx)
```

### HTML

```html
<script id="asciicast-xxxxx" src="https://asciinema.org/a/xxxxx.js" async></script>
```

## 🎨 Convertir a Otros Formatos

### Convertir a GIF

Usando `asciicast2gif` (Docker):

```bash
docker run --rm -v $PWD:/data asciinema/asciicast2gif \
  demos/case01-complete-demo.cast \
  demos/case01-complete-demo.gif
```

### Convertir a SVG

Usando `svg-term-cli`:

```bash
# Instalar
npm install -g svg-term-cli

# Convertir
svg-term --in demos/case01-complete-demo.cast \
         --out demos/case01-complete-demo.svg \
         --window
```

## 💡 Consejos para Mejores Grabaciones

### Antes de Grabar

1. **Limpiar terminal:**

   ```bash
   clear
   ```

2. **Establecer prompt PS1 (opcional):**

   ```bash
   export PS1='$ '
   ```

3. **Redimensionar ventana de terminal** a tamaño estándar (80x24 o 120x40)

4. **Probar comandos** una vez antes de grabar

### Durante la Grabación

1. **Escribir lenta y claramente** - la audiencia necesita leer

2. **Añadir pausas** con comentarios:

   ```bash
   echo "Esperando a que el servicio inicie..."
   sleep 2
   ```

3. **Mostrar salidas claramente:**

   ```bash
   echo "=== Iniciando crazy-bat ==="
   ./setup-crazy-bat.sh
   ```

4. **Evitar errores** - pero si cometes uno, corrígelo naturalmente (más realista)

### Después de Grabar

1. **Revisar inmediatamente:**

   ```bash
   asciinema play demos/tu-grabacion.cast
   ```

2. **Re-grabar si es necesario** - ¡es rápido!

3. **Añadir a git** (son solo archivos de texto):

   ```bash
   git add demos/*.cast
   git commit -m "Añadir demos asciinema para caso 01"
   ```

## 📋 Lista de Verificación Pre-Demostración

Antes de grabar la versión final:

- [ ] Infraestructura AWS desplegada y probada
- [ ] Repositorio crazy-bat clonado localmente
- [ ] IP pública de EC2 anotada
- [ ] Clave SSH accesible en la ruta esperada
- [ ] Todos los scripts probados y funcionando
- [ ] Terminal limpiada y dimensionada apropiadamente
- [ ] Ensayo de práctica completado exitosamente

## 🔧 Solución de Problemas

### La grabación no inicia

```bash
# Verificar instalación de asciinema
asciinema --version

# Reinstalar si es necesario
sudo apt-get install --reinstall asciinema
```

### Archivo demasiado grande

```bash
# Verificar tamaño del archivo
ls -lh demos/*.cast

# Reducir tiempo de inactividad en la grabación
asciinema rec --idle-time-limit 1 demos/nueva-grabacion.cast
```

### Reproducción demasiado rápida/lenta

```bash
# Ajustar velocidad durante la reproducción
asciinema play -s 1.5 demos/grabacion.cast  # 1.5x velocidad
asciinema play -s 0.8 demos/grabacion.cast  # 0.8x velocidad
```

## 📚 Recursos

- [Documentación Asciinema](https://asciinema.org/docs/)
- [Asciinema GitHub](https://github.com/asciinema/asciinema)
- [Formato de archivo asciicast](https://github.com/asciinema/asciinema/blob/develop/doc/asciicast-v2.md)

## 🎯 Estrategia de Grabación Recomendada

Para esta demostración de 8-10 minutos:

**Opción 1: Grabación completa única** (recomendado para respaldo)

- Grabar todo el flujo una vez perfectamente
- Usar durante la presentación si la demostración en vivo falla
- Duración: 5-7 minutos de ejecución real

**Opción 2: Grabaciones divididas** (recomendado para enseñanza)

- Grabar cada paso principal por separado
- Más fácil re-grabar partes individuales
- Más flexibilidad durante la presentación
- Se puede pausar entre secciones para explicar

**Mejor enfoque:** ¡Grabar ambas! Tener la versión completa como plan de respaldo, versiones divididas para enseñanza.

## 📄 Convención de Nombres de Archivo

Usar nombres descriptivos:

```bash
case01-complete-demo.cast           # Demostración completa
case01-step1-setup-crazy-bat.cast   # Pasos individuales
case01-step2-tunnel.cast
case01-step3-verify.cast
case01-troubleshooting.cast         # Problemas comunes
```

---

**Nota:** Los archivos `.cast` están basados en JSON, por lo que son pequeños y amigables con git. Una grabación de 5 minutos típicamente ocupa < 100KB.
