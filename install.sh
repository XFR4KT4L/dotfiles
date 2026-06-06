#!/usr/bin/env bash
# ============================================================
#  install.sh — Instalador completo XFR4KT4L
#  Arch Linux + Hyprland + NVIDIA RTX 3070 + Dual Monitor
#  Reproduce exactamente el sistema actual de trafalgar@Monster
#
#  USO:
#    1. Instala Arch Linux con archinstall (perfil minimal)
#    2. Configura los parámetros del kernel NVIDIA (ver paso 2)
#    3. Ejecuta este script: chmod +x install.sh && ./install.sh
#
#  TIEMPO ESTIMADO: ~45 minutos
# ============================================================

set -e

# ── Colores ───────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
BLU='\033[0;34m'; CYN='\033[0;36m'; BLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${CYN}[....] $1${NC}"; }
success() { echo -e "${GRN}[ OK ] $1${NC}"; }
warn()    { echo -e "${YLW}[WARN] $1${NC}"; }
error()   { echo -e "${RED}[ERR!] $1${NC}"; exit 1; }
step()    {
  echo ""
  echo -e "${BLD}${BLU}══════════════════════════════════════════════${NC}"
  echo -e "${BLD}${BLU}  $1${NC}"
  echo -e "${BLD}${BLU}══════════════════════════════════════════════${NC}"
}

DOTFILES="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/XFR4KT4L/dotfiles"
USER=$(whoami)

# ── Verificaciones previas ────────────────────────────────
step "Verificaciones previas"

[[ "$USER" == "root" ]] && error "No ejecutes este script como root. Usa tu usuario normal con sudo."

if ! ping -c 1 archlinux.org &>/dev/null; then
  error "Sin conexión a internet. Conéctate y vuelve a ejecutar."
fi

success "Usuario: $USER | Internet: OK"

# ── Verificar kernel NVIDIA ───────────────────────────────
if ! grep -q "nvidia-drm.modeset=1" /etc/kernel/cmdline 2>/dev/null; then
  warn "ATENCIÓN: Los parámetros NVIDIA no están configurados."
  warn "Edita /etc/kernel/cmdline y añade al final de la línea:"
  warn "  nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=0"
  warn "Luego ejecuta: sudo mkinitcpio -P && sudo reboot"
  warn "Y vuelve a ejecutar este script."
  read -p "¿Continuar de todas formas? [s/N] " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Ss]$ ]] && exit 1
fi

# ============================================================
step "1/8  Habilitar multilib y actualizar sistema"
# ============================================================

if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  info "Habilitando repositorio multilib..."
  sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi

sudo pacman -Syu --noconfirm
success "Sistema actualizado"

# ============================================================
step "2/8  Drivers NVIDIA RTX 3070"
# ============================================================

sudo pacman -S --needed --noconfirm \
  nvidia-open nvidia-utils nvidia-settings \
  lib32-nvidia-utils \
  libva-nvidia-driver \
  lib32-opencl-nvidia opencl-nvidia \
  intel-media-driver libva-intel-driver \
  mesa lib32-mesa \
  vulkan-icd-loader lib32-vulkan-icd-loader \
  openal lib32-openal

# Módulos en mkinitcpio
MKINIT="/etc/mkinitcpio.conf"
if ! grep -q "nvidia_drm" "$MKINIT"; then
  info "Añadiendo módulos NVIDIA a mkinitcpio..."
  sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' "$MKINIT"
  sudo mkinitcpio -P
  success "mkinitcpio actualizado"
else
  info "Módulos NVIDIA ya presentes"
fi

# Parámetros del kernel
CMDLINE="/etc/kernel/cmdline"
if ! grep -q "nvidia-drm.modeset=1" "$CMDLINE"; then
  warn "Añadiendo parámetros NVIDIA al kernel..."
  sudo sed -i 's/$/ nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=0/' "$CMDLINE"
  sudo mkinitcpio -P
fi

# Servicios de suspensión NVIDIA
sudo systemctl enable nvidia-suspend.service 2>/dev/null || true
sudo systemctl enable nvidia-hibernate.service 2>/dev/null || true
sudo systemctl enable nvidia-resume.service 2>/dev/null || true

success "Drivers NVIDIA configurados"

# ============================================================
step "3/8  Paquetes base del sistema"
# ============================================================

sudo pacman -S --needed --noconfirm \
  stow git base-devel curl wget \
  zsh \
  pipewire pipewire-pulse pipewire-alsa wireplumber \
  bluez bluez-utils blueman \
  networkmanager \
  polkit-kde-agent \
  xdg-desktop-portal-hyprland xdg-user-dirs \
  qt5-wayland qt6-wayland qt5ct \
  noto-fonts noto-fonts-emoji noto-fonts-cjk \
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common \
  ttf-hack-nerd \
  gvfs thunar thunar-volman tumbler ffmpegthumbnailer \
  pavucontrol playerctl brightnessctl \
  btop fastfetch \
  ranger \
  lsd \
  python-gobject \
  mesa lib32-mesa \
  vulkan-tools \
  gamemode lib32-gamemode \
  gamescope \
  mangohud lib32-mangohud \
  grim slurp \
  wl-clipboard cliphist \
  nm-connection-editor \
  neovim

success "Paquetes base instalados"

# ============================================================
step "4/8  AUR helper (paru) + paquetes AUR"
# ============================================================

if ! command -v paru &>/dev/null; then
  info "Instalando paru..."
  cd /tmp
  git clone https://aur.archlinux.org/paru.git
  cd paru && makepkg -si --noconfirm
  cd "$HOME"
  success "paru instalado"
fi

paru -S --needed --noconfirm \
  hyprland \
  xdg-desktop-portal-hyprland \
  hyprlock \
  hypridle \
  hyprpicker \
  waybar \
  wofi \
  mako \
  kitty \
  wlogout \
  awww \
  swappy \
  catppuccin-gtk-theme-mocha \
  papirus-icon-theme \
  fluent-icon-theme-git \
  bibata-cursor-theme \
  nwg-look \
  zen-browser-bin \
  visual-studio-code-bin \
  steam \
  proton-ge-custom-bin \
  sddm \
  sddm-catppuccin-git \
  discord \
  vesktop \
  spotify \
  github-cli

success "Paquetes AUR instalados"

# ============================================================
step "5/8  Servicios del sistema"
# ============================================================

sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable --now gamemode 2>/dev/null || true

systemctl --user enable pipewire.service 2>/dev/null || true
systemctl --user enable pipewire-pulse.service 2>/dev/null || true
systemctl --user enable wireplumber.service 2>/dev/null || true

# SDDM tema Catppuccin
sudo mkdir -p /etc/sddm.conf.d
cat << 'EOF' | sudo tee /etc/sddm.conf > /dev/null
[Theme]
Current=catppuccin
EOF

# Dependencias SDDM Catppuccin
sudo pacman -S --needed --noconfirm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg qt6-5compat

# Locale en_US.UTF-8 para compatibilidad con juegos Steam
if ! grep -q "^en_US.UTF-8" /etc/locale.gen; then
  sudo sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
  sudo locale-gen
fi

xdg-user-dirs-update
success "Servicios habilitados"

# ============================================================
step "6/8  Zsh y herramientas de shell"
# ============================================================

# Plugins de Zsh
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.zsh/zsh-autosuggestions"
fi
if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$HOME/.zsh/zsh-syntax-highlighting"
fi

# Starship
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# Cambiar shell a Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
  success "Shell cambiada a Zsh"
fi

# Cursor por defecto
mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" << 'EOF'
[Icon Theme]
Inherits=Bibata-Modern-Classic
EOF

success "Shell y herramientas configuradas"

# ============================================================
step "7/8  Dotfiles desde GitHub"
# ============================================================

if [ ! -d "$DOTFILES" ]; then
  info "Clonando dotfiles desde $DOTFILES_REPO..."
  git clone "$DOTFILES_REPO" "$DOTFILES"
else
  info "Dotfiles ya existen en $DOTFILES, actualizando..."
  cd "$DOTFILES" && git pull
fi

cd "$DOTFILES"

# Aplicar symlinks con Stow
info "Aplicando symlinks con GNU Stow..."
for pkg in hypr waybar kitty wofi mako wlogout nvim fastfetch ranger swappy starship gtk; do
  stow --restow "$pkg" 2>/dev/null && \
    echo -e "${GRN}[ OK ]${NC} stow: $pkg" || \
    echo -e "${YLW}[WARN]${NC} stow: $pkg (revisar manualmente)"
done

stow --restow zsh --target="$HOME" 2>/dev/null && \
  success "stow: zsh" || warn "stow: zsh"

# Carpeta de wallpapers
mkdir -p "$HOME/.config/hypr/wallpapers"
info "Carpeta de wallpapers creada: ~/.config/hypr/wallpapers/"
warn "Copia tus wallpapers a ~/.config/hypr/wallpapers/ para que awww los encuentre."

# Aplicar tema GTK
gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-mauve-standard+default' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Fluent-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

success "Dotfiles aplicados"

# ============================================================
step "8/8  Configuración de monitores"
# ============================================================

warn "IMPORTANTE: Verifica los nombres de tus monitores tras reiniciar:"
warn "  hyprctl monitors"
warn ""
warn "Si no son DP-1 y DP-2, actualiza estos archivos:"
warn "  ~/.config/hypr/monitors.conf"
warn "  ~/.config/hypr/workspaces.conf"
warn "  ~/.config/hypr/keybinds.conf"
warn ""
warn "Usa el comando:"
warn "  sed -i 's/DP-1/NOMBRE_REAL/g' ~/.config/hypr/monitors.conf"

# ============================================================
# RESUMEN FINAL
# ============================================================

echo ""
echo -e "${BLD}${GRN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLD}${GRN}║   Instalación completada correctamente                    ║${NC}"
echo -e "${BLD}${GRN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLD}${GRN}║  ✓ Drivers NVIDIA RTX 3070 (nvidia-open)                 ║${NC}"
echo -e "${BLD}${GRN}║  ✓ Hyprland + Waybar + Kitty + Wofi + Mako               ║${NC}"
echo -e "${BLD}${GRN}║  ✓ Tema Catppuccin Mocha (GTK + Waybar + Terminal)        ║${NC}"
echo -e "${BLD}${GRN}║  ✓ Iconos Fluent Dark + Cursor Bibata                    ║${NC}"
echo -e "${BLD}${GRN}║  ✓ SDDM con tema Catppuccin                              ║${NC}"
echo -e "${BLD}${GRN}║  ✓ Zsh + Starship (prompt ソウ →)                        ║${NC}"
echo -e "${BLD}${GRN}║  ✓ Zen Browser + VSCode + Neovim                         ║${NC}"
echo -e "${BLD}${GRN}║  ✓ Steam + Proton GE                                     ║${NC}"
echo -e "${BLD}${GRN}║  ✓ Dotfiles desde github.com/XFR4KT4L/dotfiles           ║${NC}"
echo -e "${BLD}${GRN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLD}${GRN}║  PENDIENTE TRAS REINICIAR:                               ║${NC}"
echo -e "${BLD}${GRN}║                                                           ║${NC}"
echo -e "${BLD}${GRN}║  1. Copia tus wallpapers a:                              ║${NC}"
echo -e "${BLD}${GRN}║     ~/.config/hypr/wallpapers/                           ║${NC}"
echo -e "${BLD}${GRN}║                                                           ║${NC}"
echo -e "${BLD}${GRN}║  2. Verifica nombres de monitores:                       ║${NC}"
echo -e "${BLD}${GRN}║     hyprctl monitors                                     ║${NC}"
echo -e "${BLD}${GRN}║                                                           ║${NC}"
echo -e "${BLD}${GRN}║  3. Configura Steam → Proton Experimental para           ║${NC}"
echo -e "${BLD}${GRN}║     juegos con el nativo Linux roto                      ║${NC}"
echo -e "${BLD}${GRN}║                                                           ║${NC}"
echo -e "${BLD}${GRN}║  4. Opcional: ejecutar security-setup.sh para            ║${NC}"
echo -e "${BLD}${GRN}║     Secure Boot, UFW y DNS cifrado                       ║${NC}"
echo -e "${BLD}${GRN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Reinicia con: ${CYN}sudo reboot${NC}"
