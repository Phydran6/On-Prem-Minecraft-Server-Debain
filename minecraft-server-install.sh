#!/bin/bash

# ============================================================
# Minecraft Server Auto-Installer für Debian 12/13
# 
# Vollautomatisches Deployment eines Minecraft Servers
# mit interaktiver Konfiguration
#
# Repository: https://github.com/DEIN-USERNAME/minecraft-server-installer
# ============================================================

set -e  # Beenden bei Fehlern

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Konfigurationsvariablen
MINECRAFT_USER="minecraft"
MINECRAFT_DIR="/opt/minecraft"
SERVICE_NAME="minecraft.service"

# Banner
clear
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║       MINECRAFT SERVER AUTO-INSTALLER                    ║"
echo "║              für Debian 12/13 & Ubuntu                   ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# Hilfsfunktionen
# ============================================================

print_step() {
    echo -e "\n${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# ASCII Fortschrittsbalken
show_progress() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '#'
    printf "%${empty}s" | tr ' ' '-'
    printf "] %3d%%" "$percentage"
}

# ============================================================
# System-Prüfungen
# ============================================================

print_step "Systemprüfungen durchführen..."

# Prüfung ob als root ausgeführt
if [[ $EUID -eq 0 ]]; then
    print_error "Dieses Script sollte NICHT als root ausgeführt werden!"
    echo "Führe es als normaler User mit sudo-Rechten aus."
    exit 1
fi

# Prüfung ob sudo verfügbar
if ! command -v sudo &> /dev/null; then
    print_error "sudo ist nicht installiert!"
    exit 1
fi

# Prüfung ob User sudo-Rechte hat
if ! sudo -v &> /dev/null; then
    print_error "Keine sudo-Rechte vorhanden!"
    exit 1
fi

# Prüfung der Distribution
if grep -qE "Debian GNU/Linux (12|13)" /etc/os-release 2>/dev/null; then
    print_success "Debian erkannt"
elif grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    print_success "Ubuntu erkannt"
else
    print_warning "Nicht-optimale Distribution erkannt"
    read -p "Trotzdem fortfahren? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_success "Systemprüfungen erfolgreich"

# ============================================================
# Interaktive Konfiguration
# ============================================================

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    KONFIGURATION                          ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# RAM-Konfiguration
echo -e "\n${YELLOW}📊 RAM-Konfiguration:${NC}"
echo "Empfehlungen basierend auf Spieleranzahl:"
echo "  • 1-5 Spieler:   2-3 GB"
echo "  • 5-10 Spieler:  3-4 GB"
echo "  • 10-20 Spieler: 4-6 GB"
echo "  • 20+ Spieler:   6-8 GB"
echo ""
while true; do
    read -p "RAM für Minecraft Server (in GB) [4]: " MC_RAM
    MC_RAM=${MC_RAM:-4}
    if [[ $MC_RAM =~ ^[0-9]+$ ]] && [ "$MC_RAM" -ge 1 ] && [ "$MC_RAM" -le 32 ]; then
        break
    else
        print_error "Bitte gib eine Zahl zwischen 1 und 32 ein."
    fi
done
print_success "RAM: ${MC_RAM} GB"

# Maximale Spieler
echo -e "\n${YELLOW}👥 Maximale Spieleranzahl:${NC}"
while true; do
    read -p "Max. Spieler [10]: " MAX_PLAYERS
    MAX_PLAYERS=${MAX_PLAYERS:-10}
    if [[ $MAX_PLAYERS =~ ^[0-9]+$ ]] && [ "$MAX_PLAYERS" -ge 1 ]; then
        break
    else
        print_error "Bitte gib eine gültige Zahl ein."
    fi
done
print_success "Max. Spieler: ${MAX_PLAYERS}"

# Server-Name (MOTD)
echo -e "\n${YELLOW}🏷️  Server-Name (MOTD):${NC}"
read -p "Server-Name [Minecraft Server]: " SERVER_MOTD
SERVER_MOTD=${SERVER_MOTD:-"Minecraft Server"}
print_success "Server-Name: ${SERVER_MOTD}"

# Schwierigkeit
echo -e "\n${YELLOW}⚔️  Schwierigkeit:${NC}"
echo "  1) Peaceful (Keine Monster)"
echo "  2) Easy"
echo "  3) Normal (Empfohlen)"
echo "  4) Hard"
while true; do
    read -p "Wähle Schwierigkeit (1-4) [3]: " DIFF_CHOICE
    DIFF_CHOICE=${DIFF_CHOICE:-3}
    case $DIFF_CHOICE in
        1) DIFFICULTY="peaceful"; break;;
        2) DIFFICULTY="easy"; break;;
        3) DIFFICULTY="normal"; break;;
        4) DIFFICULTY="hard"; break;;
        *) print_error "Bitte wähle 1, 2, 3 oder 4.";;
    esac
done
print_success "Schwierigkeit: ${DIFFICULTY}"

# Spielmodus
echo -e "\n${YELLOW}🎯 Spielmodus:${NC}"
echo "  1) Survival (Empfohlen)"
echo "  2) Creative"
echo "  3) Adventure"
while true; do
    read -p "Wähle Spielmodus (1-3) [1]: " MODE_CHOICE
    MODE_CHOICE=${MODE_CHOICE:-1}
    case $MODE_CHOICE in
        1) GAMEMODE="survival"; break;;
        2) GAMEMODE="creative"; break;;
        3) GAMEMODE="adventure"; break;;
        *) print_error "Bitte wähle 1, 2 oder 3.";;
    esac
done
print_success "Spielmodus: ${GAMEMODE}"

# PvP
echo -e "\n${YELLOW}⚔️  PvP (Spieler vs Spieler):${NC}"
read -p "PvP aktivieren? (Y/n): " PVP_CHOICE
if [[ $PVP_CHOICE =~ ^[Nn]$ ]]; then
    PVP_ENABLED="false"
else
    PVP_ENABLED="true"
fi
print_success "PvP: ${PVP_ENABLED}"

# Online-Mode
echo -e "\n${YELLOW}🔐 Online-Mode:${NC}"
echo "  • true  = Nur Original-Accounts (Empfohlen)"
echo "  • false = Cracked Clients erlaubt"
read -p "Online-Mode aktivieren? (Y/n): " ONLINE_CHOICE
if [[ $ONLINE_CHOICE =~ ^[Nn]$ ]]; then
    ONLINE_MODE="false"
    print_warning "Online-Mode deaktiviert - Cracked Clients erlaubt!"
else
    ONLINE_MODE="true"
fi
print_success "Online-Mode: ${ONLINE_MODE}"

# Backups
echo -e "\n${YELLOW}💾 Automatische Backups:${NC}"
read -p "Automatische Backups aktivieren (alle 6 Stunden)? (Y/n): " BACKUP_CHOICE
if [[ $BACKUP_CHOICE =~ ^[Nn]$ ]]; then
    ENABLE_BACKUPS="false"
else
    ENABLE_BACKUPS="true"
fi
print_success "Automatische Backups: ${ENABLE_BACKUPS}"

# Minecraft Version
echo -e "\n${YELLOW}🎮 Minecraft Client-Version:${NC}"
echo "Welche Minecraft-Version verwendest du in deinem Launcher?"
echo "(Schaue unten rechts im Minecraft Launcher für die exakte Version)"
echo ""
echo "Beispiele: 1.21, 1.21.1, 1.21.4, 1.21.8"
while true; do
    read -p "Deine Minecraft-Version: " MC_VERSION
    if [[ $MC_VERSION =~ ^1\.[0-9]+(\.[0-9]+)?$ ]]; then
        break
    else
        print_error "Bitte gib eine gültige Version ein (z.B. 1.21.8)"
    fi
done

# Server-URLs für verschiedene Versionen
declare -A SERVER_URLS
SERVER_URLS["1.21"]="https://piston-data.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar"
SERVER_URLS["1.21.1"]="https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar"
SERVER_URLS["1.21.2"]="https://piston-data.mojang.com/v1/objects/3cf2bac3e3a6e6b2fc87a43fb49fe9633eb9b573/server.jar"
SERVER_URLS["1.21.3"]="https://piston-data.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar"
SERVER_URLS["1.21.4"]="https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar"
SERVER_URLS["1.21.5"]="https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar"
SERVER_URLS["1.21.6"]="https://piston-data.mojang.com/v1/objects/939e45f93e2b7994b102b0ddba8c1ed586a21fe6/server.jar"
SERVER_URLS["1.21.7"]="https://piston-data.mojang.com/v1/objects/1ed8977ee5ce67e9eddf22c0386c1f9dc3ff3ec2/server.jar"
SERVER_URLS["1.21.8"]="https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar"

# Prüfe ob URL für Version existiert
if [[ -n "${SERVER_URLS[$MC_VERSION]}" ]]; then
    SERVER_JAR_URL="${SERVER_URLS[$MC_VERSION]}"
    print_success "Server-URL für Version $MC_VERSION gefunden"
else
    print_warning "Keine direkte URL für $MC_VERSION in der Datenbank"
    echo "Versuche Version von Mojang API zu ermitteln..."
    
    # Versuche URL über Mojang Manifest zu finden
    MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"
    VERSION_JSON=$(curl -s "$MANIFEST_URL" | grep -o "\"id\":\"$MC_VERSION\"[^}]*" | head -1)
    
    if [ -n "$VERSION_JSON" ]; then
        print_warning "Version $MC_VERSION nicht in lokaler URL-Liste"
        echo "Bitte prüfe minecraft.net/download/server für die aktuelle URL"
        read -p "Server JAR URL manuell eingeben: " SERVER_JAR_URL
    else
        print_error "Version $MC_VERSION nicht gefunden!"
        echo "Verwende neueste verfügbare Version (1.21.8)"
        SERVER_JAR_URL="${SERVER_URLS["1.21.8"]}"
        MC_VERSION="1.21.8"
    fi
fi
print_success "Version: ${MC_VERSION}"

# ============================================================
# Konfigurationsübersicht
# ============================================================

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                KONFIGURATIONSÜBERSICHT                    ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  RAM:                ${MC_RAM} GB"
echo "  Max. Spieler:       ${MAX_PLAYERS}"
echo "  Server-Name:        ${SERVER_MOTD}"
echo "  Schwierigkeit:      ${DIFFICULTY}"
echo "  Spielmodus:         ${GAMEMODE}"
echo "  PvP:                ${PVP_ENABLED}"
echo "  Online-Mode:        ${ONLINE_MODE}"
echo "  Backups:            ${ENABLE_BACKUPS}"
echo "  Minecraft Version:  ${MC_VERSION}"
echo ""
read -p "Mit dieser Konfiguration fortfahren? (Y/n): " CONFIRM
if [[ $CONFIRM =~ ^[Nn]$ ]]; then
    echo "Installation abgebrochen."
    exit 0
fi

# ============================================================
# Installation beginnt
# ============================================================

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                INSTALLATION STARTET                       ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# APT Konfiguration für nicht-interaktive Installation
export DEBIAN_FRONTEND=noninteractive

# Schritt 1: System-Update
print_step "System wird aktualisiert..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
print_success "System aktualisiert"

# Schritt 2: Abhängigkeiten installieren
print_step "Abhängigkeiten werden installiert..."
sudo apt-get install -y -qq wget curl screen ufw net-tools

# Java installieren (OpenJDK 21 bevorzugt, Fallback auf 17)
if apt-cache show openjdk-21-jre-headless &> /dev/null; then
    sudo apt-get install -y -qq openjdk-21-jre-headless
    print_success "OpenJDK 21 installiert"
elif apt-cache show openjdk-17-jre-headless &> /dev/null; then
    sudo apt-get install -y -qq openjdk-17-jre-headless
    print_success "OpenJDK 17 installiert"
else
    print_error "Keine kompatible Java-Version gefunden!"
    exit 1
fi

# Schritt 3: Minecraft-Benutzer erstellen
print_step "Minecraft-Benutzer wird erstellt..."
if id "$MINECRAFT_USER" &>/dev/null; then
    print_warning "Benutzer ${MINECRAFT_USER} existiert bereits"
else
    sudo useradd -r -m -U -d ${MINECRAFT_DIR} -s /bin/bash ${MINECRAFT_USER}
    print_success "Benutzer ${MINECRAFT_USER} erstellt"
fi

# Schritt 4: Verzeichnis vorbereiten
print_step "Server-Verzeichnis wird vorbereitet..."
sudo mkdir -p ${MINECRAFT_DIR}
sudo chown -R ${MINECRAFT_USER}:${MINECRAFT_USER} ${MINECRAFT_DIR}
print_success "Verzeichnis ${MINECRAFT_DIR} erstellt"

# Schritt 5: Server JAR herunterladen
print_step "Minecraft Server ${MC_VERSION} wird heruntergeladen..."
echo ""

# Download mit Fortschrittsanzeige
sudo -u ${MINECRAFT_USER} wget --progress=bar:force:noscroll -O ${MINECRAFT_DIR}/server.jar "${SERVER_JAR_URL}" 2>&1 | \
    grep --line-buffered "%" | \
    sed -u -e "s,\.,,g" | \
    awk '{print $2}' | \
    while read -r perc; do
        echo -ne "\r${CYAN}Download: ${perc}${NC}    "
    done
echo ""

if [ -f "${MINECRAFT_DIR}/server.jar" ]; then
    print_success "Server JAR heruntergeladen"
else
    print_error "Download fehlgeschlagen!"
    exit 1
fi

# Schritt 6: EULA akzeptieren
print_step "EULA wird akzeptiert..."
sudo -u ${MINECRAFT_USER} bash -c "echo 'eula=true' > ${MINECRAFT_DIR}/eula.txt"
print_success "EULA akzeptiert"

# Schritt 7: server.properties erstellen
print_step "Server-Konfiguration wird erstellt..."
sudo -u ${MINECRAFT_USER} tee ${MINECRAFT_DIR}/server.properties > /dev/null << EOF
# Minecraft Server Properties
# Generiert durch Auto-Installer

# Netzwerk
server-port=25565
server-ip=
enable-query=false
query.port=25565

# Spieler
max-players=${MAX_PLAYERS}
white-list=false
enforce-whitelist=false
player-idle-timeout=0

# Gameplay
gamemode=${GAMEMODE}
difficulty=${DIFFICULTY}
pvp=${PVP_ENABLED}
allow-flight=false
spawn-protection=16

# Welt
level-name=world
level-seed=
level-type=minecraft\:normal
generate-structures=true
max-world-size=29999984
spawn-animals=true
spawn-monsters=true
spawn-npcs=true

# Server
online-mode=${ONLINE_MODE}
motd=${SERVER_MOTD}
enable-rcon=false
enable-command-block=false
max-tick-time=60000
view-distance=10
simulation-distance=10

# Ressourcenpaket
resource-pack=
resource-pack-sha1=
require-resource-pack=false
EOF
print_success "server.properties erstellt"

# Schritt 8: Systemd Service erstellen
print_step "Systemd Service wird erstellt..."
sudo tee /etc/systemd/system/${SERVICE_NAME} > /dev/null << EOF
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=${MINECRAFT_USER}
Nice=5
KillMode=none
SuccessExitStatus=0 1
ProtectHome=true
ProtectSystem=full
PrivateDevices=true
NoNewPrivileges=true
WorkingDirectory=${MINECRAFT_DIR}
ExecStart=/usr/bin/screen -DmS minecraft /usr/bin/java -Xmx${MC_RAM}G -Xms${MC_RAM}G -jar server.jar nogui
ExecStop=/usr/bin/screen -p 0 -S minecraft -X eval 'stuff "say SERVER WIRD HERUNTERGEFAHREN..."\015'
ExecStop=/bin/sleep 5
ExecStop=/usr/bin/screen -p 0 -S minecraft -X eval 'stuff "stop"\015'
ExecStop=/bin/sleep 10
Restart=on-failure
RestartSec=60s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME} --quiet
print_success "Systemd Service erstellt und aktiviert"

# Schritt 9: Firewall konfigurieren
print_step "Firewall wird konfiguriert..."
if command -v ufw &> /dev/null; then
    sudo ufw allow 25565/tcp > /dev/null 2>&1 || true
    sudo ufw allow 25565/udp > /dev/null 2>&1 || true
    print_success "UFW Regeln hinzugefügt (Port 25565)"
else
    print_warning "UFW nicht installiert - Firewall manuell konfigurieren"
fi

# Schritt 10: Backup-System (optional)
if [ "$ENABLE_BACKUPS" = "true" ]; then
    print_step "Backup-System wird eingerichtet..."
    
    # Backup-Verzeichnis erstellen
    sudo -u ${MINECRAFT_USER} mkdir -p ${MINECRAFT_DIR}/backups
    
    # Backup-Script erstellen
    sudo -u ${MINECRAFT_USER} tee ${MINECRAFT_DIR}/backup.sh > /dev/null << 'EOF'
#!/bin/bash
# Minecraft Server Backup Script

BACKUP_DIR="/opt/minecraft/backups"
MINECRAFT_DIR="/opt/minecraft"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_NAME="minecraft-backup-${DATE}.tar.gz"

# Erstelle Backup
cd ${MINECRAFT_DIR}
tar -czf ${BACKUP_DIR}/${BACKUP_NAME} world world_nether world_the_end server.properties 2>/dev/null

# Lösche Backups älter als 7 Tage
find ${BACKUP_DIR} -name "minecraft-backup-*.tar.gz" -mtime +7 -delete

echo "Backup erstellt: ${BACKUP_NAME}"
EOF
    
    sudo chmod +x ${MINECRAFT_DIR}/backup.sh
    
    # Cronjob für automatische Backups
    (sudo -u ${MINECRAFT_USER} crontab -l 2>/dev/null; echo "0 */6 * * * ${MINECRAFT_DIR}/backup.sh") | sudo -u ${MINECRAFT_USER} crontab -
    
    print_success "Backup-System eingerichtet (alle 6 Stunden)"
fi

# Schritt 11: Server starten
print_step "Minecraft Server wird gestartet..."
sudo systemctl start ${SERVICE_NAME}

# Warte auf Start
echo -n "Warte auf Server-Start"
for i in {1..30}; do
    if sudo systemctl is-active --quiet ${SERVICE_NAME}; then
        break
    fi
    echo -n "."
    sleep 1
done
echo ""

# ============================================================
# Installation abgeschlossen
# ============================================================

# Server-IP ermitteln
SERVER_IP=$(hostname -I | awk '{print $1}')

echo -e "\n${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}        INSTALLATION ERFOLGREICH ABGESCHLOSSEN!            ${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"

echo -e "\n${BLUE}📡 Server-Informationen:${NC}"
echo "  IP-Adresse:         ${SERVER_IP}"
echo "  Port:               25565"
echo "  Minecraft-Adresse:  ${SERVER_IP}:25565"
echo "  Minecraft Version:  ${MC_VERSION}"

echo -e "\n${BLUE}📝 Nützliche Befehle:${NC}"
echo "  Server-Status:      sudo systemctl status ${SERVICE_NAME}"
echo "  Server stoppen:     sudo systemctl stop ${SERVICE_NAME}"
echo "  Server starten:     sudo systemctl start ${SERVICE_NAME}"
echo "  Server neustarten:  sudo systemctl restart ${SERVICE_NAME}"
echo "  Logs anzeigen:      sudo journalctl -u ${SERVICE_NAME} -f"
echo "  Console öffnen:     sudo -u ${MINECRAFT_USER} screen -r minecraft"
echo "  Console verlassen:  Ctrl+A dann D"

if [ "$ENABLE_BACKUPS" = "true" ]; then
    echo -e "\n${BLUE}💾 Backup-Befehle:${NC}"
    echo "  Manuelles Backup:   sudo -u ${MINECRAFT_USER} ${MINECRAFT_DIR}/backup.sh"
    echo "  Backup-Ordner:      ${MINECRAFT_DIR}/backups/"
fi

echo -e "\n${YELLOW}⚠️  Wichtige Hinweise:${NC}"
echo "  • Der Server startet automatisch beim Neustart der VM"
echo "  • Erste Weltgenerierung kann 1-2 Minuten dauern"
echo "  • Port 25565 muss im Router weitergeleitet werden für Internet-Zugang"

if [ "$ONLINE_MODE" = "false" ]; then
    echo -e "  • ${YELLOW}Online-Mode ist deaktiviert (Cracked-Clients erlaubt)${NC}"
fi

# Finale Statusprüfung
echo -e "\n${BLUE}🔍 Finale Statusprüfung...${NC}"
sleep 5

echo -n "  Systemd Service: "
if sudo systemctl is-active --quiet ${SERVICE_NAME}; then
    echo -e "${GREEN}✓ Aktiv${NC}"
else
    echo -e "${RED}✗ Inaktiv${NC}"
fi

echo -n "  Minecraft-Prozess: "
if pgrep -f "minecraft.*java" > /dev/null || pgrep -f "java.*server.jar" > /dev/null; then
    echo -e "${GREEN}✓ Läuft${NC}"
else
    echo -e "${YELLOW}⏳ Startet noch...${NC}"
fi

echo -n "  Port 25565: "
sleep 5
if sudo ss -tlnp 2>/dev/null | grep -q ":25565 " || sudo netstat -tlnp 2>/dev/null | grep -q ":25565 "; then
    echo -e "${GREEN}✓ Geöffnet${NC}"
else
    echo -e "${YELLOW}⏳ Wird noch geöffnet...${NC}"
fi

# Versions-Verifizierung
echo -e "\n${BLUE}🔍 Server-Version wird verifiziert...${NC}"
sleep 10
RUNNING_VERSION=$(sudo journalctl -u ${SERVICE_NAME} --no-pager -n 50 2>/dev/null | grep -o "Starting minecraft server version [0-9.]*" | tail -1 | grep -o "[0-9.]*$")
if [ -n "$RUNNING_VERSION" ]; then
    if [ "$RUNNING_VERSION" = "$MC_VERSION" ]; then
        echo -e "  ${GREEN}✓ Server läuft mit Version ${RUNNING_VERSION}${NC}"
    else
        echo -e "  ${YELLOW}⚠ Server läuft mit Version ${RUNNING_VERSION} (erwartet: ${MC_VERSION})${NC}"
    fi
else
    echo -e "  ${YELLOW}⏳ Version wird noch geladen...${NC}"
fi

echo -e "\n${GREEN}🎮 Viel Spaß mit deinem Minecraft Server!${NC}"
echo ""
