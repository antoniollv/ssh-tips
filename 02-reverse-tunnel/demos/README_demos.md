# Asciinema Demos - Reverse SSH Tunnel

This directory contains asciinema recordings of the reverse SSH tunnel demonstration.

## 📹 Available Recordings

### Complete Demo

- **File:** `case01-complete-demo.cast`
- **Duration:** ~5-7 minutes
- **Content:** Full demonstration from setup to verification
- **Use case:** Backup for live presentation or standalone viewing

### Step-by-Step Demos

Individual recordings for each phase:

1. **setup-crazy-bat.cast** - Starting the web server
2. **setup-tunnel.cast** - Establishing the SSH tunnel
3. **verify-demo.cast** - Verification and testing

## 🎬 Recording Commands

### Record Complete Demo

```bash
cd /home/tonete/DevOps/ssh-tips/02-reverse-tunnel

# Start recording
asciinema rec -t "SSH Tips - Case 1: Reverse Tunnel (Complete)" \
              --idle-time-limit 3 \
              demos/case01-complete-demo.cast

# Execute demo steps
./setup-crazy-bat.sh
# Wait for container to start...

# Open new terminal tab/window for tunnel
./setup-tunnel.sh <EC2_PUBLIC_IP>
# Tunnel is running in foreground...

# Open another terminal for verification
./verify-demo.sh <EC2_PUBLIC_IP>

# Show public URL in browser or with curl
curl http://<EC2_PUBLIC_IP>:8080

# Press Ctrl+D to stop recording
```

### Record Individual Steps

**Step 1: Setup crazy-bat**

```bash
asciinema rec -t "Step 1: Setup crazy-bat" \
              --idle-time-limit 2 \
              demos/setup-crazy-bat.cast

./setup-crazy-bat.sh

# Ctrl+D to finish
```

**Step 2: SSH Tunnel**

```bash
asciinema rec -t "Step 2: SSH Reverse Tunnel" \
              --idle-time-limit 2 \
              demos/setup-tunnel.cast

./setup-tunnel.sh <EC2_PUBLIC_IP>

# Press Ctrl+C to stop tunnel, then Ctrl+D to stop recording
```

**Step 3: Verification**

```bash
asciinema rec -t "Step 3: Verification" \
              --idle-time-limit 2 \
              demos/verify-demo.cast

./verify-demo.sh <EC2_PUBLIC_IP>

# Ctrl+D to finish
```

## ▶️ Playback

### Local Playback

```bash
# Play at normal speed
asciinema play demos/case01-complete-demo.cast

# Play at 2x speed
asciinema play -s 2 demos/case01-complete-demo.cast

# Play at 0.5x speed (slower, for teaching)
asciinema play -s 0.5 demos/case01-complete-demo.cast
```

### Interactive Controls During Playback

- **Space** - Pause/Resume
- **`.`** - Step forward (when paused)
- **Ctrl+C** - Exit playback

### During Presentation

If live demo fails, quickly switch to recorded version:

```bash
# Have this ready in a terminal
cd /home/tonete/DevOps/ssh-tips/02-reverse-tunnel
asciinema play demos/case01-complete-demo.cast
```

## 🌐 Upload to asciinema.org (Optional)

Share recordings online:

```bash
# Upload single recording
asciinema upload demos/case01-complete-demo.cast

# You'll get a URL like: https://asciinema.org/a/xxxxx
```

Benefits:
- Shareable link for attendees
- Embedded player in web pages
- No local file needed

## 📝 Embedding in Documentation

### Markdown (GitHub, GitLab)

If uploaded to asciinema.org:

```markdown
[![asciicast](https://asciinema.org/a/xxxxx.svg)](https://asciinema.org/a/xxxxx)
```

### HTML

```html
<script id="asciicast-xxxxx" src="https://asciinema.org/a/xxxxx.js" async></script>
```

## 🎨 Converting to Other Formats

### Convert to GIF

Using `asciicast2gif` (Docker):

```bash
docker run --rm -v $PWD:/data asciinema/asciicast2gif \
  demos/case01-complete-demo.cast \
  demos/case01-complete-demo.gif
```

### Convert to SVG

Using `svg-term-cli`:

```bash
# Install
npm install -g svg-term-cli

# Convert
svg-term --in demos/case01-complete-demo.cast \
         --out demos/case01-complete-demo.svg \
         --window
```

## 💡 Tips for Better Recordings

### Before Recording

1. **Clean terminal:**
   ```bash
   clear
   ```

2. **Set PS1 prompt (optional):**
   ```bash
   export PS1='$ '
   ```

3. **Resize terminal window** to standard size (80x24 or 120x40)

4. **Test commands** once before recording

### During Recording

1. **Type slowly and clearly** - audience needs to read
2. **Add pauses** with comments:
   ```bash
   echo "Waiting for service to start..."
   sleep 2
   ```

3. **Show outputs clearly:**
   ```bash
   echo "=== Starting crazy-bat ==="
   ./setup-crazy-bat.sh
   ```

4. **Avoid mistakes** - but if you make one, fix it naturally (more realistic)

### After Recording

1. **Review immediately:**
   ```bash
   asciinema play demos/your-recording.cast
   ```

2. **Re-record if needed** - it's quick!

3. **Add to git** (they're just text files):
   ```bash
   git add demos/*.cast
   git commit -m "Add asciinema demos for case 01"
   ```

## 📋 Pre-Demo Checklist

Before recording the final version:

- [ ] AWS infrastructure deployed and tested
- [ ] crazy-bat repository cloned locally
- [ ] EC2 public IP noted down
- [ ] SSH key accessible at expected path
- [ ] All scripts tested and working
- [ ] Terminal cleared and sized appropriately
- [ ] Practice run completed successfully

## 🔧 Troubleshooting

### Recording doesn't start

```bash
# Check asciinema installation
asciinema --version

# Reinstall if needed
sudo apt-get install --reinstall asciinema
```

### File too large

```bash
# Check file size
ls -lh demos/*.cast

# Reduce idle time in recording
asciinema rec --idle-time-limit 1 demos/new-recording.cast
```

### Playback too fast/slow

```bash
# Adjust speed during playback
asciinema play -s 1.5 demos/recording.cast  # 1.5x speed
asciinema play -s 0.8 demos/recording.cast  # 0.8x speed
```

## 📚 Resources

- [Asciinema Documentation](https://asciinema.org/docs/)
- [Asciinema GitHub](https://github.com/asciinema/asciinema)
- [asciicast file format](https://github.com/asciinema/asciinema/blob/develop/doc/asciicast-v2.md)

## 🎯 Recommended Recording Strategy

For this 8-10 minute demo:

**Option 1: Single complete recording** (recommended for backup)
- Record entire flow once perfectly
- Use during presentation if live demo fails
- Duration: 5-7 minutes actual execution

**Option 2: Split recordings** (recommended for teaching)
- Record each major step separately
- Easier to re-record individual parts
- More flexibility during presentation
- Can pause between sections to explain

**Best approach:** Record both! Have complete version as failsafe, split versions for teaching.

## 📄 Filename Convention

Use descriptive names:

```bash
case01-complete-demo.cast           # Full demonstration
case01-step1-setup-crazy-bat.cast   # Individual steps
case01-step2-tunnel.cast
case01-step3-verify.cast
case01-troubleshooting.cast         # Common issues
```

---

**Note:** `.cast` files are JSON-based text files, so they're small and git-friendly. A 5-minute recording is typically < 100KB.
