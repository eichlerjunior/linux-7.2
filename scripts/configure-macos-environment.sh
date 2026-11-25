#!/bin/bash
# Configure macOS-like environment on dual3060

echo "=== macOS-like environment on dual3060 ==="

echo "Display: 1920x1080@60Hz (max resolution)"
echo "Theme: Arc (macOS-like)"
echo "Icons: Moka (macOS-like)"

# Set GTK theme
mkdir -p /home/dual3060/.config/gtk-3.0
mkdir -p /home/dual3060/.config/gtk-4.0
mkdir -p /home/dual3060/.config/dconf
mkdir -p /home/dual3060/.config/gnome-shell/extensions

cat > /home/dual3060/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Arc
gtk-icon-theme-name=Moka
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
EOF

cat > /home/dual3060/.config/gtk-4.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Arc
gtk-icon-theme-name=Moka
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
EOF

cat > /home/dual3060/.config/dconf/config << 'EOF'
[org/gnome/desktop/interface]
gtk-theme='Arc'
icon-theme='Moka'
cursor-theme='Adwaita'
EOF

cat > /home/dual3060/.config/gnome-shell/extensions/org.gnome.shell.extensions.ini << 'EOF'
[org.gnome.shell.extensions]
disable-workspaces-restoration=false
disable-clippy=false
disable-windows-navigators=false
EOF

# Display resolution
export DISPLAY=:1
xrandr --output HDMI-0 --mode 1920x1080 --rate 60 2>/dev/null

echo "Configuration complete"
echo "macOS-like environment ready"
