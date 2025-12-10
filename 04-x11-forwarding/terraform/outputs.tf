output "x11_server_public_ip" {
  description = "Public IP of X11 server"
  value       = aws_eip.x11_server.public_ip
}

output "ssh_connection_command" {
  description = "SSH command with X11 forwarding enabled"
  value       = "ssh -X -i ~/.ssh/your-key.pem ec2-user@${aws_eip.x11_server.public_ip}"
}

output "demo_commands" {
  description = "Commands to test X11 forwarding"
  value = <<-EOT
    
    ═══════════════════════════════════════════════════════════════
    🖥️  X11 Forwarding Demo - Connection Instructions
    ═══════════════════════════════════════════════════════════════
    
    📋 Prerequisites (Local Machine):
    
    Linux:
      ✓ X11 already installed (no action needed)
      
    Windows:
      1. Install VcXsrv: https://sourceforge.net/projects/vcxsrv/
      2. Launch XLaunch with default settings
      3. Allow firewall access if prompted
      
    ═══════════════════════════════════════════════════════════════
    
    🔐 Step 1: Connect with X11 forwarding
    
    ssh -X -i ~/.ssh/your-key.pem ec2-user@${aws_eip.x11_server.public_ip}
    
    ═══════════════════════════════════════════════════════════════
    
    🎨 Step 2: Test X11 forwarding (choose one or all)
    
    # Simple test (eyes that follow your cursor)
    xeyes
    
    # X11 terminal (run commands with graphical output)
    xterm
    
    ═══════════════════════════════════════════════════════════════
    
    ✅ Expected Result:
       - GUI window appears on your LOCAL screen
       - Application runs on REMOTE EC2 instance
       - Close window or Ctrl+C to exit
    
    ═══════════════════════════════════════════════════════════════
  EOT
}

output "windows_instructions" {
  description = "Additional instructions for Windows users"
  value = <<-EOT
    
    ═══════════════════════════════════════════════════════════════
    🪟 Windows-Specific Instructions
    ═══════════════════════════════════════════════════════════════
    
    Option 1: Using VcXsrv + OpenSSH
    
    1. Install VcXsrv: https://sourceforge.net/projects/vcxsrv/
    2. Launch XLaunch:
       - Display settings: Multiple windows
       - Start no client
       - Disable access control: ✓
    3. Set DISPLAY variable in PowerShell:
       $env:DISPLAY="localhost:0.0"
    4. Connect:
       ssh -X -i ~/.ssh/your-key.pem ec2-user@${aws_eip.x11_server.public_ip}
    
    ───────────────────────────────────────────────────────────────
    
    Option 2: Using MobaXterm (Easiest)
    
    1. Download MobaXterm: https://mobaxterm.mobatek.net/
    2. Built-in X11 server activates automatically
    3. Create new SSH session with X11-Forwarding enabled
    4. Connect and run: xeyes
    
    ═══════════════════════════════════════════════════════════════
  EOT
}
